local TokenRegistry = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)

local RaycastIgnore = ReplicatedStorage.BindableEvents.RaycastIgnore

local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

TokenRegistry.Abilities = {
    ["FireToken"] = function(player, farm, tokenPosition)
        
    end,

    ["SilkToken"] = function(player, farm, tokenPosition)
        local finalSilkInfo = calculateFinalSilk(player, "SilkToken")
        PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
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
        
        RaycastIgnore:Fire(collectRadius)
        
        local TweenShape = Instance.new("Part")
        TweenShape.Shape = "Cylinder"
        TweenShape.Anchored = true
        TweenShape.CanCollide = false
        TweenShape.CanQuery = false
        TweenShape.Size = Vector3.new(farm.FarmArea.Size.X, 0, 0)
        TweenShape.Color = Color3.fromHex("#ff91ad")
        TweenShape.Material = Enum.Material.ForceField
        TweenShape.CastShadow = false
        
        local CollectTweenInfo = TweenInfo.new(
            0.3,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )

        local wormsList = {}
        local wormsCollected = 0
        local function processCocoonPart(part)
            if (part.Name == "BasicBall") then
                table.insert(wormsList, part)
                wormsCollected += 1
            end
        end
        
        -- 1. Catch cocoons that fall into the radius AFTER it spawns
        collectRadius.Touched:Connect(processCocoonPart)
        
        local overlapParams = OverlapParams.new()
        local partsInside = workspace:GetPartsInPart(collectRadius, overlapParams)
        
        -- 2. Catch cocoons that were ALREADY there when the aura spawned
        for _, part in pairs(partsInside) do
            processCocoonPart(part)
        end

        collectRadius:Destroy()

        for _, cocoon in pairs(wormsList) do
            if (cocoon) then
                local TweenShapeCopy = TweenShape:Clone()
                TweenShape.CFrame = CFrame.new(cocoon.Position.X, floorY, cocoon.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
                TweenShapeCopy.Parent = workspace
                RaycastIgnore:Fire(TweenShapeCopy)
                
                local CollectTween = TweenService:Create(
                    TweenShapeCopy,
                    CollectTweenInfo,
                    {Size = Vector3.new(farm.FarmArea.Size.X, cocoon.Size.X, cocoon.Size.X)}
                )
                
                task.spawn(function()
                    CollectTween:Play()
                    cocoon:Destroy()
                    CollectTween.Completed:Wait()
                    TweenShapeCopy:Destroy()
                end)

                local finalSilkInfo = calculateFinalSilk(player, "collectToken")
                CollectedSilk:Fire(cocoon.Position, finalSilkInfo)
            end
        end

        if wormsCollected > 0 then
            PlayerDataModule.addWorm(player, type, wormsCollected)
        end
    end
}

function calculateFinalSilk(player, token)
    local flatSilk = PlayerDataModule.getBasicData(player, "flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (token == "SilkToken" or rand <= PlayerDataModule.getBasicData(player, "critChance")) then
        finalSilk += finalSilk * PlayerDataModule.getBasicData(player, "critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

return TokenRegistry