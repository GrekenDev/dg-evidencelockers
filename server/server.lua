lib.locale()

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

  if not jobName then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  if not Config.AllowedJobs[jobName] then
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
        exports.ox_inventory:RegisterStash(stashName, name, Config.StashSlots, Config.StashWeight)
        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = locale('stash_created') .. ' ' .. name })
      end)
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

  if not jobName then
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('no_access') })
    return
  end

  if not Config.AllowedJobs[jobName] then
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
        exports.ox_inventory:RegisterStash(stashName, name, Config.StashSlots, Config.StashWeight)
        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = locale('stash_created') .. ' ' .. name })
      end)
    end
  end)
end)
