local QBCore = exports['qb-core']:GetCoreObject()

local fallingCrate  = {}
local dropppedCrate = {}

local Timeout = 0
local CrateDestroyed = false

RegisterCommand("spv", function()
    TriggerServerEvent("airdrop:server:spawnairdrop")
    TriggerEvent('chatMessage', "", {255, 255, 255}, "Airdriop event triggered. Location : Somehwere in Grapeseed/Sandy");
end)

function spawnCrate(pedLocation, headingVector)
    local propToDrop      = 'p_parachute1_sp_dec'
    local PropToDropChild = 'prop_mil_crate_01'

    LoadModel(propToDrop)
    LoadModel(PropToDropChild)
    local spawnLocation = pedLocation

    fallingCrate.PropInf = {
        Location = spawnLocation,
        Child    = CreateObject(propToDrop, vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z - 1), true, true, true),
        Parent   = CreateObject(PropToDropChild, vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z), true, true, true),
        Falling  = true
    }

    local blip = AddBlipForRadius(fallingCrate.PropInf.Location.x, fallingCrate.PropInf.Location.y, fallingCrate.PropInf.Location.z, 100.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)

    SetEntityHeading(fallingCrate.PropInf.Child, headingVector)
    SetEntityHeading(fallingCrate.PropInf.Parent, headingVector)

    SetEntityLodDist(fallingCrate.PropInf.Parent, 1000)
    SetEntityLodDist(fallingCrate.PropInf.Child, 1000)

    UpdateCratePosition()

    dropppedCrate.PropInf = {
        Location          = fallingCrate.PropInf.Location,
        Prop              = fallingCrate.PropInf.Parent,
        Picked            = false,
        PickingInProgress = false
    }

    SetEntityLodDist(dropppedCrate.PropInf.Prop, 1000)

    PlaceObjectOnGroundProperly(dropppedCrate.PropInf.Prop)
    CreateFlareOnProp(dropppedCrate.PropInf.Prop)
    
    DeleteEntity(fallingCrate.PropInf.Child)

    DespawnCrate()

    exports['qb-target']:AddTargetEntity(dropppedCrate.PropInf.Prop, {
		options = {
			{
				type = "client",
				event = "airdrop:client:picklock",
				icon = 'fas fa-box',
				label = 'Open',
			},
            {
				type = "client",
				event = "airdrop:client:destroycrate",
				icon = 'fas fa-box',
				label = 'Destroy',
			}
		},
		distance = 2.5
	})

end

function DespawnCrate()
    Citizen.CreateThread(function()

        local countDown = Config.CrateDespawnTime

        while countDown > 0 do
            countDown = countDown -1

            Citizen.Wait(1000)
        end

        local z = 100;

        while z > 10 do
            local cord = GetEntityCoords(dropppedCrate.PropInf.Prop)
            SetEntityCoords(dropppedCrate.PropInf.Prop, cord.x, cord.y, cord.z - 0.02, 0, 0, 0, false)
            Citizen.Wait(10)
            z = z -1
        end

        DeleteEntity(dropppedCrate.PropInf.Prop)
        RemoveBlip(blip)
    end)
end

function LoadModel(model) 
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end
end

function UpdateCratePosition()
    local windX = math.random(1,10) / 1000
    local windY = math.random(1,10) / 1000
    
    while GetEntityHeightAboveGround(fallingCrate.PropInf.Parent) > 0.2 do
        local cord = GetEntityCoords(fallingCrate.PropInf.Parent)
        
        SetEntityCoords(fallingCrate.PropInf.Child, cord.x + windX, cord.y + windY, (cord.z + 3) - Config.CrateFallSpeed, 0, 0, 0, false)
        SetEntityCoords(fallingCrate.PropInf.Parent, cord.x + windX, cord.y + windY, cord.z - Config.CrateFallSpeed, 0, 0, 0, false)
        Citizen.Wait(10)
    end
    PlaceObjectOnGroundProperly(fallingCrate.PropInf.Parent)
end

