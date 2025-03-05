lib.locale()

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end

  MySQL.query('SELECT stash_name, name FROM police_lockers', {}, function(results)
    if results and #results > 0 then
      for _, stash in ipairs(results) do
        exports.ox_inventory:RegisterStash(stash.stash_name, stash.name, Config.StashSlots, Config.StashWeight, false)
      end
      print('^2[DG-EvidenceLockers] Loaded ' .. #results .. ' evidence lockers from database.^0')
    else
      print('^3[DG-EvidenceLockers] No evidence lockers found in database.^0')
    end
  end)
end)

local function generateStashName(name)
  local cleanedName = name:gsub("%s+", "_"):gsub("[^%w_]", ""):lower()
  return 'police_locker_' .. cleanedName
end

local function getPlayerJob(source)
  local player = exports.qbx_core:GetPlayer(source)
  if not player or not player.PlayerData then return nil end
  return player.PlayerData.job and player.PlayerData.job.name or nil
end

local playerCooldowns = {}

RegisterNetEvent('dg_evidencelocker:create')
AddEventHandler('dg_evidencelocker:create', function(name)
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  local stashName = generateStashName(name)

  if playerCooldowns[src] and (os.time() - playerCooldowns[src]) < 10 then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('stash_wait') })
    return
  end

  playerCooldowns[src] = os.time()

  if #stashName < 5 or #stashName > 50 then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('invalid_stash_name') })
    return
  end

  MySQL.scalar('SELECT stash_name FROM police_lockers WHERE stash_name = ?', { stashName }, function(result)
    if result then
      TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('stash_exists') })
    else
      MySQL.insert('INSERT INTO police_lockers (name, stash_name) VALUES (?, ?)', { name, stashName }, function()
        exports.ox_inventory:RegisterStash(stashName, name, Config.StashSlots, Config.StashWeight, false) -- Lägger till owner = false
        TriggerClientEvent('ox_lib:notify', src,
          { type = 'success', description = locale('stash_created') .. ' ' .. name })
      end)
    end
  end)
end)

RegisterNetEvent('dg_evidencelocker:search')
AddEventHandler('dg_evidencelocker:search', function(name)
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  local stashName = generateStashName(name)

  MySQL.scalar('SELECT stash_name FROM police_lockers WHERE stash_name = ?', { stashName }, function(result)
    if result then
      TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashName)
    else
      TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('stash_not_found') })
    end
  end)
end)

RegisterNetEvent('dg_evidencelocker:showAll')
AddEventHandler('dg_evidencelocker:showAll', function()
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  MySQL.query('SELECT name, stash_name FROM police_lockers', {}, function(results)
    if #results > 0 then
      TriggerClientEvent('dg_evidencelocker:openMenu', src, results)
    else
      TriggerClientEvent('ox_lib:notify', src, { type = 'info', description = locale('no_stashes') })
    end
  end)
end)

RegisterNetEvent('dg_evidencelocker:clearMenu')
AddEventHandler('dg_evidencelocker:clearMenu', function()
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  MySQL.query('SELECT name, stash_name FROM police_lockers', {}, function(results)
    if #results > 0 then
      TriggerClientEvent('dg_evidencelocker:openClearMenu', src, results)
    else
      TriggerClientEvent('ox_lib:notify', src, { type = 'info', description = locale('no_stashes') })
    end
  end)
end)

RegisterNetEvent('dg_evidencelocker:confirmClear')
AddEventHandler('dg_evidencelocker:confirmClear', function(stashName)
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  -- Skicka bekräftelse till klienten
  TriggerClientEvent('dg_evidencelocker:confirmClear', src, stashName)
end)

RegisterNetEvent('dg_evidencelocker:clear')
AddEventHandler('dg_evidencelocker:clear', function(stashName)
  local src = source
  local jobName = getPlayerJob(src)

  if not jobName or not Config.AllowedJobs[jobName] then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  exports.ox_inventory:ClearInventory(stashName)
  TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = locale('stash_cleared') })
end)
