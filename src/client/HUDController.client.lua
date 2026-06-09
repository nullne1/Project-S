local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UsedWorm = ReplicatedStorage:WaitForChild("RemoteEvents").UsedWorm
local CollectedWorm = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedWorm

local CollectedSilk = ReplicatedStorage:WaitForChild("BindableEvents").CollectedSilk
local InventoryOpened = ReplicatedStorage:WaitForChild("BindableEvents").InventoryOpened
local InventoryClosed = ReplicatedStorage:WaitForChild("BindableEvents").InventoryClosed

local localPlayer = Players.LocalPlayer

local MainGui = localPlayer.PlayerGui:WaitForChild("MainGui")
local wormsText = MainGui.DataFrame.WormsText
local silkText = MainGui.DataFrame.SilkText
local invButton = MainGui.ButtonFrame.InventoryButton

-- local isTouchScreen = UserInputService.TouchEnabled
-- local hasKeyboard = UserInputService.KeyboardEnabled

-- if isTouchScreen and not hasKeyboard then
--     print("Player is on a mobile device or tablet!")
-- end

-- UserInputService.TouchMoved:Connect(function()
--     print("Hello")
-- end)

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

CollectedSilk.Event:Connect(function(startPos, silkInfo)
    silkText.Text += silkInfo["finalSilk"]
end)

UsedWorm.OnClientEvent:Connect(function()
    wormsText.Text -= 1
end)

CollectedWorm.OnClientEvent:Connect(function()
    wormsText.Text += 1
end)

