lib.locale()

local function Notify(data)
    if Config.Notify == "ox" then
        lib.notify({
            type = data.type or 'info',
            icon = data.icon or Config.NotifyIcon or 'fa-solid fa-archive',
            title = data.title or Config.NotifyTitle or 'Evidence Locker',
            description = data.description,
            position = Config.NotifyPosition,
            duration = Config.NotifyDuration
        })
    elseif Config.Notify == "okok" then
        exports['okokNotify']:Alert(data.title or Config.NotifyTitle or 'Evidence Locker', data.description, Config.NotifyDuration, data.type or 'info')
    elseif Config.Notify == "lation" then
        exports.lation_ui:notify({
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

-- Wrappers for Ox or Lation UI
local function AlertDialog(data)
    if Config.UseLationUi then
        return exports.lation_ui:alert({
            header = data.header,
            content = data.content,
            icon = data.icon or 'fas fa-circle-exclamation',
            iconColor = '#EF4444',
            type = 'destructive',
            labels = {
                cancel = locale('cancel'),
                confirm = locale('confirm')
            }
        })
    else
        return lib.alertDialog({
            header = data.header,
            content = data.content,
            centered = true,
            cancel = true,
            size = 'md',
            labels = {
                cancel = locale('cancel'),
                confirm = locale('confirm')
            }
        })
    end
end

local function InputDialog(title, label)
    if Config.UseLationUi then
        local result = exports.lation_ui:input({
            title = title,
            subtitle = label,
            submitText = locale('submitText') or "Bekräfta",
            options = {
                {
                    type = 'input',
                    label = label,
                    description = '',
                    placeholder = '',
                    icon = 'fas fa-pen',
                    required = true
                }
            }
        })
        if result then return { result[1] } end
    else
        return lib.inputDialog(title, { label })
    end
end

local function ShowContextMenu(id, title, description, options)
    if Config.UseLationUi then
        exports.lation_ui:registerMenu({
            id = id,
            title = title,
            subtitle = description or '',
            onExit = function() end,
            options = options
        })
        exports.lation_ui:showMenu(id)
    else
        lib.registerContext({ id = id, title = title, description = description, options = options })
        lib.showContext(id)
    end
end

-- Job utilities
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

-- Main Menu
local function openContextMenu(lockerName)
    ShowContextMenu('dg_evidencelocker_menu_' .. lockerName, locale('menu_title'), nil, {
        {
            title = locale('create_stash'),
            description = locale('create_stash_desc'),
            icon = 'fas fa-folder-plus',
            onSelect = function()
                local input = InputDialog(locale('create_stash'), locale('input_stash_name'))
                if input and input[1] then
                    TriggerServerEvent('dg_evidencelocker:create', lockerName, input[1])
                end
            end
        },
        {
            title = locale('search_stash'),
            description = locale('search_stash_desc'),
            icon = 'fas fa-search',
            onSelect = function()
                local input = InputDialog(locale('search_stash'), locale('input_stash_name'))
                if input and input[1] then
                    TriggerServerEvent('dg_evidencelocker:search', lockerName, input[1])
                end
            end
        },
        {
            title = locale('list_stashes'),
            description = locale('list_stashes_desc'),
            icon = 'fas fa-list',
            onSelect = function()
                TriggerServerEvent('dg_evidencelocker:showAll', lockerName)
            end
        },
        {
            title = locale('clear_stash'),
            description = locale('clear_stash_desc'),
            icon = 'fas fa-trash',
            onSelect = function()
                TriggerServerEvent('dg_evidencelocker:clearMenu', lockerName)
            end
        },
        {
            title = locale('delete_stash'),
            description = locale('delete_stash_desc'),
            icon = 'fas fa-triangle-exclamation',
            onSelect = function()
                TriggerServerEvent('dg_evidencelocker:deleteMenu', lockerName)
            end
        }
    })
end

-- All other menus use ShowContextMenu similarly
-- openMenu
RegisterNetEvent('dg_evidencelocker:openMenu', function(lockerName, lockers)
    local options = {
        {
            title = locale('back'),
            icon = 'fas fa-arrow-left',
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
    ShowContextMenu('dg_evidencelocker_list_' .. lockerName, locale('select_stash'), locale('select_stash_desc'), options)
end)

RegisterNetEvent('dg_evidencelocker:openClearMenu', function(lockerName, lockers)
    local options = {
        {
            title = locale('back'),
            icon = 'fas fa-arrow-left',
            onSelect = function() openContextMenu(lockerName) end
        }
    }
    for _, locker in ipairs(lockers) do
        table.insert(options, {
            title = locker.name,
            description = locale('clear_stash_desc') .. ' ' .. locker.name,
            icon = 'fas fa-trash',
            onSelect = function()
                TriggerServerEvent('dg_evidencelocker:confirmClear', lockerName, locker.stash_name)
            end
        })
    end
    ShowContextMenu('dg_evidencelocker_clear_' .. lockerName, locale('clear_stash'), nil, options)
end)

RegisterNetEvent('dg_evidencelocker:confirmClear', function(lockerName, stashName)
    local confirmed = AlertDialog({
        header = locale('clear_stash'),
        content = locale('confirm_clear_stash')
    })
    if confirmed == 'confirm' then
        TriggerServerEvent('dg_evidencelocker:clear', lockerName, stashName)
    end
end)

RegisterNetEvent('dg_evidencelocker:openDeleteMenu', function(lockerName, lockers)
    local options = {
        {
            title = locale('back'),
            icon = 'fas fa-arrow-left',
            onSelect = function() openContextMenu(lockerName) end
        }
    }
    for _, locker in ipairs(lockers) do
        table.insert(options, {
            title = locker.name,
            description = locale('delete_stash_desc') .. ' ' .. locker.name,
            icon = 'fas fa-triangle-exclamation',
            onSelect = function()
                TriggerServerEvent('dg_evidencelocker:confirmDelete', lockerName, locker.stash_name)
            end
        })
    end
    ShowContextMenu('dg_evidencelocker_delete_' .. lockerName, locale('delete_stash'), nil, options)
end)

RegisterNetEvent('dg_evidencelocker:confirmDelete', function(lockerName, stashName)
    local confirmed = AlertDialog({
        header = locale('delete_stash'),
        content = locale('confirm_delete_stash')
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
                            icon = Config.NotifyIcon or 'fa-solid fa-archive',
                            onSelect = function()
                                local job = getPlayerJob()
                                if job and hasJob(locker.jobs, job) then
                                    openContextMenu(name)
                                else
                                    Notify({
                                        type = 'error',
                                        title = Config.NotifyTitle or 'Evidence Locker',
                                        description = locale('no_access_job'),
                                        icon = Config.NotifyIcon or 'fa-solid fa-archive'
                                    })
                                end
                            end,
                            canInteract = function()
                                local job = getPlayerJob()
                                return job and hasJob(locker.jobs, job)
                            end
                        }
                    }
                })
            elseif Config.Interact == "sleepless" or Config.Interact == "sleepless_interact" then
                stashZones[name] = exports['sleepless_interact']:addCoords(
                    locker.coords,
                    {
                        label = locale('open_stash'),
                        icon = Config.NotifyIcon or 'fa-solid fa-archive',
                        distance = 2.0,
                        onSelect = function(data)
                            local job = getPlayerJob()
                            if job and hasJob(locker.jobs, job) then
                                openContextMenu(name)
                            else
                                Notify({
                                    type = 'error',
                                    title = Config.NotifyTitle or 'Evidence Locker',
                                    description = locale('no_access_job'),
                                    icon = Config.NotifyIcon or 'fa-solid fa-archive'
                                })
                            end
                        end,
                        canInteract = function(entity, distance, coords, zoneName)
                            local job = getPlayerJob()
                            return job and type(locker.jobs) == "table" and hasJob(locker.jobs, job)
                        end
                    }
                )
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

RegisterNetEvent('dg_evidencelocker:clientNotify', function(data)
    exports.lation_ui:notify({
        title = data.title,
        message = data.message,
        type = data.type,
        icon = data.icon,
        iconColor = data.iconColor,
        bgColor = data.bgColor,
        txtColor = data.txtColor
    })
end)
