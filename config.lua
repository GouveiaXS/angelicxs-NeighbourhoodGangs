----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
-- Images are provided for new items if you choose to add them 		--
----------------------------------------------------------------------

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-NeighbourhoodGangs:CustomNotify')
AddEventHandler('angelicxs-NeighbourhoodGangs:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
    --exports['okokNotify']:Alert('', message, 4000, type, false)
end)

Config.NeighbourhoodGang ={
    ['ballas'] = {                                              -- Gang Name
        ['Active'] = false,                                     -- !!LEAVE THIS FALSE DO NOT TOUCH IT!!
        ['CenterLocation'] = vector3(1306.2, -552.78, 71.34), -- Center point of the gang's area
        ['ZoneColour'] = 1,                                     -- What colour the neighbourhood gang radius will be, if not wanted change value to FALSE
        ['ZoneRadius'] = 50,                                    -- How big the neighbourhood gang radius is REQUIRED for peds to wander in area, if FALSE peds will be stationary.
        ['ModelTypes'] = {                                      -- List of model types that a gang member may spawn as
            'g_f_y_ballas_01',
            'g_m_y_ballaeast_01',
            'g_m_y_ballaorig_01',
            'g_m_y_ballasout_01',
        },
        ['PedWeapons'] = {                                      -- List of weapons gang member may spawn with
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        ['Armour'] = 25,                                        -- How much armor the gang members will have
        ['RespawnTimer'] = 0.1,                                 -- Respawn timer in minutes
        ['MainLocations'] = {                                   -- Location of gang members
            vector4(1315.4, -562.24, 72.17, 63.34),
            vector4(1316.07, -555.82, 72.09, 3.64),
            vector4(1304.3, -542.47, 70.95, 69.85),
            vector4(1334.71, -565.02, 73.59, 80.59),
            vector4(1351.41, -567.36, 74.28, 66.56),
        },
    },
    ['lost'] = {                                                -- Gang Name
        ['Active'] = false,                                     -- !!LEAVE THIS FALSE DO NOT TOUCH IT!!
        ['ZoneColour'] = 5,                                     -- What colour the neighbourhood gang radius will be, if not wanted change value to FALSE
        ['ZoneRadius'] = 50,                                    -- How big the neighbourhood gang radius is REQUIRED for peds to wander in area, if FALSE peds will be stationary.
        ['CenterLocation'] = vector3(1250.96, -535.49, 68.86), -- Center point of the gang's area
        ['ModelTypes'] = {                                      -- List of model types that a gang member may spawn as
            'g_f_y_lost_01',
            'g_m_y_lost_01',
            'g_m_y_lost_02',
            'g_m_y_lost_03',
        },
        ['PedWeapons'] = {                                      -- List of weapons gang member may spawn with
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        ['Armour'] = 25,                                        -- How much armor the gang members will have
        ['RespawnTimer'] = 0.1,                                  -- Respawn timer in minutes
        ['MainLocations'] = {                                   -- Location of gang members
            vector4(1251.14, -526.61, 68.97, 247.0),
            vector4(1244.22, -558.72, 69.37, 201.75),
            vector4(1253.63, -556.3, 69.08, 302.25),
        },
    },
}
