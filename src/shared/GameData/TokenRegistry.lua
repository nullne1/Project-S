local TokenRegistry = {}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local CocoonRegistry = require(ReplicatedStorage.Shared.GameData.CocoonRegistry)
local PlantRegistry = require(game:GetService("ReplicatedStorage").Shared.GameData.PlantRegistry)

local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

local ActivateTokenClient = ReplicatedStorage.RemoteFunctions.ActivateTokenClient


TokenRegistry.Abilities = {
    ["WaterToken"] = function(player, farm, tokenPosition, targetPlant)
        local bounces = math.huge
        local dropAreaSize = farm.Plants:GetChildren()[1].DropArea.Size.Y
        local bounceRadius = (dropAreaSize / 1.5)
        local playerCocoons = CocoonRegistry[player.UserId]
        local lastCocoonPos = nil
        local cocoonNotFound = true
        local waveID = HttpService:GenerateGUID(false)
        local waveSpeed = 0.3
        local cocoonPos = nil
        local finalSilkInfo = nil

        for i = 1, bounces, 1 do
            -- detects based on position around token on the first iteration, last cocoon for every other iteration
            if (playerCocoons and i == 1) then
                -- looks for valid cocoon
                for cocoonID, cocoonData in pairs(playerCocoons) do
                    local cocoonActive = cocoonData["Active"]
                    if (cocoonActive) then
                        local cocoonTargetPos = cocoonData["TargetPos"]
                        local distance = (Vector3.new(targetPlant.Position.X, targetPlant.Position.Y, targetPlant.Position.Z) - Vector3.new(cocoonTargetPos.X, cocoonTargetPos.Y, cocoonTargetPos.Z)).Magnitude
                        local WaterTokenInfo = {
                            WaveID = waveID,
                            CollectedID = cocoonID,
                            LastBounce = false,
                            WaveSpeed = waveSpeed
                        }
                        
                        if (distance <= bounceRadius) then
                            playerCocoons[cocoonID] = nil
                            lastCocoonPos = ActivateTokenClient:InvokeClient(player, "WaterToken", farm, tokenPosition, nil, WaterTokenInfo)
                            
                            finalSilkInfo = calculateFinalSilk(player, "WaterToken")
                            cocoonPos = cocoonTargetPos

                            PlayerDataModule.addWorm(player, "basicWorm", 1)
                            PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])

                            -- Remove it from the virtual registry
                            cocoonNotFound = false
                            break
                        end
                        cocoonNotFound = true
                    end
                end
            elseif (not lastCocoonPos or cocoonNotFound) then
                break
            elseif (lastCocoonPos) then
                -- mid wave, looks for cocoon based on last cocoon's position
                for cocoonID, cocoonData in pairs(playerCocoons) do
                    local cocoonActive = cocoonData["Active"]
                    if (cocoonActive) then
                        local cocoonTargetPos = cocoonData["TargetPos"]
                        local distance = (Vector3.new(lastCocoonPos.X, targetPlant.Position.Y, lastCocoonPos.Z) - Vector3.new(cocoonTargetPos.X, cocoonTargetPos.Y, cocoonTargetPos.Z)).Magnitude

                        local WaterTokenInfo = {
                            WaveID = waveID,
                            CollectedID = cocoonID,
                            LastBounce = false,
                            WaveSpeed = waveSpeed
                        }
                        
                        if (distance <= bounceRadius) then
                            playerCocoons[cocoonID] = nil
                            lastCocoonPos = ActivateTokenClient:InvokeClient(player, "WaterToken", farm, tokenPosition, nil, WaterTokenInfo)
                            
                            finalSilkInfo = calculateFinalSilk(player, "WaterToken")
                            cocoonPos = cocoonTargetPos    

                            PlayerDataModule.addWorm(player, "basicWorm", 1)
                            PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])

                            -- Remove it from the virtual registry
                            cocoonNotFound = false
                            break
                        end
                        cocoonNotFound = true
                    end
                end
            else
                break
            end
            task.wait(waveSpeed)
            CollectedSilk:FireClient(player, cocoonPos, finalSilkInfo)
        end
        local WaterTokenInfo = {
            WaveID = waveID,
            CollectedID = nil,
            LastBounce = true,
            WaveSpeed = waveSpeed
        }
        ActivateTokenClient:InvokeClient(player, "WaterToken", farm, tokenPosition, nil, WaterTokenInfo)
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
        local collectRadius = (dropAreaSize / 2) + 1.7 -- hard coded
        local playerCocoons = CocoonRegistry[player.UserId]
        local wormsCollected = 0
        local collectedIDs = {}

        if playerCocoons then
            for cocoonID, cocoonData in pairs(playerCocoons) do
                local cocoonActive = cocoonData["Active"]
                if (cocoonActive) then
                    local cocoonTargetPos = cocoonData["TargetPos"]
                    local distance = (targetPlant.Position - cocoonTargetPos).Magnitude
                    
                    if (distance <= collectRadius) then
                        wormsCollected += 1
                        table.insert(collectedIDs, cocoonID)
                        
                        local finalSilkInfo = calculateFinalSilk(player, "CollectToken")
                        PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
                        CollectedSilk:FireClient(player, cocoonTargetPos, finalSilkInfo)

                        -- Remove it from the virtual registry
                        playerCocoons[cocoonID] = nil
                    end
                end
            end
        end

        if wormsCollected > 0 then
            PlayerDataModule.addWorm(player, "basicWorm", wormsCollected)
            
            -- Tell the client to play the pink cylinder effect AND delete the physical meshes
            ActivateTokenClient:InvokeClient(player, "CollectToken", farm, tokenPosition, collectedIDs)
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