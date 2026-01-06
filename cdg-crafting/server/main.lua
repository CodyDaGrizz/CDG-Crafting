local DB = require('server.db')

-- Per-citizen active craft sessions (queue started via UI "CRAFT" button)
-- cid -> { benchId = string, jobs = { {recipeId=string, quantity=number}... }, refunds = { {item,count}... } }
local Sessions = {}

local function getCitizenId(src)
  local Player = exports.qbx_core:GetPlayer(src)
  if not Player then return nil end
  return Player.PlayerData.citizenid
end

local function notify(src, msg, ntype)
  TriggerClientEvent('ox_lib:notify', src, {
    title = 'Crafting',
    description = msg,
    type = ntype or 'inform'
  })
end

local function getBenchById(benchId)
  for _, b in ipairs(Config.Benches) do
    if b.id == benchId then return b end
  end
  return nil
end

local function isPlayerNearBench(src, bench)
  local ped = GetPlayerPed(src)
  if not ped or ped <= 0 then return false end
  local pcoords = GetEntityCoords(ped)
  local dist = #(pcoords - bench.coords)
  return dist <= (bench.radius or 1.5)
end

local function benchHasRecipe(bench, recipeId)
  for _, id in ipairs(bench.recipes or {}) do
    if id == recipeId then return true end
  end
  return false
end

local function calcLevelFromXp(category, xp)
  local cat = Config.Categories[category]
  if not cat or not cat.levels then return 1 end
  local lvl = 1
  for level, req in pairs(cat.levels) do
    if xp >= req and level > lvl then lvl = level end
  end
  return lvl
end

local function buildBenchCounts(src, bench)
  local counts = {}
  local seen = {}

  for _, recipeId in ipairs(bench.recipes or {}) do
    local recipe = Config.Recipes[recipeId]
    if recipe and recipe.ingredients then
      for _, ing in ipairs(recipe.ingredients) do
        if ing.item and not seen[ing.item] then
          seen[ing.item] = true
          counts[ing.item] = exports.ox_inventory:Search(src, 'count', ing.item) or 0
        end
      end
    end
  end

  return counts
end

