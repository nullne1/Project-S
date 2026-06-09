local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantRegistry = require(ReplicatedStorage.Shared.GameData.PlantRegistry)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)

local GetPlayerData = ReplicatedStorage.RemoteFunctions.GetPlayerData
local AssignEntityToPlayer = ReplicatedStorage.RemoteFunctions.AssignEntityToPlayer

local AddWorm = ReplicatedStorage.RemoteEvents.AddWorm
local AddSilk = ReplicatedStorage.RemoteEvents.AddSilk

local CocoonStart = ServerStorage.BindableEvents.CocoonStart

CocoonStart.Event:Connect(function(type, wormModel, farm, player, targetPlant, wormCFrame)
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
