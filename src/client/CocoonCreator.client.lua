local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(ReplicatedStorage.Shared.CocoonModule)

local CollectedCocoon = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedCocoon
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient
local CocoonFinished = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonFinished

local LocalPlayer = Players.LocalPlayer

CocoonStartClient.OnClientEvent:Connect(function(type, wormModel, farm, targetPlant, wormCFrame, tokenSkills)
    local cocoon = CocoonModule.new(farm, targetPlant, wormCFrame)
    cocoon:spinCocoon()
    
    -- detect player
    local notCollected = true
    local canBeCollected
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and canBeCollected and part and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(LocalPlayer)) then
            notCollected = false
            CollectedCocoon:FireServer(type, cocoon.Ball.Position)
            cocoon:despawn()
        end
    end)

    -- start pupating and despawn plant if its the last
    cocoon:spinCocoon()
    CocoonFinished:FireServer(wormModel, targetPlant)
    cocoon:launch()
    
    canBeCollected = true
end)