local function aggregateRefunds(refunds, recipe, qty)
  for _, ing in ipairs(recipe.ingredients or {}) do
    local amt = (ing.count or 0) * qty
    if amt > 0 then
      refunds[#refunds+1] = { item = ing.item, count = amt }
    end
  end
end

local function validateAndBuildSession(src, cid, benchId, queue)
  local bench = getBenchById(benchId)
  if not bench then return nil, 'Invalid bench.' end
  if not isPlayerNearBench(src, bench) then return nil, 'You are too far from the bench.' end

  local jobs = {}
  local refunds = {}

  local maxQty = Config.MaxCraftQuantity or 100

  -- Validate each job
  for i = 1, #queue do
    local entry = queue[i]
    local recipeId = entry.recipeId
    local qty = math.floor(tonumber(entry.quantity) or 1)
    if qty < 1 then qty = 1 end
    if qty > maxQty then qty = maxQty end

    if not recipeId or not benchHasRecipe(bench, recipeId) then
      return nil, 'This bench cannot craft one of the queued recipes.'
    end

    local recipe = Config.Recipes[recipeId]
    if not recipe then return nil, 'One of the queued recipes is invalid.' end

    local category = recipe.category
    if not category or not Config.Categories[category] then
      return nil, 'One of the queued recipes is misconfigured.'
    end

    local requiresBlueprint = (recipe.requiresBlueprint ~= false)
    if requiresBlueprint and not DB.hasLearned(cid, recipeId) then
      return nil, 'You have not learned one of the required blueprints.'
    end

    local prog = DB.getSkill(cid, category)
    local reqLevel = recipe.levelRequired or 1
    if (prog.level or 1) < reqLevel then
      return nil, ('Your %s level is too low.'):format(Config.Categories[category].label or category)
    end

    -- Check materials (for this job now; we remove for whole queue after validation)
    for _, ing in ipairs(recipe.ingredients or {}) do
      local need = (ing.count or 0) * qty
      local have = exports.ox_inventory:Search(src, 'count', ing.item) or 0
      if have < need then
        return nil, 'Missing materials.'
      end
    end

    jobs[#jobs+1] = { recipeId = recipeId, quantity = qty }
    aggregateRefunds(refunds, recipe, qty)
  end

  return {
    benchId = benchId,
    jobs = jobs,
    refunds = refunds,
  }, nil
end

-- Blueprint usable items (QBOX)
for blueprintItem, data in pairs(Config.Blueprints or {}) do
  exports.qbx_core:CreateUseableItem(blueprintItem, function(source, item)
    local cid = getCitizenId(source)
    if not cid then return end

    local taught = 0
    for _, recipeId in ipairs(data.teaches or {}) do
      if Config.Recipes[recipeId] then
        DB.learnRecipe(cid, recipeId)
        taught += 1
      end
    end

    if taught <= 0 then
      return notify(source, 'This blueprint is misconfigured.', 'error')
    end

    if data.consumeOnUse then
      if item and item.slot then
        exports.ox_inventory:RemoveItem(source, blueprintItem, 1, item.metadata, item.slot)
      else
        exports.ox_inventory:RemoveItem(source, blueprintItem, 1)
      end
    end

    notify(source, ('Learned %d blueprint(s).'):format(taught), 'success')
  end)
end

-- UI data
lib.callback.register('cdg-crafting:server:getBenchData', function(source, benchId)
  local cid = getCitizenId(source)
  if not cid then return nil end

  local bench = getBenchById(benchId)
  if not bench then return nil end
  if not isPlayerNearBench(source, bench) then return nil end

  local learned = DB.getLearnedMap(cid)
  local skills = DB.getAllSkills(cid)

  for catName, _ in pairs(Config.Categories) do
    if not skills[catName] then
      skills[catName] = DB.getSkill(cid, catName)
    end
  end

  local counts = buildBenchCounts(source, bench)

  return {
    bench = { id = bench.id, label = bench.label, recipes = bench.recipes },
    learned = learned,
    skills = skills,
    categories = Config.Categories,
    recipes = Config.Recipes,
    counts = counts,
    maxQty = Config.MaxCraftQuantity or 100
  }
end)

lib.callback.register('cdg-crafting:server:getCounts', function(source, benchId)
  local bench = getBenchById(benchId)
  if not bench then return nil end
  if not isPlayerNearBench(source, bench) then return nil end
  return buildBenchCounts(source, bench)
end)

-- Begin a craft session (reserve materials for the full queue)
lib.callback.register('cdg-crafting:server:beginQueue', function(source, benchId, queue)
  local cid = getCitizenId(source)
  if not cid then return false, 'No character.' end
  if Sessions[cid] then return false, 'You are already crafting.' end
  if type(queue) ~= 'table' or #queue == 0 then return false, 'Queue is empty.' end

  local session, err = validateAndBuildSession(source, cid, benchId, queue)
  if not session then return false, err end

  -- Remove all materials up-front (anti-exploit)
  for _, r in ipairs(session.refunds) do
    exports.ox_inventory:RemoveItem(source, r.item, r.count)
  end

  Sessions[cid] = session
  return true, nil
end)

-- Return server-authoritative duration (hidden from UI; used by progressbar)
lib.callback.register('cdg-crafting:server:getJobDuration', function(source, recipeId, quantity)
  local cid = getCitizenId(source)
  if not cid then return nil end
  local session = Sessions[cid]
  if not session then return nil end

  local qty = math.floor(tonumber(quantity) or 1)
  if qty < 1 then qty = 1 end

  local recipe = Config.Recipes[recipeId]
  if not recipe then return nil end
  return (recipe.craftTime or 0) * qty
end)

-- Finish a job: grant outputs + XP
lib.callback.register('cdg-crafting:server:finishJob', function(source, recipeId, quantity)
  local cid = getCitizenId(source)
  if not cid then return false end
  local session = Sessions[cid]
  if not session then return false end

  local recipe = Config.Recipes[recipeId]
  if not recipe then return false end

  local qty = math.floor(tonumber(quantity) or 1)
  if qty < 1 then qty = 1 end

  -- Outputs
  for _, out in ipairs(recipe.outputs or {}) do
    exports.ox_inventory:AddItem(source, out.item, (out.count or 0) * qty)
  end

  -- XP
  local category = recipe.category
  local prog = DB.getSkill(cid, category)
  local gained = (recipe.xpGain or 0) * qty
  local newXp = (prog.xp or 0) + gained
  local newLevel = calcLevelFromXp(category, newXp)
  DB.setSkill(cid, category, newXp, newLevel)

  TriggerClientEvent('cdg-crafting:client:crafted', source, {
    recipeId = recipeId,
    category = category,
    xp = newXp,
    level = newLevel,
    xpGained = gained,
    quantity = qty
  })

  return true
end)

-- Cancel current session and refund ALL remaining materials (full refund)
RegisterNetEvent('cdg-crafting:server:cancelQueueRefund', function()
  local src = source
  local cid = getCitizenId(src)
  if not cid then return end
  local session = Sessions[cid]
  if not session then return end

  for _, r in ipairs(session.refunds or {}) do
    exports.ox_inventory:AddItem(src, r.item, r.count)
  end

  Sessions[cid] = nil
  notify(src, 'Crafting cancelled. Materials refunded.', 'error')
end)

-- End a session when queue completes
RegisterNetEvent('cdg-crafting:server:endSession', function()
  local src = source
  local cid = getCitizenId(src)
  if not cid then return end
  Sessions[cid] = nil
end)

-- Admin commands (same as earlier versions)
local function playerCitizenId(target)
  local Player = exports.qbx_core:GetPlayer(target)
  return Player and Player.PlayerData and Player.PlayerData.citizenid or nil
end

local function parseInt(x)
  local n = tonumber(x)
  if not n then return nil end
  return math.floor(n)
end

lib.addCommand('cdgblueprint', {
  help = 'Blueprint admin tools',
  restricted = true,
  params = {
    { name = 'action', help = 'give | unlock', type = 'string' },
    { name = 'playerId', help = 'Server ID', type = 'number' },
    { name = 'id', help = 'Blueprint item OR recipeId', type = 'string' },
  }
}, function(source, args)
  local action, target, id = args.action, args.playerId, args.id
  if not target or not id then return end

  local cid = playerCitizenId(target)
  if not cid then return notify(source, 'Invalid target player.', 'error') end

  if action == 'give' then
    if not Config.Blueprints[id] then return notify(source, 'Unknown blueprint item in Config.Blueprints.', 'error') end
    exports.ox_inventory:AddItem(target, id, 1)
    notify(source, ('Gave %s to %d'):format(id, target), 'success')
    notify(target, 'You received a blueprint.', 'inform')
    return
  end

  if action == 'unlock' then
    if not Config.Recipes[id] then return notify(source, 'Unknown recipeId in Config.Recipes.', 'error') end
    DB.learnRecipe(cid, id)
    notify(source, ('Unlocked recipe %s for %d'):format(id, target), 'success')
    notify(target, 'An admin unlocked a blueprint for you.', 'inform')
    return
  end

  notify(source, 'Usage: /cdgblueprint give <playerId> <blueprintItem> OR /cdgblueprint unlock <playerId> <recipeId>', 'error')
end)

lib.addCommand('cdgcraft', {
  help = 'Crafting skill admin tools',
  restricted = true,
  params = {
    { name = 'action', help = 'reset | setlevel | addxp', type = 'string' },
    { name = 'playerId', help = 'Server ID', type = 'number' },
    { name = 'category', help = 'Category name or "all" (reset)', type = 'string' },
    { name = 'value', help = 'Level or XP amount', type = 'number', optional = true },
  }
}, function(source, args)
  local action, target, category, value = args.action, args.playerId, args.category, args.value
  if not target or not category then return end

  local cid = playerCitizenId(target)
  if not cid then return notify(source, 'Invalid target player.', 'error') end

  if action == 'reset' then
    if category == 'all' then
      exports.oxmysql:query_async('DELETE FROM cdg_crafting_skills WHERE citizenid = ?', { cid })
      notify(source, ('Reset ALL crafting categories for %d'):format(target), 'success')
      notify(target, 'Your crafting skills were reset by an admin.', 'inform')
      return
    end

    if not Config.Categories[category] then return notify(source, 'Unknown category.', 'error') end
    exports.oxmysql:query_async('DELETE FROM cdg_crafting_skills WHERE citizenid = ? AND category = ?', { cid, category })
    notify(source, ('Reset %s for %d'):format(category, target), 'success')
    notify(target, ('Your %s skill was reset by an admin.'):format(category), 'inform')
    return
  end

  if action == 'setlevel' then
    if not Config.Categories[category] then return notify(source, 'Unknown category.', 'error') end
    local lvl = parseInt(value)
    if not lvl or lvl < 1 then return notify(source, 'Invalid level.', 'error') end

    local reqXp = Config.Categories[category].levels[lvl] or 0
    DB.ensureSkillRow(cid, category)
    DB.setSkill(cid, category, reqXp, lvl)

    notify(source, ('Set %s to level %d for %d'):format(category, lvl, target), 'success')
    notify(target, ('Your %s level was set to %d by an admin.'):format(category, lvl), 'inform')
    return
  end

  if action == 'addxp' then
    if not Config.Categories[category] then return notify(source, 'Unknown category.', 'error') end
    local amount = parseInt(value)
    if not amount then return notify(source, 'Invalid XP amount.', 'error') end

    local prog = DB.getSkill(cid, category)
    local newXp = (prog.xp or 0) + amount
    if newXp < 0 then newXp = 0 end
    local newLevel = calcLevelFromXp(category, newXp)

    DB.setSkill(cid, category, newXp, newLevel)

    notify(source, ('Added %d XP to %s for %d (Lv %d)'):format(amount, category, target, newLevel), 'success')
    notify(target, ('You gained %d %s XP (admin).'):format(amount, category), 'inform')
    return
  end

  notify(source, 'Usage: /cdgcraft reset <playerId> <category|all> | /cdgcraft setlevel <playerId> <category> <level> | /cdgcraft addxp <playerId> <category> <amount>', 'error')
end)
