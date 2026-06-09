local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)

local GetPlayerData = ReplicatedStorage.RemoteFunctions.GetPlayerData
local AssignEntityToPlayer = ReplicatedStorage.RemoteFunctions.AssignEntityToPlayer

local AddWorm = ReplicatedStorage.RemoteEvents.AddWorm
local AddSilk = ReplicatedStorage.RemoteEvents.AddSilk

GetPlayerData.OnServerInvoke = function(player, data)
	return PlayerData.getBasicData(player, data)
end

AssignEntityToPlayer.OnServerInvoke = function(player, entity)
    return PlayerData.assignEntityToPlayer(player, entity)
end

AddWorm.OnServerEvent:Connect(function(player, type, amount)
	PlayerData.addWorm(player, type, amount)
end)

AddSilk.OnServerEvent:Connect(function(player, amount)
	PlayerData.addSilk(player, amount)
end)