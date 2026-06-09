local TokenRegistry = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GetPlayerData = ReplicatedStorage:WaitForChild("RemoteFunctions").GetPlayerData

local AddWorm = ReplicatedStorage:WaitForChild("RemoteEvents").AddWorm
local AddSilk = ReplicatedStorage:WaitForChild("RemoteEvents").AddSilk
local TokenUsed = ReplicatedStorage:WaitForChild("BindableEvents").TokenUsed

local CollectedSilk = ReplicatedStorage:WaitForChild("BindableEvents").CollectedSilk

TokenRegistry.Abilities = {
    ["FireToken"] = function(player, farm, tokenPosition)
        
    end,

    ["BasicToken"] = function(player, farm, tokenPosition)
        local finalSilkInfo = calculateFinalSilk(player, "basicToken")
        PlayerData.addSilk(player, finalSilkInfo["finalSilk"])
        CollectedSilk:FireClient(player, tokenPosition, finalSilkInfo)
    end,

    ["CollectToken"] = function(player, farm, tokenPosition)
        local dropAreaSize = farm.Plants:GetChildren()[1].DropArea.Size.Y
        local collectRadius = Instance.new("Part")
        collectRadius.Shape = "Cylinder"
        collectRadius.Anchored = true
        collectRadius.CanCollide = false
        collectRadius.CanQuery = false
        collectRadius.CastShadow = false
        collectRadius.Transparency = 1
        collectRadius.Size = Vector3.new(farm.FarmArea.Size.X, dropAreaSize, dropAreaSize)
        local floorY = farm.FarmArea.Position.Y
        collectRadius.CFrame = CFrame.new(tokenPosition.X, floorY, tokenPosition.Z) * CFrame.Angles(0, 0, math.rad(90))
        collectRadius.Parent = workspace

        TokenUsed:Fire(player, collectRadius)

        local wormsCollected = 0
        local function processCocoonPart(part)
            if (part.Name == "BasicBall") then
                part.Name = "Collected"
                local finalSilkInfo = calculateFinalSilk("collectToken")
                CollectedSilk:Fire(part.Position, finalSilkInfo)
                wormsCollected += 1
                part:Destroy()
            end
        end
        
        -- 1. Catch cocoons that fall into the aura AFTER it spawns
        collectRadius.Touched:Connect(processCocoonPart)
        
        local overlapParams = OverlapParams.new()
        local partsInside = workspace:GetPartsInPart(collectRadius, overlapParams)
        
        -- 2. Catch cocoons that were ALREADY there when the aura spawned
        for _, part in pairs(partsInside) do
            processCocoonPart(part)
        end
        
        local TweenShape = Instance.new("Part")
        TweenShape.Shape = "Cylinder"
        TweenShape.Anchored = true
        TweenShape.CanCollide = false
        TweenShape.CanQuery = false
        TweenShape.Size = Vector3.new(farm.FarmArea.Size.X, 0, 0)
        TweenShape.CFrame = CFrame.new(tokenPosition.X, floorY, tokenPosition.Z) * CFrame.Angles(0, 0, math.rad(90))
        TweenShape.Color = Color3.fromHex("#ff91ad")
        TweenShape.Material = Enum.Material.ForceField
        TweenShape.Color = Color3.fromHex("#ff91ad")
        TweenShape.CastShadow = false
        TweenShape.Parent = workspace
        
        local CollectTweenInfo = TweenInfo.new(
            0.3,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )

        local CollectTween = TweenService:Create(
            TweenShape,
            CollectTweenInfo,
            {Size = Vector3.new(farm.FarmArea.Size.X, dropAreaSize, dropAreaSize)}
        )
        
        task.spawn(function()
            CollectTween:Play()
            CollectTween.Completed:Wait()
            collectRadius:Destroy()
            TweenShape:Destroy()
        end)

        if wormsCollected > 0 then
            AddWorm:FireServer("basicWorm", wormsCollected)
        end
    end
}

function calculateFinalSilk(token)
    local flatSilk = GetPlayerData:InvokeServer("flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (token == "SilkToken" or rand <= GetPlayerData:InvokeServer("critChance")) then
        finalSilk += finalSilk * GetPlayerData:InvokeServer("critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

return TokenRegistry