function CreateFlareOnProp(Prop)
    UseParticleFxAssetNextCall("core")
    SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
    StartParticleFxLoopedOnEntity('weap_heist_flare_trail', Prop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
    FreezeEntityPosition(Prop, true)
end

RegisterNetEvent("airdrop:client:spawnairdrop", function()

    local vehicle = "cargobob"
    LoadModel(vehicle)


    local pedType = "csb_mweather"
    LoadModel(pedType)


    local vehicleFirstTarget  = Config.ChopperCratedropLocations[math.random(#Config.ChopperCratedropLocations)]
    local SpawnPos   = Config.ChopperSpawnLocations[math.random(#Config.ChopperSpawnLocations)]
    local pedVehicle = CreateVehicle(vehicle, SpawnPos.x, SpawnPos.y, SpawnPos.z, GetHeadingFromVector_2d(vehicleFirstTarget.x, vehicleFirstTarget.y), 1, 0)
    local driver     = CreatePedInsideVehicle(pedVehicle, 3, pedType, -1, true, true)

    -- Teleport person inside cargobob, just to see where it is
    if Config.Debug == true then
        StartPlayerTeleport(PlayerId(), SpawnPos.x, SpawnPos.y, SpawnPos.z, 0.0, false, true, true)

        local blip = AddBlipForRadius(vehicleFirstTarget.x,vehicleFirstTarget.y,vehicleFirstTarget.z, 20.0)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 128)

        while IsPlayerTeleportActive() do
            Citizen.Wait(0)
        end
    end
    


    SetHeliBladesFullSpeed(pedVehicle)

    Citizen.CreateThread(function()
        TaskVehicleDriveToCoord(driver, pedVehicle, vehicleFirstTarget.x, vehicleFirstTarget.y, vehicleFirstTarget.z, 100.00, 1, pedVehicle, 786468, 10.0, true)
        while GetDistanceBetweenCoords(vehicleFirstTarget.x, vehicleFirstTarget.y, vehicleFirstTarget.z, GetEntityCoords(pedVehicle)) > 10.0 do
            Citizen.Wait(1)
        end

        Citizen.Wait(Config.TimeBeforeDrop)
        local currentPos = vector3(GetEntityCoords(pedVehicle).x,GetEntityCoords(pedVehicle).y,GetEntityCoords(pedVehicle).z - 8)
        local headingVec = GetEntityHeading(pedVehicle)

        spawnCrate(currentPos, headingVec)
        Citizen.Wait(Config.TimeBeforeleave)

        TaskVehicleDriveToCoord(driver, pedVehicle, SpawnPos.x, SpawnPos.y, 300, 100.00, 1, pedVehicle, 786468, 10.0, true)
        while GetDistanceBetweenCoords(SpawnPos.x, SpawnPos.y, SpawnPos.z, GetEntityCoords(pedVehicle)) > 10.0 do
            Citizen.Wait(1)
        end

        DeleteEntity(pedVehicle)
        DeleteEntity(driver)

    end)
end)

RegisterCommand("showallairdroppoints", function()
    local blips = {}
    for nameCount = 1, #Config.ChopperCratedropLocations do
        local location = Config.ChopperCratedropLocations[nameCount]
        local blip = AddBlipForRadius(location.x,location.y,location.z, 20.0)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 128)
        table.insert(blips,blip)
    end
    Citizen.CreateThread(function()
        Citizen.Wait(10000)
        for item = 1, #blips do
            RemoveBlip(blips[item])
        end
    end)
end, true)

RegisterNetEvent('airdrop:client:destroycrate', function()
    DeleteEntity(dropppedCrate.PropInf.Prop)
    CrateDestroyed = true
end)

RegisterNetEvent('airdrop:crate:picklock', function()
    if dropppedCrate.PropInf.Picked == false then

        QBCore.Functions.Progressbar("Opening crate", "Picking the lock..", 60000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
            TriggerServerEvent('airdrop:server:spawnpeds'),
        },{
            animDict = "anim@gangops@facility@servers@",
            anim = "hotwire",
            flags = 16,
        }, {}, {}, function()
            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
            TriggerServerEvent("airdrop:client:opencrate")
            dropppedCrate.PropInf.Picked = true
        end)
    else
        TriggerEvent("airdrop:client:opencrate")
    end
end)

RegisterNetEvent('airdrop:client:spawnpeds',function()
    local maxpeds        = Config.MaxNumbedOfPeds
    local numPedsSpawned = 0

	Citizen.CreateThread(function()
        while dropppedCrate.PropInf.Picked == false do
            local cord = GetEntityCoords(fallingCrate.PropInf.Parent)
            Citizen.Wait(math.random(Config.MinPedSpawning ,Config.MaxPedSpawning))
            local pedX = cord.x + math.random(-100,100)
            local pedY = cord.y + math.random(-100,100)
            local pedZ = cord.z
            local pedType = Config.CrateProtectors[math.random(#Config.CrateProtectors)]


            RequestModel(pedType)
            while not HasModelLoaded(pedType) do
                Wait(1)
            end

            local ped = CreatePed(4, pedType, pedX, pedY, pedZ, 0.0, true, true)
            GiveWeaponToPed(ped, GetHashKey(Config.CrateProtectorWeapons[math.random(#Config.CrateProtectorWeapons)]), 60, false, true)

            PlaceObjectOnGroundProperly(ped)
            local PedLocation = vector3(pedX,pedY,pedZ)
            
            local coords = GetEntityCoords(fallingCrate.PropInf.Parent)

            TaskGoToCoordAnyMeans(ped, coords, 5.0, 0, 0, 786603, 0xbf800000)
            TaskCombatPed(ped, GetPlayerPed(-1), 0, 16)
            SetPedShootRate(ped, 200)
            SetPedAccuracy(ped, 100)
            SetEntityHealth(ped, 200)
            SetPedPathAvoidFire(ped, 1)
            SetPedRelationshipGroupHash(ped, GetHashKey("army"))
            SetPedCombatAttributes(ped, 46, true)
            numPedsSpawned = numPedsSpawned + 1
            if maxpeds == 0 then
                print("no more peds please: ", numPedsSpawned)
                break
            end
            maxpeds = maxpeds - 1
        end
    end)
end)

RegisterNetEvent('airdrop:client:opencrate',function()
	local CrateItems = {}
	CrateItems.label = "Prison Canteen"
	CrateItems.items = Config.CrateItems
	CrateItems.slots = #Config.CrateItems
	TriggerServerEvent("inventory:server:OpenInventory", "shop", "Lootcrate_"..math.random(1, 99), CrateItems)
end)

