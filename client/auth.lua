local QBCore = exports['qb-core']:GetCoreObject()
local isLoggedIn = false
local currentUser = nil

-- Functions
local function ShowLoginUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showLogin'
    })
end

local function HideLoginUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideLogin'
    })
end

local function CheckUserAccount()
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:getUserAccount', function(user)
        if user then
            isLoggedIn = true
            currentUser = user
            -- User is already logged in, proceed to character selection
            TriggerEvent('qb-multicharacter:client:chooseChar')
        else
            -- User needs to login/register
            ShowLoginUI()
        end
    end)
end

-- Events
RegisterNetEvent('qb-multicharacter:client:showLogin', function()
    CheckUserAccount()
end)

RegisterNetEvent('qb-multicharacter:client:authResult', function(result)
    if result.action == 'loginResult' and result.success then
        isLoggedIn = true
        currentUser = result.userData
        HideLoginUI()
        -- Proceed to character selection
        TriggerEvent('qb-multicharacter:client:chooseChar')
    end
    
    -- Send result to NUI for display
    SendNUIMessage(result)
end)

-- NUI Callbacks
RegisterNUICallback('login', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:attemptLogin', data.email, data.password)
    cb('ok')
end)

RegisterNUICallback('register', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:attemptRegister', data.username, data.email, data.password)
    cb('ok')
end)

-- Exports
exports('IsLoggedIn', function()
    return isLoggedIn
end)

exports('GetCurrentUser', function()
    return currentUser
end)