local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 1},
            {token = "CollectToken", chance = 0},
            {token = "SilkToken", chance = 0},
            {token = "WaterToken", chance = 0}}
    }
}

return WormRegistry