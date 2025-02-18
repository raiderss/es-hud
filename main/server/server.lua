Framework = nil
Framework = GetFramework()
Citizen.Await(Framework)

local function GetPlayerInfo(xPlayer)
    if not xPlayer then return nil end
    
    local playerInfo = {
        id = tostring(xPlayer.source or xPlayer.PlayerData.source),
        job = "",
        grade = "",
        cash = "0",
        bank = "0"
    }

    if Config.Framework == "ESX" or Config.Framework == "NewESX" then
        playerInfo.job = xPlayer.getJob().name
        playerInfo.grade = xPlayer.getJob().grade_label
        playerInfo.cash = tostring(xPlayer.getMoney())
        playerInfo.bank = tostring(xPlayer.getAccount('bank').money)
    else
        playerInfo.job = xPlayer.PlayerData.job.name
        playerInfo.grade = xPlayer.PlayerData.job.grade.name
        playerInfo.cash = tostring(xPlayer.PlayerData.money['cash'])
        playerInfo.bank = tostring(xPlayer.PlayerData.money['bank'])
    end

    return playerInfo
end

Citizen.CreateThread(function()
        Citizen.Wait(500) 
        for _, playerId in pairs(GetPlayers()) do
            local Player = Config.Framework == "ESX" or Config.Framework == "NewESX" 
                and Framework.GetPlayerFromId 
                or Framework.Functions.GetPlayer

            local xPlayer = Player(tonumber(playerId))
            if xPlayer then
                local playerInfo = GetPlayerInfo(xPlayer)
                TriggerClientEvent('HudPlayerLoad', tonumber(playerId), playerInfo, Config.ServerInfo)
            end
        end
end)

if Config.Framework == "ESX" or Config.Framework == "NewESX" then
    RegisterServerEvent('esx:onAddAccountMoney')
    AddEventHandler('esx:onAddAccountMoney', function(source, account, money)
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            local playerInfo = GetPlayerInfo(xPlayer)
            if playerInfo then
                TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
            end
        end
    end)

    RegisterServerEvent('esx:onRemoveAccountMoney')
    AddEventHandler('esx:onRemoveAccountMoney', function(source, account, money)
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            local playerInfo = GetPlayerInfo(xPlayer)
            if playerInfo then
                TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
            end
        end
    end)

    RegisterServerEvent('esx:onAddInventoryItem')
    AddEventHandler('esx:onAddInventoryItem', function(source, item, count)
        if item == 'money' then
            local xPlayer = Framework.GetPlayerFromId(source)
            if xPlayer then
                local playerInfo = GetPlayerInfo(xPlayer)
                if playerInfo then
                    TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
                end
            end
        end
    end)
end

if Config.Framework == "QBCore" then
    RegisterServerEvent('QBCore:Server:OnMoneyChange')
    AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneytype, amount, type)
        local xPlayer = Framework.Functions.GetPlayer(source)
        if xPlayer then
            local playerInfo = GetPlayerInfo(xPlayer)
            if playerInfo then
                TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
            end
        end
    end)
end

RegisterServerEvent('QBCore:Server:OnJobUpdate')
AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    local xPlayer = Framework.Functions.GetPlayer(source)
    if xPlayer then
        local playerInfo = GetPlayerInfo(xPlayer)
        if playerInfo then
            TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
        end
    end
end)

RegisterServerEvent('esx:setJob')
AddEventHandler('esx:setJob', function(source, job)
    local xPlayer = Framework.GetPlayerFromId(source)
    if xPlayer then
        local playerInfo = GetPlayerInfo(xPlayer)
        if playerInfo then
            TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    local source = source
    Wait(1000) 
    local xPlayer = Framework.GetPlayerFromId(source)
    if xPlayer then
        local playerInfo = GetPlayerInfo(xPlayer)
        if playerInfo then
            TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
        end
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    Wait(1000) 
    local xPlayer = Framework.Functions.GetPlayer(source)
    if xPlayer then
        local playerInfo = GetPlayerInfo(xPlayer)
        if playerInfo then
            TriggerClientEvent('HudPlayerLoad', source, playerInfo, Config.ServerInfo)
        end
    end
end)
