local WormRegistry = {}

WormRegistry.Worms = {
    ["basicWorm"] = {
        Speed = 1,
        TokenSkills = {
            {token = "FireToken", chance = 0.25},
            {token = "CollectToken", chance = 0.25},
            {token = "SilkToken", chance = 0.5}}
    }
}

return WormRegistry