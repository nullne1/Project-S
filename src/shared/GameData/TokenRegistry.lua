local TokenRegistry = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local CocoonRegistry = require(ReplicatedStorage.Shared.GameData.CocoonRegistry)

local RenderTokenEffect = ReplicatedStorage.RemoteEvents.RenderTokenEffect
local RaycastIgnore = ReplicatedStorage.RemoteEvents.RaycastIgnore
local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

TokenRegistry.Abilities = {
    ["FireToken"] = function(player, farm, tokenPosition, targetPlant)
        if (targetPlant) then
            local ColorTween = TweenService:Create(
                targetPlant,
                TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                {Color = Color3.fromHex("#FF0000")}
            )
            ColorTween:Play()
        end
    end,

    ["SilkToken"] = function(player, farm, tokenPosition, targetPlant)
        local finalSilkInfo = calculateFinalSilk(player, "SilkToken")
        PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
        CollectedSilk:FireClient(player, tokenPosition, finalSilkInfo)
    end,

    ["CollectToken"] = function(player, farm, tokenPosition, targetPlant)
        local dropAreaSize = farm.Plants:GetChildren()[1].DropArea.Size.Y
        local collectRadius = (dropAreaSize / 2) + 1.6
        local playerCocoons = CocoonRegistry[player.UserId]
        local wormsCollected = 0
        local collectedIDs = {}

        if playerCocoons then
            for cocoonID, cocoonPosition in pairs(playerCocoons) do
                local distance = (tokenPosition - cocoonPosition).Magnitude
                
                if distance <= collectRadius then
                    wormsCollected += 1
                    table.insert(collectedIDs, cocoonID)
                    
                    local finalSilkInfo = calculateFinalSilk(player, "collectToken")
                    CollectedSilk:FireClient(player, cocoonPosition, finalSilkInfo)

                    -- Remove it from the virtual registry
                    playerCocoons[cocoonID] = nil
                end
            end
        end

        if wormsCollected > 0 then
            PlayerDataModule.addWorm(player, "basicWorm", wormsCollected)
            
            -- Tell the client to play the pink cylinder effect AND delete the physical meshes
            RenderTokenEffect:FireClient(player, "CollectToken", farm, tokenPosition, collectedIDs)
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