local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantRegistry = require(ReplicatedStorage.Shared.GameData.PlantRegistry)
local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)

local CollectedCocoon = ReplicatedStorage.RemoteEvents.CollectedCocoon
local CocoonFinished = ReplicatedStorage.RemoteEvents.CocoonFinished
local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

CollectedCocoon.OnServerEvent:Connect(function(player, type, position)
	-- calculate final silk amount from player data
	local finalSilkInfo = calculateFinalSilk(player)
	PlayerDataModule.addWorm(player, type, 1)
	PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
	
	CollectedSilk:FireClient(player, position, finalSilkInfo)
end)

function calculateFinalSilk(player)
    local flatSilk = PlayerDataModule.getBasicData(player, "flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= PlayerDataModule.getBasicData(player, "critChance")) then
        finalSilk += finalSilk * PlayerDataModule.getBasicData(player, "critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

CocoonFinished.OnServerEvent:Connect(function(player, wormModel, targetPlant)
    local plantData = PlantRegistry[targetPlant]

    -- detect if cocoon is last
    local lastCocoon
    if (plantData["cocoonUses"] == 1) then
		plantData["cocoonUses"] = 0
		lastCocoon = true
	else
        plantData["module"]:depleteUse()
		plantData["cocoonUses"] -= 1
		lastCocoon = false
	end

	if (lastCocoon) then
		plantData["module"]:Despawn(player)
	end
end)
