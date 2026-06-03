local PlantDropRegistry = {}

PlantDropRegistry.Drops = {
    ["BasicBush"] = {
        "Stick",
    }
}

PlantDropRegistry.DropInfo = {
    ["Stick"] = 132171463852957
}

PlantDropRegistry.DropChance = {
    ["Stick"] = {
        {amount = 3, chance = 0.07},
        {amount = 2, chance = 0.16},
        {amount = 1, chance = 0.33}
    }
}

return PlantDropRegistry