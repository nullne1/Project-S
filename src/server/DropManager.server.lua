local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DropModule = require(ReplicatedStorage.Shared.DropModule)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)
local PlantDropRegistry = require(ReplicatedStorage.Shared.GameData.PlantDropRegistry)

local CollectedDrop = ServerStorage.BindableEvents.CollectedDrop
local PlantDespawned = ServerStorage.BindableEvents.PlantDespawned
local UpdateInventory = ReplicatedStorage.RemoteEvents.UpdateInventory

CollectedDrop.Event:Connect(function(player, dropMesh)
    PlayerData.addItem(player, tostring(dropMesh))
end)

PlantDespawned.Event:Connect(function(name, spawnCFrame, farm, player)
    local plantDrops = PlantDropRegistry.Drops[name]
    local dropChances = PlantDropRegistry.DropChance[plantDrops[1]]

    -- simulates chance based on drop chances dict and keeps track of the biggest number of drops chosen
    local rng = math.random()
    local counter = 0
    local awardedAmount = nil
    for _, dropInfo in dropChances do
        counter += dropInfo["chance"]
        if (rng <= counter) then
            awardedAmount = dropInfo["amount"]
            break
        end
    end

    if (awardedAmount) then
        for i = 1, awardedAmount, 1 do
            local drop = DropModule.new(name, spawnCFrame, farm, player)
            drop.DropMesh = ServerStorage.Drops:FindFirstChild(plantDrops[1], true):Clone()

            drop:hover()

            local collected = false
            drop.DropMesh.Touched:Connect(function(otherPart)
                if (not collected and tostring(otherPart.Parent) == tostring(player)) then
                    collected = true
                    CollectedDrop:Fire(player, drop.DropMesh)
                    UpdateInventory:FireClient(player, drop.DropMesh.Name)
                    drop:despawn()
                end
            end)
        end
    end
end)