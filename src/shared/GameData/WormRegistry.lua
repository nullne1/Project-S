local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 0.01},
            {token = "CollectToken", chance = 0.02},
            {token = "SilkToken", chance = 0.03}}
    }
}

return WormRegistry