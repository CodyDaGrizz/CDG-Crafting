local isOpen = false
local currentBenchId = nil
local frozen = false
local isCrafting = false

local function setFrozen(state)
  local ped = PlayerPedId()
  FreezeEntityPosition(ped, state)
  frozen = state
end

local function hardCloseUi()
  isOpen = false
  currentBenchId = nil
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  if frozen then setFrozen(false) end
  SendNUIMessage({ action = 'close' })
end

local function openUi(benchId)
  if isOpen or isCrafting then return end
  currentBenchId = benchId

  local data = lib.callback.await('cdg-crafting:server:getBenchData', false, benchId)
  if not data then
    currentBenchId = nil
    return lib.notify({ type='error', description='Cannot open bench (too far or invalid).' })
  end

  isOpen = true
  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  setFrozen(true)

  SendNUIMessage({ action = 'open', payload = data })
end

local function closeUi()
  if not isOpen then return end
  isOpen = false
  currentBenchId = nil
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  if frozen then setFrozen(false) end
  SendNUIMessage({ action = 'close' })
end

-- Ensure UI never spawns open
AddEventHandler('onClientResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  hardCloseUi()
end)

AddEventHandler('playerSpawned', function()
  if not isOpen then hardCloseUi() end
end)

CreateThread(function()
  Wait(3000)
  if not isOpen then hardCloseUi() end
end)

-- Target zones
CreateThread(function()
  if not Config.UseTarget then return end

  for _, bench in ipairs(Config.Benches) do
    exports.ox_target:addSphereZone({
      coords = bench.coords,
      radius = bench.radius or 1.5,
      debug = false,
      options = {
        {
          name = ('cdg_crafting_%s'):format(bench.id),
          icon = bench.icon or 'fa-solid fa-hammer',
          label = ('Open %s'):format(bench.label or 'Crafting Bench'),
          onSelect = function()
            openUi(bench.id)
          end,
        }
      }
    })
  end
end)

RegisterNUICallback('close', function(_, cb)
  if isCrafting then
    lib.notify({ type='error', description='You are crafting. Cancel to stop.' })
    cb(true)
    return
  end
  closeUi()
  cb(true)
end)

-- Start queue crafting: UI builds the list, then presses a single CRAFT button
RegisterNUICallback('startQueue', function(data, cb)
  cb({ ok = true })

  if isCrafting then
    return lib.notify({ type='error', description='Already crafting.' })
  end

  if not currentBenchId then
    return lib.notify({ type='error', description='No bench selected.' })
  end

  local queue = (data and data.queue) or {}
  if type(queue) ~= 'table' or #queue == 0 then
    return lib.notify({ type='error', description='Queue is empty.' })
  end

  -- Ask server to validate + reserve materials for the full queue
  local ok, reason = lib.callback.await('cdg-crafting:server:beginQueue', false, currentBenchId, queue)
  if not ok then
    return lib.notify({ type='error', description = reason or 'Cannot start crafting.' })
  end

  -- Close the bench UI immediately
  closeUi()

  -- Run sequential crafting with ox_lib progressbar
  CreateThread(function()
    local ped = PlayerPedId()
    isCrafting = true

    -- Hard lock player + animation
    setFrozen(true)

    local dict, anim = 'amb@world_human_hammering@male@base', 'base'
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 1, 0.0, false, false, false)

    for i = 1, #queue do
      local job = queue[i]
      local recipeId = job.recipeId
      local qty = tonumber(job.quantity) or 1

      local duration = lib.callback.await('cdg-crafting:server:getJobDuration', false, recipeId, qty)
      if not duration then
        TriggerServerEvent('cdg-crafting:server:cancelQueueRefund')
        lib.notify({ type='error', description='Craft failed. Refunded.' })
        break
      end

      local okProgress = lib.progressBar({
        duration = duration,
        label = 'Crafting...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, mouse = false },
      })

      if not okProgress then
        -- Cancelled
        TriggerServerEvent('cdg-crafting:server:cancelQueueRefund')
        lib.notify({ type='error', description='Crafting cancelled. Refunded.' })
        break
      end

      local finished = lib.callback.await('cdg-crafting:server:finishJob', false, recipeId, qty)
      if not finished then
        TriggerServerEvent('cdg-crafting:server:cancelQueueRefund')
        lib.notify({ type='error', description='Craft failed. Refunded.' })
        break
      end
    end

    TriggerServerEvent('cdg-crafting:server:endSession')
    ClearPedTasks(ped)
    setFrozen(false)
    isCrafting = false
  end)
end)

RegisterNUICallback('refreshCounts', function(_, cb)
  if not currentBenchId then cb({ ok=false }) return end
  local counts = lib.callback.await('cdg-crafting:server:getCounts', false, currentBenchId)
  if not counts then cb({ ok=false }) return end
  cb({ ok=true, counts=counts })
end)

RegisterNetEvent('cdg-crafting:client:crafted', function(update)
  if not update then return end
  -- Keep it vague: do not reveal time/xp in UI, but we can still notify completion.
  lib.notify({ type='success', description = ('Craft completed x%d'):format(update.quantity or 1) })
end)

-- Hard control lock while UI open
CreateThread(function()
  while true do
    if not isOpen then
      Wait(300)
    else
      Wait(0)
      DisableControlAction(0, 1, true)
      DisableControlAction(0, 2, true)
      DisableControlAction(0, 24, true)
      DisableControlAction(0, 25, true)
      DisableControlAction(0, 30, true)
      DisableControlAction(0, 31, true)
      DisableControlAction(0, 36, true)
      DisableControlAction(0, 37, true)
      DisableControlAction(0, 44, true)
      DisableControlAction(0, 59, true)
      DisableControlAction(0, 60, true)

      -- ESC/BACKSPACE closes UI (unless crafting)
      if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 200) then
        if isCrafting then
          lib.notify({ type='error', description='You are crafting. Cancel to stop.' })
        else
          closeUi()
        end
      end
    end
  end
end)
