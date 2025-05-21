lib.locale()


local function getPlayerJob()
  local player = exports.qbx_core:GetPlayerData()
  return player and player.job and player.job.name or nil
end

local function hasJob(jobs, playerJob)
  for _, job in ipairs(jobs) do
    if job == playerJob then return true end
  end
  return false
end


local function openContextMenu(lockerName)
  lib.registerContext({
    id = 'dg_evidencelocker_menu_' .. lockerName,
    title = locale('menu_title'),
    options = {
      {
        title = locale('create_stash'),
        description = locale('create_stash_desc'),
        icon = 'fa-solid fa-folder-plus',
        onSelect = function()
          local input = lib.inputDialog(locale('create_stash'), { locale('input_stash_name') })
          if input and input[1] then
            TriggerServerEvent('dg_evidencelocker:create', lockerName, input[1])
          end
        end
      },
      {
        title = locale('search_stash'),
        description = locale('search_stash_desc'),
        icon = 'fa-solid fa-search',
        onSelect = function()
          local input = lib.inputDialog(locale('search_stash'), { locale('input_stash_name') })
          if input and input[1] then
            TriggerServerEvent('dg_evidencelocker:search', lockerName, input[1])
          end
        end
      },
      {
        title = locale('list_stashes'),
        description = locale('list_stashes_desc'),
        icon = 'fa-solid fa-list',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:showAll', lockerName)
        end
      },
      {
        title = locale('clear_stash'),
        description = locale('clear_stash_desc'),
        icon = 'fa-solid fa-trash',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:clearMenu', lockerName)
        end
      },
      {
        title = locale('delete_stash'),
        description = locale('delete_stash_desc'),
        icon = 'fa-solid fa-triangle-exclamation',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:deleteMenu', lockerName)
        end
      }
    }
  })
  lib.showContext('dg_evidencelocker_menu_' .. lockerName)
end


RegisterNetEvent('dg_evidencelocker:openMenu', function(lockerName, lockers)
  local options = {
    {
      title = locale('back'),
      icon = 'fa-solid fa-arrow-left',
      onSelect = function() openContextMenu(lockerName) end
    }
  }

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('open_stash_desc') .. ' ' .. locker.name,
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:search', lockerName, locker.name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_list_' .. lockerName,
    title = locale('select_stash'),
    description = locale('select_stash_desc'),
    options = options
  })
  lib.showContext('dg_evidencelocker_list_' .. lockerName)
end)


RegisterNetEvent('dg_evidencelocker:openClearMenu', function(lockerName, lockers)
  local options = {
    {
      title = locale('back'),
      icon = 'fa-solid fa-arrow-left',
      onSelect = function() openContextMenu(lockerName) end
    }
  }

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('clear_stash_desc') .. ' ' .. locker.name,
      icon = 'fa-solid fa-trash',
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:confirmClear', lockerName, locker.stash_name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_clear_' .. lockerName,
    title = locale('clear_stash'),
    options = options
  })
  lib.showContext('dg_evidencelocker_clear_' .. lockerName)
end)

RegisterNetEvent('dg_evidencelocker:confirmClear', function(lockerName, stashName)
  local confirmed = lib.alertDialog({
    header = locale('clear_stash'),
    content = locale('confirm_clear_stash'),
    centered = true,
    cancel = true,
    size = 'md',
    labels = { cancel = locale('cancel'), confirm = locale('confirm') }
  })

  if confirmed == 'confirm' then
    TriggerServerEvent('dg_evidencelocker:clear', lockerName, stashName)
  end
end)


RegisterNetEvent('dg_evidencelocker:openDeleteMenu', function(lockerName, lockers)
  local options = {
    {
      title = locale('back'),
      icon = 'fa-solid fa-arrow-left',
      onSelect = function() openContextMenu(lockerName) end
    }
  }

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('delete_stash_desc') .. ' ' .. locker.name,
      icon = 'fa-solid fa-triangle-exclamation',
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:confirmDelete', lockerName, locker.stash_name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_delete_' .. lockerName,
    title = locale('delete_stash'),
    options = options
  })
  lib.showContext('dg_evidencelocker_delete_' .. lockerName)
end)

RegisterNetEvent('dg_evidencelocker:confirmDelete', function(lockerName, stashName)
  local confirmed = lib.alertDialog({
    header = locale('delete_stash'),
    content = locale('confirm_delete_stash'),
    centered = true,
    cancel = true,
    size = 'md',
    labels = { cancel = locale('cancel'), confirm = locale('confirm') }
  })

  if confirmed == 'confirm' then
    TriggerServerEvent('dg_evidencelocker:delete', lockerName, stashName)
  end
end)


local stashZones = {}

local function createStashZones()
  for name, locker in pairs(Config.EvidenceLockers) do
    if not stashZones[name] then
      if Config.Interact == "ox_target" then
        stashZones[name] = exports.ox_target:addBoxZone({
          coords = locker.coords,
          size = vec3(1, 1, 1),
          rotation = 0,
          debug = false,
          options = {
            {
              label = locale('open_stash'),
              icon = 'fa-solid fa-archive',
              onSelect = function()
                openContextMenu(name)
              end,
              canInteract = function()
                local job = getPlayerJob()
                return job and hasJob(locker.jobs, job)
              end
            }
          }
        })
      elseif Config.Interact == "sleepless" or Config.Interact == "sleepless_interact" then
        stashZones[name] = exports['sleepless_interact']:addCoords({
          coords = locker.coords,
          length = 1.0,
          width = 1.0,
          heading = 0.0,
          minZ = locker.coords.z - 1.0,
          maxZ = locker.coords.z + 1.0,
          debug = false,
          options = {
            {
              label = locale('open_stash'),
              icon = 'fa-solid fa-archive',
              action = function()
                openContextMenu(name)
              end,
              canInteract = function()
                local job = getPlayerJob()
                return job and hasJob(locker.jobs, job)
              end
            }
          }
        })
      end
    end
  end
end

local function removeStashZones()
  for name, zone in pairs(stashZones) do
    if Config.Interact == "ox_target" then
      exports.ox_target:removeZone(zone)
    elseif Config.Interact == "sleepless" then
      exports['sleepless_interact']:removeCoords(zone)
    end
    stashZones[name] = nil
  end
end

CreateThread(function()
  while true do
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearby = false
    for name, locker in pairs(Config.EvidenceLockers) do
      if #(playerCoords - locker.coords) < 50 then
        nearby = true
        break
      end
    end

    if nearby then
      createStashZones()
    else
      removeStashZones()
    end

    Wait(5000)
  end
end)