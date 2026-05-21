local TokenRegistry = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerDataModule)
local Zone = require(ReplicatedStorage.ZonePluginModule.Zone)

local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk
local TokenUsed = ReplicatedStorage:WaitForChild("RemoteEvents").TokenUsed


TokenRegistry.Abilities = {
    ["FireToken"] = function(player, farm, tokenPosition)

    end,

    ["CollectToken"] = function(player, farm, tokenPosition)
        local collectRadius = Instance.new("Part")
        collectRadius.Shape = "Cylinder"
        collectRadius.Anchored = true
        collectRadius.CanCollide = false
        collectRadius.CanQuery = false
        collectRadius.CastShadow = false
        collectRadius.Transparency = 1
        collectRadius.Size = Vector3.new(farm.FarmArea.Size.X, 20, 10)
        local floorY = farm.FarmArea.Position.Y
        collectRadius.CFrame = CFrame.new(tokenPosition.X, floorY, tokenPosition.Z) * CFrame.Angles(0, 0, math.rad(90))
        collectRadius.Parent = workspace

        TokenUsed:FireClient(player, collectRadius)

        local collectZone = Zone.new(collectRadius)
        local function processCocoonPart(part)
            if (part.Name == "BasicBall") then
                local finalSilkInfo = calculateFinalSilk(player)
                CollectedSilk:FireClient(player, part.Position, finalSilkInfo)
                part:Destroy()
            end
        end

        -- 1. Catch cocoons that fall into the aura AFTER it spawns
        collectZone.partEntered:Connect(processCocoonPart)

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
        TweenShape.Material = Enum.Material.ForceField
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
            {Size = Vector3.new(farm.FarmArea.Size.X, 20, 10)}
        )
        
        task.spawn(function()
            CollectTween:Play()
            CollectTween.Completed:Wait()
            collectZone:destroy()
            collectRadius:Destroy()
            TweenShape:Destroy()
        end)


        
    end
}

function calculateFinalSilk(player)
    local flatSilk = PlayerData.getBasicData(player, "flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= PlayerData.getBasicData(player, "critChance")) then
        finalSilk += finalSilk * PlayerData.getBasicData(player, "critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

return TokenRegistry