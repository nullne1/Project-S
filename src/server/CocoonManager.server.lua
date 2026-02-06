local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)

local CocoonStart = game:GetService("ServerStorage").BindableEvents.CocoonStart
local CocoonFinished = game:GetService("ServerStorage").BindableEvents.CocoonFinished

local StartExtract = game:GetService("ServerStorage").BindableEvents.StartExtract
local StopExtract = game:GetService("ServerStorage").BindableEvents.StopExtract

CocoonStart.Event:Connect(function(wormBody, farm, player)
    local cocoon = CocoonModule.new(wormBody, wormBody.CFrame, farm, player)
    cocoon:start()
end)