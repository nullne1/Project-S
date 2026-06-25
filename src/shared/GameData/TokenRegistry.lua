local TokenRegistry = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local CocoonRegistry = require(ReplicatedStorage.Shared.GameData.CocoonRegistry)
local PlantRegistry = require(game:GetService("ReplicatedStorage").Shared.GameData.PlantRegistry)

local RenderTokenEffect = ReplicatedStorage.RemoteEvents.RenderTokenEffect
local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

TokenRegistry.Abilities = {
    ["WaterToken"] = function(player, farm, tokenPosition, targetPlant)
        return
    end,

    ["FireToken"] = function(player, farm, tokenPosition, targetPlant)
        local plantModule = PlantRegistry[targetPlant]
        if (targetPlant and plantModule and plantModule.FireStacks == 0) then
            plantModule.FireStacks = 0
            plantModule:setFire()
            
        elseif (targetPlant and plantModule and plantModule.FireStacks > 0) then
            plantModule.FireStacks += 1

            local startTime = os.time()
            plantModule.StartTime = startTime
            plantModule.EndTime = startTime + 8
        end
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
    end,

    ["SilkToken"] = function(player, farm, tokenPosition, targetPlant)
        local finalSilkInfo = calculateFinalSilk(player, "SilkToken")
        PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
        CollectedSilk:FireClient(player, tokenPosition, finalSilkInfo)
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