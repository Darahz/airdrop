local function cRequestModel(hash)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end
    end
    if airdropConfig.Debug == true then print("Model requested",hash) end
end

RegisterNetEvent("airdrop:client:spawnchopper",function(spawnLocation,dropLocation)
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
    local parachuteOffset = vector3(0,0,1)
    
    -- Request all the models for the airdrop to happen
    cRequestModel(airdropConfig.Props.propParachute)
    cRequestModel(airdropConfig.Props.propCrate)
    cRequestModel(airdropConfig.PedConfig.pedtype)
    cRequestModel(airdropConfig.PedConfig.vehicle)

    local pedVehicle = CreateVehicle(airdropConfig.PedConfig.vehicle, spawnLocation.x, spawnLocation.y, spawnLocation.z, GetHeadingFromVector_2d(dropLocation.x, dropLocation.y), 1, 0)
    local pedDriver  = CreatePedInsideVehicle(pedVehicle, 3, airdropConfig.PedConfig.pedtype, -1, true, true)
    SetHeliBladesFullSpeed(pedVehicle)

    StartPlayerTeleport(PlayerId(), spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, false, true, true)

    while IsPlayerTeleportActive() do
        Citizen.Wait(0)
    end

    TaskVehicleDriveToCoord(pedDriver, pedVehicle, dropLocation, 100.00, 1, pedVehicle, 786468, 10.0, true)

    while GetDistanceBetweenCoords(dropLocation, GetEntityCoords(pedVehicle)) > 10.0 do
        Citizen.Wait(10)
    end

    Citizen.Wait(10000)

    local vehiclePosition = GetEntityCoords(pedVehicle)

    local obj  = CreateObject(airdropConfig.Props.propParachute, (vehiclePosition + parachuteOffset) - vector3(0,0,6), true, true, true)
    local obj2 = CreateObject(airdropConfig.Props.propCrate, vehiclePosition - vector3(0,0,6), true, true, true)
    FreezeEntityPosition(obj,true)
    FreezeEntityPosition(obj2,true)

    local tmpCoord = GetEntityCoords(obj2)
    while GetEntityHeightAboveGround(obj2) > 0.2 do    
        tmpCoord = GetEntityCoords(obj2)
        SetEntityCoords(obj, tmpCoord.x, tmpCoord.y, (tmpCoord.z + 3) - airdropConfig.Props.fallspeed, 0, 0, 0, false)
        SetEntityCoords(obj2, tmpCoord.x, tmpCoord.y, tmpCoord.z - airdropConfig.Props.fallspeed, 0, 0, 0, false)
        Citizen.Wait(10)
    end

    PlaceObjectOnGroundProperly(obj2)
    DeleteObject(obj)
    Citizen.Wait(10000)

    exports['qb-target']:AddTargetEntity(dropppedCrate.PropInf.Prop, {
		options = {
			{
				type = "client",
				event = "airdrop:client:picklock",
				icon = 'fas fa-box',
				label = 'Open',
			}
		},
		distance = 2.5
	})
    
    DeleteObject(obj)
    DeleteObject(obj2)
    DeleteObject(pedDriver)
    DeleteObject(pedVehicle)

end)

RegisterCommand("airdrop",function()
    TriggerServerEvent("airdrop:server:spawnchopper")
end)
