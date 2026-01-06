local DB = {}
local oxmysql = exports.oxmysql

function DB.ensureSkillRow(citizenid, category)
  oxmysql:insert_async([[
    INSERT IGNORE INTO cdg_crafting_skills (citizenid, category, xp, level)
    VALUES (?, ?, 0, 1)
  ]], { citizenid, category })
end

function DB.getSkill(citizenid, category)
  DB.ensureSkillRow(citizenid, category)
  local rows = oxmysql:query_async(
    'SELECT xp, level FROM cdg_crafting_skills WHERE citizenid = ? AND category = ?',
    { citizenid, category }
  )
  if not rows or not rows[1] then return { xp = 0, level = 1 } end
  return { xp = rows[1].xp or 0, level = rows[1].level or 1 }
end

function DB.setSkill(citizenid, category, xp, level)
  oxmysql:update_async(
    'UPDATE cdg_crafting_skills SET xp = ?, level = ? WHERE citizenid = ? AND category = ?',
    { xp, level, citizenid, category }
  )
end

function DB.getAllSkills(citizenid)
  local rows = oxmysql:query_async(
    'SELECT category, xp, level FROM cdg_crafting_skills WHERE citizenid = ?',
    { citizenid }
  )
  local skills = {}
  for _, r in ipairs(rows or {}) do
    skills[r.category] = { xp = r.xp or 0, level = r.level or 1 }
  end
  return skills
end

function DB.hasLearned(citizenid, recipeId)
  local rows = oxmysql:query_async(
    'SELECT 1 FROM cdg_crafting_blueprints WHERE citizenid = ? AND recipe_id = ? LIMIT 1',
    { citizenid, recipeId }
  )
  return rows and rows[1] ~= nil
end

function DB.learnRecipe(citizenid, recipeId)
  oxmysql:insert_async(
    'INSERT IGNORE INTO cdg_crafting_blueprints (citizenid, recipe_id) VALUES (?, ?)',
    { citizenid, recipeId }
  )
end

function DB.getLearnedMap(citizenid)
  local rows = oxmysql:query_async(
    'SELECT recipe_id FROM cdg_crafting_blueprints WHERE citizenid = ?',
    { citizenid }
  )
  local learned = {}
  for _, r in ipairs(rows or {}) do
    learned[r.recipe_id] = true
  end
  return learned
end

return DB
