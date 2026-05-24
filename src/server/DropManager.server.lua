local ServerStorage = game:GetService("ServerStorage")

local DropModule = require(game:GetService("ReplicatedStorage").Shared.DropModule)
local PlantDespawned = ServerStorage.BindableEvents.PlantDespawned

PlantDespawned.Event:Connect(function(name, spawnCFrame, farm, player)
    local drop = DropModule.new(name, spawnCFrame, farm, player)
    drop:hover()
end)