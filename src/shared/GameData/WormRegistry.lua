local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 0.2},
            {token = "CollectToken", chance = 0},
            {token = "SilkToken", chance = 0.2},
            {token = "WaterToken", chance = 0.2}}
    }
}

return WormRegistry