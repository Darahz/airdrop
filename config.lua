Config = {}

Config.CrateFallSpeed   = 0.09
Config.CrateDespawnTime = 300

Config.TimeBeforeDrop   = 10000
Config.TimeBeforeleave   = 1000

Config.Timeout = 60

Config.Debug = false

-- Spawning in milliseconds, there's a wait between spawn
Config.MinPedSpawning = 9000
Config.MaxPedSpawning = 12000
Config.MaxNumbedOfPeds   = 8

Config.ChopperSpawnLocations = {
    vector3(4614.49,  3689.4,  537.61),
    vector3(3454.88,  1748.83, 668.37),
    vector3(2939.93, -116.24,  580.37),
    vector3(654.47,   154.66,  1056.82),
    vector3(-100.45,  1772.3,  529.33),
    vector3(-697.58,  3025.29, 426.27),
    vector3(-1752.53, 4866.04, 354.18),
    vector3(-1457.17, 5890.31, 520.18),
    vector3(-1859.98, 2795.13, 300.81),
    vector3(2001.69,  7998.37, 471.68),
}

Config.ChopperCratedropLocations = {
    vector3(2683.33, 2989.83, 150.00),
    vector3(2573.02, 2940.49, 150.00),
    vector3(2510.92, 3276.14, 150.00),
    vector3(2108.58, 3389.74, 150.00),
    vector3(1970.74, 3424.37, 150.00),
    vector3(2141.02, 3891.35, 150.00),
    vector3(2532.14, 4356.5,  150.00),
    vector3(2328.72, 4629.49, 150.00),
    vector3(2087.08, 4600.18, 150.00),
    vector3(586.56,  2935.91, 150.00),
    vector3(749.92,  2526.1,  150.00),
    vector3(827.23,  2141.76, 150.00),
}

Config.CrateItems = {
    [1] = {
        name = "goldbar",
        price = 0,
        amount = 50,
        info = {},
        type = "item",
        slot = 1
    },
    [2] = {
        name = "diamond_ring",
        price = 0,
        amount = math.random(1,3),
        info = {},
        type = "item",
        slot = 2
    }
}