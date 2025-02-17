Framework = nil
Framework = GetFramework()

pauseActive = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(650)
        local isMenuActive = IsPauseMenuActive()
        if isMenuActive ~= pauseActive then
            exports[GetCurrentResourceName()]:eyestore(not isMenuActive)
            pauseActive = isMenuActive
        end
    end
end)

exports('eyestore', function(state)
    SendNUIMessage({ data = 'EXIT', args = state })
end)


local lastUpdate = 0
local updateInterval = 200 
local cachedStats = {
    vitals = {
        health = 100,
        armor = 0,
        food = 0,
        water = 0,
        stamina = 0,
        oxygen = 100
    },
    status = {
        running = false,
        swimming = false,
        showStamina = false,
        showOxygen = false
    }
}

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    
    while not HasScaleformMovieLoaded(minimap) do
        Wait(0) 
    end

    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    
    while true do
        Wait(0)
        
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

local function shouldUpdate(newStats)
    DisplayRadar(true)
    local hasChanges = false
    
    for stat, value in pairs(newStats.vitals) do
        if math.abs((cachedStats.vitals[stat] or 0) - value) > 1 then
            hasChanges = true
            break
        end
    end
    
    for status, value in pairs(newStats.status) do
        if cachedStats.status[status] ~= value then
            hasChanges = true
            break
        end
    end
    
    return hasChanges
end

Citizen.CreateThread(function()
    while true do
        local now = GetGameTimer()
        if now - lastUpdate >= updateInterval then
            local playerPed = PlayerPedId()
            local playerId = PlayerId()
            local newStats = {
                vitals = {
                    health = math.floor(math.min(GetEntityHealth(playerPed) - 100, 100)),
                    armor = math.floor(math.min(GetPedArmour(playerPed), 100)),
                    stamina = math.ceil(100 - GetPlayerSprintStaminaRemaining(playerId)),
                    oxygen = math.ceil(GetPlayerUnderwaterTimeRemaining(playerId) * 10)
                },
                status = {
                    running = IsPedRunning(playerPed) or IsPedSprinting(playerPed),
                    swimming = IsPedSwimming(playerPed) or IsEntityInWater(playerPed) or IsPedSwimmingUnderWater(playerPed)
                }
            }
            if Framework then
                local PlayerData = Config.Framework == "QBCore" and Framework.Functions.GetPlayerData() or Framework.GetPlayerData()
                if PlayerData and PlayerData.metadata then
                    newStats.vitals.food = math.floor(math.min(PlayerData.metadata.hunger or 0, 100))
                    newStats.vitals.water = math.floor(math.min(PlayerData.metadata.thirst or 0, 100))
                end
            end
            newStats.status.showStamina = newStats.status.running or (newStats.vitals.stamina < 100)
            newStats.status.showOxygen = newStats.status.swimming or (newStats.vitals.oxygen < 100)
            if shouldUpdate(newStats) then
                SendNUIMessage({
                    type = 'UPDATE_STATS',
                    stats = newStats
                })
                cachedStats = newStats
            end
            lastUpdate = now
        end
        Citizen.Wait(updateInterval / 2) 
    end
end)

RegisterNetEvent('HudPlayerLoad')
AddEventHandler('HudPlayerLoad', function(playerInfo, serverInfo)
    SendNUIMessage({
        type = 'UPDATE_HUD',
        playerInfo = playerInfo,
        serverInfo = serverInfo
    })
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    SendNUIMessage({
        type = 'UPDATE_STATS',
        stats = {
            vitals = {
                food = math.floor(math.min(newHunger, 100)),
                water = math.floor(math.min(newThirst, 100))
            }
        }
    })
end)
