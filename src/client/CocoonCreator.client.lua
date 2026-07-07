local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(ReplicatedStorage:WaitForChild("Shared").CocoonModule)

local CollectedCocoon = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedCocoon
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient
local CocoonFinished = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonFinished

local localPlayer = Players.LocalPlayer

CocoonStartClient.OnClientEvent:Connect(function(cocoonID, type, wormModel, farm, targetPlant, wormCFrame, targetPos)
    local cocoon = CocoonModule.new(cocoonID, farm, targetPlant, wormCFrame, targetPos)
    
    -- detect player
    local notCollected = true
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and cocoon.CanBeCollected and part and part.Parent and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(localPlayer)) then
            notCollected = false
            CollectedCocoon:FireServer(cocoon.CocoonID, type)

            cocoon:magnetize(localPlayer, true)
        end
    end)

    -- start pupating and despawn plant if its the last
    cocoon:spinCocoon()
    CocoonFinished:FireServer(wormModel, targetPlant)
    cocoon:launch()
end)


