local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 0.2},
            {token = "CollectToken", chance = 1},
            {token = "SilkToken", chance = 0.1},
            {token = "WaterToken", chance = 0.5}}
    }
}

return WormRegistry