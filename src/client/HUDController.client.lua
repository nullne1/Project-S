local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UsedWorm = ReplicatedStorage:WaitForChild("RemoteEvents").UsedWorm
local CollectedWorm = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedWorm
local CollectedSilk = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedSilk

local InventoryOpened = ReplicatedStorage:WaitForChild("BindableEvents").InventoryOpened
local InventoryClosed = ReplicatedStorage:WaitForChild("BindableEvents").InventoryClosed

local localPlayer = Players.LocalPlayer
local MainGui = localPlayer.PlayerGui:WaitForChild("MainGui")
local wormsText = MainGui.Data.WormsText
local silkText = MainGui.Data.SilkText
local invButton = MainGui.InventoryButton

local inventoryIsOpen = false
invButton.MouseButton1Click:Connect(function()
    if (inventoryIsOpen) then
        InventoryClosed:Fire()
        inventoryIsOpen = false
    else
        InventoryOpened:Fire()
        inventoryIsOpen = true
    end
end)

CollectedSilk.OnClientEvent:Connect(function(startPos, silkInfo)
    silkText.Text += silkInfo["finalSilk"]
end)

UsedWorm.OnClientEvent:Connect(function()
    wormsText.Text -= 1
end)

CollectedWorm.OnClientEvent:Connect(function()
    wormsText.Text += 1
end)

