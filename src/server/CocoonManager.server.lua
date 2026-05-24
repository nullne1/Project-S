local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)
local PlantRegistry = require(ReplicatedStorage.Shared.GameData.PlantRegistry)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk
local CollectedWorm = ReplicatedStorage.RemoteEvents.CollectedWorm

local function calculateFinalSilk(player)
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

CocoonStart.Event:Connect(function(type, wormModel, farm, player, targetPlant, wormCFrame)
    local cocoon = CocoonModule.new(wormModel, farm, player, targetPlant, wormCFrame)
    PlayerData.assignEntityToPlayer(player, cocoon.Ball)
    local plantData = PlantRegistry[targetPlant]

    -- detect if cocoon is last
    local lastCocoon
    if (plantData["cocoonUses"] == 1) then
		plantData["cocoonUses"] = 0
		lastCocoon = true
	else
		plantData["cocoonUses"] -= 1
		lastCocoon = false
	end

    -- detect player
    local notCollected = true
    local canBeCollected
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and canBeCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(player)) then
            notCollected = false
            
            -- calculate final silk amount from player data
            local finalSilkInfo = calculateFinalSilk(player)
            PlayerData.addWorm(player, type)
            PlayerData.addSilk(player, finalSilkInfo["finalSilk"])
            
            CollectedSilk:FireClient(player, cocoon.Ball.Position, finalSilkInfo)
            cocoon:despawn()
        end
    end)

    -- start pupating and despawn plant if its the last
    cocoon:spinCocoon()
    CocoonFinished:Fire(wormModel)
    cocoon:launch()
    canBeCollected = true
	if (lastCocoon) then
		plantData["module"]:Despawn(player)
	end
end)