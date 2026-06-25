local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 0.1},
            {token = "CollectToken", chance = 0.1},
            {token = "SilkToken", chance = 0.1},
            {token = "WaterToken", chance = 1}}
    }
}

return WormRegistry