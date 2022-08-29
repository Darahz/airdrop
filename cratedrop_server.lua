
RegisterNetEvent("airdrop:server:spawnairdrop", function()
    TriggerClientEvent("airdrop:client:spawnairdrop", -1)
end)

RegisterNetEvent("airdrop:server:spawnpeds", function()
    TriggerClientEvent("airdrop:client:spawnpeds", -1)
end)