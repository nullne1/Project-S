local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DropModule = require(ReplicatedStorage.Shared.DropModule)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)

local CollectedDrop = ServerStorage.BindableEvents.CollectedDrop
local PlantDespawned = ServerStorage.BindableEvents.PlantDespawned

CollectedDrop.Event:Connect(function(player, dropMesh)
    PlayerData.addItem(player, tostring(dropMesh))
end)

PlantDespawned.Event:Connect(function(name, spawnCFrame, farm, player)
    local drop = DropModule.new(name, spawnCFrame, farm, player)
    drop:hover()
end)