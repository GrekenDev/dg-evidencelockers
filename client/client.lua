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

local function getPlayerJob()
  local player = exports.qbx_core:GetPlayerData()
  return player and player.job and player.job.name or nil
end

exports.ox_target:addBoxZone({
  coords = Config.StashLocation,
  size = vec3(1, 1, 1),
  rotation = 0,
  debug = false,
  options = {
    {
      label = locale('open_stash'),
      icon = 'fa-solid fa-archive',
      action = function()
        openContextMenu()
      end,
      canInteract = function(entity, distance, data)
        local job = getPlayerJob()
        return job and Config.AllowedJobs[job] ~= nil
      end
    }
  }
})
