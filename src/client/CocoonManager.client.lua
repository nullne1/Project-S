local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(ReplicatedStorage:WaitForChild("Shared").CocoonModule)

local GetPlayerData = ReplicatedStorage:WaitForChild("RemoteFunctions").GetPlayerData
local AssignEntityToPlayer = ReplicatedStorage:WaitForChild("RemoteFunctions").AssignEntityToPlayer

local AddWorm = ReplicatedStorage:WaitForChild("RemoteEvents").AddWorm
local AddSilk = ReplicatedStorage:WaitForChild("RemoteEvents").AddSilk
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient
local CocoonFinished = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonFinished

local CollectedSilk = ReplicatedStorage:WaitForChild("BindableEvents").CollectedSilk

local LocalPlayer = Players.LocalPlayer

local function calculateFinalSilk()
    local flatSilk = GetPlayerData:InvokeServer("flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= GetPlayerData:InvokeServer("critChance")) then
        finalSilk += finalSilk * GetPlayerData:InvokeServer("critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

CocoonStartClient.OnClientEvent:Connect(function(type, wormModel, farm, targetPlant, wormCFrame, tokenSkills)
    local cocoon = CocoonModule.new(farm, targetPlant, wormCFrame)
    cocoon:spinCocoon()
    
    AssignEntityToPlayer:InvokeServer(LocalPlayer, cocoon.Ball)
    -- detect player
    local notCollected = true
    local canBeCollected
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and canBeCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(LocalPlayer)) then
            notCollected = false
            
            -- calculate final silk amount from player data
            local finalSilkInfo = calculateFinalSilk()
            AddWorm:FireServer(type, 1)
            AddSilk:FireServer(finalSilkInfo["finalSilk"])
            
            CollectedSilk:Fire(cocoon.Ball.Position, finalSilkInfo)
            cocoon:despawn()
        end
    end)

    -- start pupating and despawn plant if its the last
    cocoon:spinCocoon()
    CocoonFinished:FireServer(wormModel)
    cocoon:launch()
    
    canBeCollected = true
end)


