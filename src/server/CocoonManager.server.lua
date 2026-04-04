local ServerStorage = game:GetService("ServerStorage")
local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart

CocoonStart.Event:Connect(function(wormBody, farm, player, targetTree, treeModule)
    CocoonModule.new(wormBody, wormBody.CFrame, farm, player, targetTree, treeModule)
end)