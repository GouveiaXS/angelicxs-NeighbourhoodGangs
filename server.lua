ESX = nil
QBcore = nil
local PlayersAvailable = {}

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

for k,v in pairs(Config.NeighbourhoodGang) do
    PlayersAvailable[k] = {}
end

RegisterNetEvent('angelicxs-NeighbourHoodGangs:Server:ActivityUpdater', function(gang, active)
    if not gang then return end
    if active then
        Config.NeighbourhoodGang[gang]['Active'] = true
        TriggerClientEvent('angelicxs-NeighbourHoodGangs:Client:ActivityUpdater', -1, gang, active)
        PlayersAvailable[gang][source] = true
    else
        PlayersAvailable[gang][source] = false
    end
end)

CreateThread(function()
    Wait(5000)
    while true do 
        for gang, source in pairs(PlayersAvailable) do
        local inzone = 0
            for id, active in pairs(source) do
                if active then inzone = inzone + 1 end
            end
            if inzone == 0 then
                Config.NeighbourhoodGang[gang]['Active'] = false
                TriggerClientEvent('angelicxs-NeighbourHoodGangs:Client:ActivityUpdater', -1, gang, false)
            end
        end
        Wait(5000)
    end
end)

RegisterNetEvent('angelicxs-NeighbourHoodGangs:Server:RelationshipUpdater', function(gang, net)
    TriggerClientEvent('angelicxs-NeighbourHoodGangs:Client:RelationshipUpdater', -1, gang, net)
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        PlayersAvailable = {}
        TriggerClientEvent('angelicxs-NeighbourHoodGangs:Client:ActivityUpdater', -1, gang, false)
    end
end)