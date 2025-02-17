Config = {
    Framework = 'QBCore',  -- QBCore or ESX or OLDQBCore or NewESX
    ServerInfo = {
        Logo = "https://forum-cfx-re.akamaized.net/original/4X/3/3/c/33c8a46bd7dc62a1f44a6b492f6d854ae6e97822.png",
        Discord = "JOIN DISCORD"
    },
    Settings = {
        EnableHUD = true,              
        EnableNotifications = true,    
        Scale = {
            Enable = true,
            Size = 1.0,               
            MinSize = 0.5,            
            MaxSize = 2.0,            
            AffectIcons = true,       
            AffectText = true         
        },
        Bars = {
            Health = {
                Show = true,
                Color = '#ff3636',      
                GradientColor = '#ff0000'
            },
            Armor = {
                Show = true,
                HideEmpty = true,
                Color = '#1e90ff',      
                GradientColor = '#4169e1'
            },
            Food = {
                Show = true,
                Color = '#ffa500',      
                GradientColor = '#ff8c00'
            },
            Water = {
                Show = true,
                Color = '#00bfff',      
                GradientColor = '#1e90ff'
            },
            Stamina = {
                Show = true,
                Color = '#ffd700',      
                GradientColor = '#daa520'
            },
            Oxygen = {
                Show = true,
                Color = '#00ffff',      
                GradientColor = '#00ced1'
            }
        },
        DynamicBars = {
            StaminaOnlyWhenRunning = true,
            OxygenOnlyInWater = true
        },
        Design = {
            BlurEffect = true,
            Icons = {
                Show = true,
                Size = 'normal',
                Color = 'white'
            },
            Values = {
                Show = true,
                ShowPercent = true,
                Color = 'white'
            },
            Bars = {
                Height = 'normal',
                Rounded = true
            }
        }
    }
}

function GetFramework()
    local Get = nil
    if Config.Framework == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    end
    if Config.Framework == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    end
    if Config.Framework == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    end
    if Config.Framework == "OLDQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
end
