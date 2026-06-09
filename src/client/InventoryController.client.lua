local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantDropRegistry = require(ReplicatedStorage:WaitForChild("Shared").GameData.PlantDropRegistry)

local GetPlayerData = ReplicatedStorage:WaitForChild("RemoteFunctions").GetPlayerData
local UpdateInventory = ReplicatedStorage:WaitForChild("RemoteEvents").UpdateInventory
local InitializeInventory = ReplicatedStorage:WaitForChild("RemoteEvents").InitializeInventory
local InventoryOpened = ReplicatedStorage:WaitForChild("BindableEvents").InventoryOpened
local InventoryClosed = ReplicatedStorage:WaitForChild("BindableEvents").InventoryClosed

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local inventoryFrame = playerGui:WaitForChild("MainGui").InventoryFrame

UpdateInventory.OnClientEvent:Connect(function(newItem)
    local items = GetPlayerData:InvokeServer("items")
    local assetId = PlantDropRegistry.DropInfo[newItem]

    local itemKeys = {}
    for key, _ in pairs(items) do
        table.insert(itemKeys, key)
    end

    if (not table.find(itemKeys, newItem)) then
        local itemTemplate = ReplicatedStorage.UITemplates.ItemTemplate:Clone()
        itemTemplate.Name = newItem .. "Icon"
        itemTemplate.Image = "rbxassetid://" .. assetId
        itemTemplate.Parent = inventoryFrame
        itemTemplate.ItemCounter.Text = 1
    else
        local itemAmount = inventoryFrame:FindFirstChild(newItem .. "Icon").ItemCounter.Text
        local stringWithoutFirstChar = string.sub(itemAmount, 2)
        stringWithoutFirstChar += 1
        inventoryFrame:FindFirstChild(newItem .. "Icon").ItemCounter.Text = "x" .. stringWithoutFirstChar
    end
end)

InitializeInventory.OnClientEvent:Connect(function()
    local items = GetPlayerData:InvokeServer("items")
    for key, value in pairs(items) do
        local assetId = PlantDropRegistry.DropInfo[key]
        local itemTemplate = ReplicatedStorage.UITemplates.ItemTemplate:Clone()
        itemTemplate.Name = key .. "Icon"
        itemTemplate.Image = "rbxassetid://" .. assetId
        itemTemplate.Parent = inventoryFrame
        itemTemplate.ItemCounter.Text = "x" .. value
    end
end)

InventoryOpened.Event:Connect(function()
    inventoryFrame.Visible = true
end)

InventoryClosed.Event:Connect(function()
    inventoryFrame.Visible = false
end)