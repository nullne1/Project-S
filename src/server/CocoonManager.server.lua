local ServerStorage = game:GetService("ServerStorage")
local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished

local StartExtract = ServerStorage.BindableEvents.StartExtract
local StopExtract = ServerStorage.BindableEvents.StopExtract

CocoonStart.Event:Connect(function(wormBody, farm, player)
    local cocoon = CocoonModule.new(wormBody, wormBody.CFrame, farm, player)
    cocoon:start()
end)