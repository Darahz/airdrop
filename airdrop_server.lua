local spawnedCrate = {}


RegisterNetEvent("airdrop:server:spawnchopper")
AddEventHandler("airdrop:server:spawnchopper",function()
    local chopperSpawnLocation = airdropConfig.ChopperSpawnLocations[math.random(#airdropConfig.ChopperSpawnLocations)]
    local chopperDropLocation  = airdropConfig.Droplocations[math.random(#airdropConfig.Droplocations)]
    TriggerClientEvent("airdrop:client:spawnchopper", -1,chopperSpawnLocation,chopperDropLocation)

end)