local TokenRegistry = {}

TokenRegistry.Abilities = {
    ["CollectToken"] = function(player, farm, tokenPosition)
        local collectRadius = Instance.new("Part")
        collectRadius.Shape = "Cylinder"
        collectRadius.Anchored = true
        collectRadius.CanTouch = false
        collectRadius.CanCollide = false
        collectRadius.Size = Vector3.new(farm.FarmArea.Size.X, 10, 10)
        print(player)
    end
}

return TokenRegistry