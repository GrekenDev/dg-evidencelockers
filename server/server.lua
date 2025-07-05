lib.locale()


local function Notify(source, data)
    if Config.Notify == "ox" then
        TriggerClientEvent('ox_lib:notify', source, {
            type = data.type or 'info',
            description = data.description,
            position = Config.NotifyPosition,
            duration = Config.NotifyDuration
        })
    elseif Config.Notify == "okok" then
        TriggerClientEvent('okokNotify:Alert', source,
            data.title or Config.NotifyTitle or 'Evidence Locker',
            data.description,
            Config.NotifyDuration,
            data.type or 'info',
            false
        )
    elseif Config.Notify == "lation" then
        TriggerClientEvent('dg_evidencelocker:clientNotify', source, {
            title = data.title or Config.NotifyTitle or 'Evidence Locker',
            message = data.description or '',
            type = data.type or 'info',
            icon = data.icon,
            iconColor = data.iconColor,
            bgColor = data.bgColor,
            txtColor = data.txtColor
        })
    end
end

CreateThread(function()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local repo = 'GrekenDev/dg-evidencelockers'
    print('^2[DG-EvidenceLockers] Checking version: Current = ' .. (currentVersion or 'nil') .. '^0')
    lib.checkDependency(repo, currentVersion, function(data)
        if not data then
            print('^1[DG-EvidenceLockers] Version check failed. Could not reach version server.^0')
            return
        end
        print('^2[DG-EvidenceLockers] Version data received: ' .. json.encode(data) .. '^0')
        local latestVersion = data.version
        if latestVersion ~= currentVersion then
            print('^3[DG-EvidenceLockers] A new version is available: ^2' .. latestVersion .. '^3 (You are running: ^1' .. currentVersion .. '^3)')
            print('^3Download the latest version here: https://github.com/GrekenDev/dg-evidencelockers^0')
        else
            print('^2[DG-EvidenceLockers] You are running the latest version (' .. currentVersion .. ').^0')
        end
    end)
    Wait(0)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    MySQL.query('SELECT stash_name, name, locker FROM police_lockers', {}, function(results)
        if results and #results > 0 then
            for _, stash in ipairs(results) do
                local locker = Config.EvidenceLockers[stash.locker]
                local slots = locker and locker.stashSlots or 20
                local weight = locker and locker.stashWeight or 500000
                exports.ox_inventory:RegisterStash(stash.stash_name, stash.name, slots, weight, false)
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

local function getPlayerJobAndGrade(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player or not player.PlayerData then return nil, 0 end
    local job = player.PlayerData.job and player.PlayerData.job.name or nil
    local grade = player.PlayerData.job and (player.PlayerData.job.grade.level or player.PlayerData.job.grade) or 0
    return job, grade
end

local function hasJob(jobs, playerJob)
    for _, job in ipairs(jobs) do
        if job == playerJob then return true end
    end
    return false
end

local playerCooldowns = {}

RegisterNetEvent('dg_evidencelocker:create')
AddEventHandler('dg_evidencelocker:create', function(lockerName, name)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end

    local stashName = generateStashName(name)

    if playerCooldowns[src] and (os.time() - playerCooldowns[src]) < 10 then
        Notify(src, { type = 'error', description = locale('stash_wait') })
        return
    end

    playerCooldowns[src] = os.time()

    if #stashName < 5 or #stashName > 50 then
        Notify(src, { type = 'error', description = locale('invalid_stash_name') })
        return
    end

    MySQL.scalar('SELECT stash_name FROM police_lockers WHERE stash_name = ?', { stashName }, function(result)
        if result then
            Notify(src, { type = 'error', description = locale('stash_exists') })
        else
            MySQL.insert('INSERT INTO police_lockers (name, stash_name, locker) VALUES (?, ?, ?)', { name, stashName, lockerName }, function()
                exports.ox_inventory:RegisterStash(stashName, name, locker.stashSlots, locker.stashWeight, false)
                Notify(src, { type = 'success', description = locale('stash_created') .. ' ' .. name })
            end)
        end
    end)
end)

RegisterNetEvent('dg_evidencelocker:search')
AddEventHandler('dg_evidencelocker:search', function(lockerName, name)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end

    local stashName = generateStashName(name)

    MySQL.scalar('SELECT stash_name FROM police_lockers WHERE stash_name = ? AND locker = ?', { stashName, lockerName }, function(result)
        if result then
            TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashName)
        else
            Notify(src, { type = 'error', description = locale('stash_not_found') })
        end
    end)
end)

RegisterNetEvent('dg_evidencelocker:showAll')
AddEventHandler('dg_evidencelocker:showAll', function(lockerName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end

    MySQL.query('SELECT name, stash_name FROM police_lockers WHERE locker = ?', { lockerName }, function(results)
        if #results > 0 then
            TriggerClientEvent('dg_evidencelocker:openMenu', src, lockerName, results)
        else
            Notify(src, { type = 'info', description = locale('no_stashes') })
        end
    end)
end)

RegisterNetEvent('dg_evidencelocker:clearMenu')
AddEventHandler('dg_evidencelocker:clearMenu', function(lockerName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.clearRank then
        Notify(src, { type = 'error', description = locale('no_access_clear') })
        return
    end

    MySQL.query('SELECT name, stash_name FROM police_lockers WHERE locker = ?', { lockerName }, function(results)
        if #results > 0 then
            TriggerClientEvent('dg_evidencelocker:openClearMenu', src, lockerName, results)
        else
            Notify(src, { type = 'info', description = locale('no_stashes') })
        end
    end)
end)

RegisterNetEvent('dg_evidencelocker:confirmClear')
AddEventHandler('dg_evidencelocker:confirmClear', function(lockerName, stashName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.clearRank then
        Notify(src, { type = 'error', description = locale('no_access_clear') })
        return
    end

    TriggerClientEvent('dg_evidencelocker:confirmClear', src, lockerName, stashName)
end)

RegisterNetEvent('dg_evidencelocker:clear')
AddEventHandler('dg_evidencelocker:clear', function(lockerName, stashName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.clearRank then
        Notify(src, { type = 'error', description = locale('no_access_clear') })
        return
    end

    exports.ox_inventory:ClearInventory(stashName)
    Notify(src, { type = 'success', description = locale('stash_cleared') })
end)

RegisterNetEvent('dg_evidencelocker:deleteMenu')
AddEventHandler('dg_evidencelocker:deleteMenu', function(lockerName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.deleteRank then
        Notify(src, { type = 'error', description = locale('no_access_delete') })
        return
    end

    MySQL.query('SELECT name, stash_name FROM police_lockers WHERE locker = ?', { lockerName }, function(results)
        if #results > 0 then
            TriggerClientEvent('dg_evidencelocker:openDeleteMenu', src, lockerName, results)
        else
            Notify(src, { type = 'info', description = locale('no_stashes') })
        end
    end)
end)

RegisterNetEvent('dg_evidencelocker:confirmDelete')
AddEventHandler('dg_evidencelocker:confirmDelete', function(lockerName, stashName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]
    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.deleteRank then
        Notify(src, { type = 'error', description = locale('no_access_delete') })
        return
    end

    TriggerClientEvent('dg_evidencelocker:confirmDelete', src, lockerName, stashName)
end)

RegisterNetEvent('dg_evidencelocker:delete')
AddEventHandler('dg_evidencelocker:delete', function(lockerName, stashName)
    local src = source
    local job, grade = getPlayerJobAndGrade(src)
    local locker = Config.EvidenceLockers[lockerName]

    if not locker or not hasJob(locker.jobs, job) then
        Notify(src, { type = 'error', description = locale('no_access_job') })
        return
    end
    if grade < locker.deleteRank then
        Notify(src, { type = 'error', description = locale('no_access_delete') })
        return
    end

    local exists = MySQL.scalar.await('SELECT stash_name FROM police_lockers WHERE stash_name = ? AND locker = ?', { stashName, lockerName })
    if not exists then
        Notify(src, { type = 'error', description = locale('stash_not_found') })
        return
    end

    MySQL.execute('DELETE FROM police_lockers WHERE stash_name = ? AND locker = ?', { stashName, lockerName })

    if Config.UseBbInv then

        MySQL.execute('DELETE FROM bb_containers WHERE name = ?', { stashName })
    else
        exports.ox_inventory:ClearInventory(stashName)
    end

    Notify(src, { type = 'success', description = locale('stash_deleted') })
end)


