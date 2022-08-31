QBCore = exports['qb-core']:GetCoreObject()
local CrateHacked = false
local hackCountdown    = airdropConfig.Props.hacktime;

local function cRequestModel(hash)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end
    end
    if airdropConfig.Debug == true then print("Model requested",hash) end
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function CreateFlareOnProp(Prop)
    UseParticleFxAssetNextCall("core")
    SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
    StartParticleFxLoopedOnEntity('proj_flare_trail', Prop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
end

-- Yoink qbcore -> client -> Events
-- Yoink : An exclamation that, when uttered in conjunction with taking an object,
-- immediately transfers ownership from the original owner to the person using the word.

local function Draw3DText(coords, str)
    local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoord()
    local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
    if onScreen then
        SetTextScale(1.0, 0.5 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextProportional(1)
        SetTextOutline()
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(worldX, worldY)
    end
end

local function SpawnMerryWeatherSolider(baseLocation)
    local spawnLocaton = baseLocation + vector3(math.random(-100,100),math.random(-100,100),0)
    local ped          = CreatePed(4, airdropConfig.PedConfig.pedtype, spawnLocaton.x, spawnLocaton.y, spawnLocaton.z, 0.0, true, true)
    print("spawning ped : " , spawnLocaton)
    GiveWeaponToPed(ped, GetHashKey(airdropConfig.PedConfig.weapons[math.random(#airdropConfig.PedConfig.weapons)]), 60, false, true)

    PlaceObjectOnGroundProperly(ped)

    TaskCombatHatedTargetsInArea(ped,baseLocation.x, baseLocation.y, baseLocation.z, 100.0,true)
    TaskGoToCoordAnyMeans(ped, baseLocation.x, baseLocation.y, baseLocation.z, 5.0, 0, 0, 786603, 0xbf800000)
    TaskCombatPed(ped, GetPlayerPed(-1), 0, 16)
    SetPedShootRate(ped, 200)
    SetPedAccuracy(ped, 100)
    SetEntityHealth(ped, 200)
    SetPedPathAvoidFire(ped, 1)
    SetPedCombatAttributes(ped, 46, true)
end

local function DisplayHackCountdown(laptopProp)
    local coord  = GetEntityCoords(laptopProp) + vector3(0,0,0.25)
    local maxval = airdropConfig.Props.hacktime
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)

            if (math.random(0,100) / 100) < (airdropConfig.PedConfig.percentage / 100) then SpawnMerryWeatherSolider(coord) end

            if hackCountdown <= 0 then
                hackCountdown = 30
                DeleteEntity(laptopProp)
                break
            end
            hackCountdown = hackCountdown - 1
        end
    end)
    
    while hackCountdown > 0 do
        
        Draw3DText(coord,"Lock will open in " .. hackCountdown .. " Seconds" )
        Citizen.Wait(1)
    end
end

local function StartHacking(ped, propCrate)
    local tmpCoord = GetEntityCoords(propCrate)
    local laptop   = nil

    QBCore.Functions.Notify("Merryweather has been notified of the hacking")
    loadAnimDict("anim@gangops@facility@servers@")
    TaskPlayAnim(ped, 'anim@gangops@facility@servers@', 'hotwire', 3.0, 3.0, -1, 1, 0, false, false, false)
    QBCore.Functions.Progressbar("Starting attack", "Opening software...", 2000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        crateHacked = true
        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
        laptop = CreateObject(airdropConfig.Props.laptop, tmpCoord + vector3(0,0.02,0.902), true, true, true)
        FreezeEntityPosition(laptop, true)
        DisplayHackCountdown(laptop)        
    end, function() -- Cancel
        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
    end)
end

RegisterNetEvent("airdrop:client:spawnchopper",function(spawnLocation,dropLocation)
    -- Request all the models for the airdrop to happen
    cRequestModel(airdropConfig.Props.propParachute)
    cRequestModel(airdropConfig.Props.propCrate)

    cRequestModel(airdropConfig.Props.laptop)
    cRequestModel(airdropConfig.Props.laptopClosed)

    cRequestModel(airdropConfig.PedConfig.pedtype)
    cRequestModel(airdropConfig.PedConfig.vehicle)

    
    local parachuteOffset = vector3(0,0,7)
    local pedVehicle      = CreateVehicle(airdropConfig.PedConfig.vehicle, spawnLocation.x, spawnLocation.y, spawnLocation.z, GetHeadingFromVector_2d(dropLocation.x, dropLocation.y), 1, 0)
    local pedDriver       = CreatePedInsideVehicle(pedVehicle, 3, airdropConfig.PedConfig.pedtype, -1, true, true)
    local vehiclePosition = nil

    local propParachute   = nil
    local propCrate       = nil
    local laptop          = nil

    local tmpCoord = nil

    SetHeliBladesFullSpeed(pedVehicle)
    TaskVehicleDriveToCoord(pedDriver, pedVehicle, dropLocation, 100.00, 1, pedVehicle, 786468, 5.0, true)

    while GetDistanceBetweenCoords(dropLocation, GetEntityCoords(pedVehicle)) > 5.0 do
        Citizen.Wait(10)
    end

    Citizen.Wait(2000)

    vehiclePosition = GetEntityCoords(pedVehicle)
    propParachute   = CreateObject(airdropConfig.Props.propParachute, vehiclePosition - parachuteOffset, true, true, true)
    propCrate       = CreateObject(airdropConfig.Props.propCrate, vehiclePosition - vector3(0,0,6), true, true, true)

    FreezeEntityPosition(propParachute ,true)
    FreezeEntityPosition(propCrate,true)
    tmpCoord = GetEntityCoords(propCrate) - vector3(0,0,2)
    while GetEntityHeightAboveGround(propCrate) > 0.2 do    
        tmpCoord = GetEntityCoords(propCrate)
        SetEntityCoords(propParachute, tmpCoord.x, tmpCoord.y, (tmpCoord.z + 3) - airdropConfig.Props.fallspeed, 0, 0, 0, false)
        SetEntityCoords(propCrate, tmpCoord.x, tmpCoord.y, tmpCoord.z - airdropConfig.Props.fallspeed, 0, 0, 0, false)
        Citizen.Wait(10)
    end

    PlaceObjectOnGroundProperly(propCrate)
    CreateFlareOnProp(propCrate)
    DeleteObject(propParachute)

    exports['qb-target']:AddTargetEntity(propCrate, {
		options = {
			{
                icon = 'fas fa-box',
				label = 'Open',
				action = function()
                    if CrateHacked == true then
                        -- Open stash
                    else
                        StartHacking(GetPlayerPed(-1), propCrate)
                    end
                end
			},
            {
                icon = 'fas fa-xmark',
				label = 'Remove',
                canInteract = function()
					return airdropConfig.Debug
				end,
				action = function()
                    DeleteObject(propParachute)
                    DeleteObject(propCrate)
                    DeleteObject(laptop)

                    MarkObjectForDeletion(pedDriver)
                    MarkObjectForDeletion(pedVehicle)
                    DeleteObject(pedDriver)
                    DeleteObject(pedVehicle)
                end
			}
		},
		distance = 2.5
	})

    TaskVehicleDriveToCoord(pedDriver, pedVehicle, spawnLocation, 100.00, 1, pedVehicle, 786468, 10.0, true)
    while GetDistanceBetweenCoords(spawnLocation, GetEntityCoords(pedVehicle)) > 10.0 do
        Citizen.Wait(10)
    end

    MarkObjectForDeletion(pedDriver)
    MarkObjectForDeletion(pedVehicle)
    DeleteObject(pedDriver)
    DeleteObject(pedVehicle)

end)

RegisterCommand("airdrop",function()
    TriggerServerEvent("airdrop:server:spawnchopper")
end)
