lib.locale()

local function openContextMenu()
  lib.registerContext({
    id = 'dg_evidencelocker_menu',
    title = locale('menu_title'),
    options = {
      {
        title = locale('create_stash'),
        description = locale('create_stash_desc'),
        icon = 'fa-solid fa-folder-plus',
        onSelect = function()
          local input = lib.inputDialog(locale('create_stash'), { locale('input_stash_name') })
          if input and input[1] then
            TriggerServerEvent('dg_evidencelocker:create', input[1])
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
            TriggerServerEvent('dg_evidencelocker:search', input[1])
          end
        end
      },
      {
        title = locale('list_stashes'),
        description = locale('list_stashes_desc'),
        icon = 'fa-solid fa-list',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:showAll')
        end
      },
      {
        title = locale('clear_stash'),
        description = locale('clear_stash_desc'),
        icon = 'fa-solid fa-trash',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:clearMenu')
        end
      },
      {
        title = locale('delete_stash'),
        description = locale('delete_stash_desc'),
        icon = 'fa-solid fa-triangle-exclamation',
        onSelect = function()
          TriggerServerEvent('dg_evidencelocker:deleteMenu')
        end
      }      
    }
  })
  lib.showContext('dg_evidencelocker_menu')
end

RegisterNetEvent('dg_evidencelocker:openMenu')
AddEventHandler('dg_evidencelocker:openMenu', function(lockers)
  local options = {}

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('open_stash_desc') .. ' ' .. locker.name,
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:search', locker.name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_list',
    title = locale('select_stash'),
    description = locale('select_stash_desc'),
    options = options
  })
  lib.showContext('dg_evidencelocker_list')
end)

RegisterNetEvent('dg_evidencelocker:openClearMenu')
AddEventHandler('dg_evidencelocker:openClearMenu', function(lockers)
  local options = {}

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('clear_stash_desc') .. ' ' .. locker.name,
      icon = 'fa-solid fa-trash',
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:confirmClear', locker.stash_name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_clear',
    title = locale('clear_stash'),
    options = options
  })
  lib.showContext('dg_evidencelocker_clear')
end)

RegisterNetEvent('dg_evidencelocker:confirmClear')
AddEventHandler('dg_evidencelocker:confirmClear', function(stashName)
  local confirmed = lib.alertDialog({
    header = locale('clear_stash'),
    content = locale('confirm_clear_stash'),
    centered = true,
    cancel = true,
    size = 'md',
    labels = { cancel = locale('cancel'), confirm = locale('confirm') }
  })

  if confirmed == 'confirm' then
    TriggerServerEvent('dg_evidencelocker:clear', stashName)
  end
end)

RegisterNetEvent('dg_evidencelocker:openDeleteMenu')
AddEventHandler('dg_evidencelocker:openDeleteMenu', function(lockers)
  local options = {}

  for _, locker in ipairs(lockers) do
    table.insert(options, {
      title = locker.name,
      description = locale('delete_stash_desc') .. ' ' .. locker.name,
      icon = 'fa-solid fa-triangle-exclamation',
      onSelect = function()
        TriggerServerEvent('dg_evidencelocker:confirmDelete', locker.stash_name)
      end
    })
  end

  lib.registerContext({
    id = 'dg_evidencelocker_delete',
    title = locale('delete_stash'),
    options = options
  })
  lib.showContext('dg_evidencelocker_delete')
end)

RegisterNetEvent('dg_evidencelocker:confirmDelete')
AddEventHandler('dg_evidencelocker:confirmDelete', function(stashName)
  local confirmed = lib.alertDialog({
    header = locale('delete_stash'),
    content = locale('confirm_delete_stash'),
    centered = true,
    cancel = true,
    size = 'md',
    labels = { cancel = locale('cancel'), confirm = locale('confirm') }
  })

  if confirmed == 'confirm' then
    TriggerServerEvent('dg_evidencelocker:delete', stashName)
  end
end)

local function getPlayerJob()
  local player = exports.qbx_core:GetPlayerData()
  return player and player.job and player.job.name or nil
end

local stashZone = nil

local function createStashZone()
  if stashZone then return end

  stashZone = exports.ox_target:addBoxZone({
    coords = Config.StashLocation,
    size = vec3(1, 1, 1),
    rotation = 0,
    debug = false,
    options = {
      {
        label = locale('open_stash'),
        icon = 'fa-solid fa-archive',
        onSelect = function()
          openContextMenu()
        end,
        canInteract = function()
          local job = getPlayerJob()
          return job and Config.AllowedJobs[job] ~= nil
        end
      }
    }
  })
end

local function removeStashZone()
  if stashZone then
    exports.ox_target:removeZone(stashZone)
    stashZone = nil
  end
end

CreateThread(function()
  while true do
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - Config.StashLocation)

    if distance < 50 then
      createStashZone()
    else
      removeStashZone()
    end

    Wait(5000)
  end
end)
