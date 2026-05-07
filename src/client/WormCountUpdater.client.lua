local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local wormsText = localPlayer.PlayerGui:WaitForChild("MainGui").WormsText

local UsedWorm = ReplicatedStorage.RemoteEvents.UsedWorm
local CollectedWorm = ReplicatedStorage.RemoteEvents.CollectedWorm

UsedWorm.OnClientEvent:Connect(function()
    wormsText.Text -= 1
end)

CollectedWorm.OnClientEvent:Connect(function()
    wormsText.Text += 1
end)


