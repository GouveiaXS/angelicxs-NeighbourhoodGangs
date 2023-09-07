ESX = nil
QBcore = nil
PlayerGang = nil

Relationships = {}
garbage = nil
local Gangspawns = {}

RegisterNetEvent('angelicxs-NeighbourhoodGangs:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-NeighbourhoodGangs:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    
    garbage, Relationships['none'] = AddRelationshipGroup(GetHashKey('none'))
    for k,v in pairs(Config.NeighbourhoodGang) do
        if v['ZoneColour'] then
            SetBlip(v)
        end
        local name = GetHashKey(k)
        garbage, Relationships[k] = AddRelationshipGroup(name)
        SetRelationshipBetweenGroups(0, Relationships[k], Relationships[k])
        SetRelationshipBetweenGroups(3, Relationships[k], Relationships['none'])
        SetRelationshipBetweenGroups(3, Relationships['none'], Relationships[k])
    end
    for k,v in pairs(Config.NeighbourhoodGang) do
        local name = Relationships[k]
        for g, rival in pairs(Config.NeighbourhoodGang) do
            local name2 = Relationships[g]
            if name2 ~= name then
                SetRelationshipBetweenGroups(5, name, name2)
                SetRelationshipBetweenGroups(5, name2, name)
            end
        end
    end

    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	    while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        CreateThread(function()
            while true do
                local playerData = ESX.GetPlayerData()
                if playerData.job.name ~= nil then
                    PlayerGang = playerData.job.name
                    if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
                    else
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
                    end
                    break
                end
                Wait(100)
            end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerGang = job.name
            if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
            else
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
            end
        end)

    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerGang = playerData.gang.name
                    if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
                    else
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
                    end
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            local playerData = QBCore.Functions.GetPlayerData()
            PlayerGang = playerData.gang.name
            if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
            else
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
            end
        end)
    end
end)

CreateThread(function()
    while true do
        local loc = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.NeighbourhoodGang) do
            if #(v['CenterLocation']-loc) <= (tonumber(v['ZoneRadius']*2)) then
                if not v['Active'] then  
                    TriggerServerEvent('angelicxs-NeighbourHoodGangs:Server:ActivityUpdater', k, true)
                    Config.NeighbourhoodGang[k]['Active'] = true
                    GangSpawner(k)
                end
                TriggerServerEvent('angelicxs-NeighbourHoodGangs:Server:ActivityUpdater', k, true)
            else
                TriggerServerEvent('angelicxs-NeighbourHoodGangs:Server:ActivityUpdater', k, false)
            end
        end
        Wait(5000)
    end
end)

RegisterNetEvent('angelicxs-NeighbourHoodGangs:Client:ActivityUpdater', function(gang, active)
    if not gang then return end
    if active then
        Config.NeighbourhoodGang[gang]['Active'] = true
    else
        Config.NeighbourhoodGang[gang]['Active'] = false
        for key,spawns in pairs(Gangspawns) do
            if key == gang then
                for slot, entity in pairs(spawns) do
                    if DoesEntityExist(entity) then
                        DeleteEntity(entity)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('angelicxs-NeighbourHoodGangs:Client:RelationshipUpdater', function(gang, net)
    local spawn = NetworkGetEntityFromNetworkId(net)
    if not spawn then return end
    if DoesEntityExist(spawn) then
        SetPedRelationshipGroupHash(spawn, GetHashKey(Relationships[gang]))
    end
end)

function GangSpawner(k)
    Gangspawns[k] = {}
    for i = 1, #Config.NeighbourhoodGang[k]['MainLocations'] do
        local center = Config.NeighbourhoodGang[k]['CenterLocation']
        local rad = Config.NeighbourhoodGang[k]['ZoneRadius']
        local spot = Config.NeighbourhoodGang[k]['MainLocations'][i]
        local model = Randomizer(Config.NeighbourhoodGang[k]['ModelTypes'])
        local armour = Config.NeighbourhoodGang[k]['Armour']
        local weapon = Randomizer(Config.NeighbourhoodGang[k]['PedWeapons'])
        local hash = HashGrabber(model)
        Gangspawns[k][i] = CreatePed(4, hash, spot.x, spot.y, spot.z-0.9, spot.w, true, true)
        local spawn = GangAttributesRoamer(Gangspawns[k][i], armour, weapon, k, center, rad)
        while not spawn do Wait(100) end
        CreateThread(function()
            while GetEntityHeightAboveGround(Gangspawns[k][i]) == 0 do Wait(100) end
            while Config.NeighbourhoodGang[k]['Active'] do 
                if GetEntityHealth(Gangspawns[k][i]) <= 5 then
                    Gangspawns[k][i] = CreatePed(4, hash, spot.x, spot.y, spot.z, spot.w, true, true)
                    GangAttributesRoamer(Gangspawns[k][i], armour, weapon, k, center, rad)
                    SetPedArmour(Gangspawns[k][i], armour)
                    Wait(Config.NeighbourhoodGang[k]['RespawnTimer'])
                end
                Wait(5000)
            end
            SetModelAsNoLongerNeeded(model)
        end)
    end
end

function GangAttributesRoamer(entity, armour, weapon, gang, center, rad)
    while not DoesEntityExist(entity) do Wait(50) end
    SetEntityAsMissionEntity(entity, true, true)
    NetworkRegisterEntityAsNetworked(entity)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(entity), true)
    SetPedRelationshipGroupHash(entity, Relationships[gang])
    TriggerServerEvent('angelicxs-NeighbourHoodGangs:Server:RelationshipUpdater', gang, NetworkGetNetworkIdFromEntity(entity))
    SetPedArmour(entity, armour)
    GiveWeaponToPed(entity, weapon, 500)
    SetPedFleeAttributes(entity, 0, false)
    SetPedCombatAttributes(entity, 0, true)
    SetPedCombatAttributes(entity, 1, true)
    SetPedCombatAttributes(entity, 2, true)
    SetPedCombatAttributes(entity, 3, true)
    SetPedCombatAttributes(entity, 5, true)
    SetPedCombatAttributes(entity, 46, true)
    SetPedCombatAbility(entity, math.random(0,2)) -- best 2
    SetPedCombatMovement(entity, math.random(0,3)) -- best 1 (defence), best 2 (offence)
    SetPedAccuracy(entity, math.random(75,100)) -- best 100
    SetPedCombatRange(entity, math.random(0,2)) -- best 2
    SetEntityVisible(entity, true) 
    if rad then
        TaskWanderInArea(entity, center.x, center.y, center.z, rad, 10, 10.0) -- Wander at least 20m, waits at least 10 secs before moving to next spot
    end
    return true
end

function Randomizer(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

function SetBlip(data)
    local loc = data['CenterLocation']
    local p = AddBlipForRadius(loc.x, loc.y, loc.z, data['ZoneRadius']+0.01)
    SetBlipHighDetail(p, true)
    SetBlipColour(p, data['ZoneColour'])
    SetBlipAlpha(p, 160)
    SetBlipAsShortRange(p, true)
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        RemoveRelationshipGroup(GetHashKey('none'))
        for i = 1, #Config.NeighbourhoodGang do
            RemoveRelationshipGroup(GetHashKey(Config.NeighbourhoodGang[i]))
        end
        for gang,spawns in pairs(Gangspawns) do
            for slot, entity in pairs(spawns) do
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end
            end
        end
    end
end)