local TokenRegistry = {}

TokenRegistry.Abilities = {
    ["CollectToken"] = function(player, farm, tokenPosition)
        local collectRadius = Instance.new("Part")
        collectRadius.Shape = "Cylinder"
        collectRadius.Anchored = true
        collectRadius.CanTouch = false
        collectRadius.CanCollide = false
        collectRadius.Material = Enum.Material.ForceField
        collectRadius.Size = Vector3.new(farm.FarmArea.Size.X, 10, 10)
        collectRadius.CFrame *= CFrame.Angles(0, 0, math.rad(90))
        collectRadius.Position = tokenPosition
        collectRadius.Parent = workspace
    end
}

return TokenRegistry