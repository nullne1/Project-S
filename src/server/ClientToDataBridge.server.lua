local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)

local GetPlayerData = ReplicatedStorage.RemoteFunctions.GetPlayerData
local AssignEntityToPlayer = ReplicatedStorage.RemoteFunctions.AssignEntityToPlayer

GetPlayerData.OnServerInvoke = function(player, data)
	return PlayerDataModule.getBasicData(player, data)
end

AssignEntityToPlayer.OnServerInvoke = function(player, entity)
    return PlayerDataModule.assignEntityToPlayer(player, entity)
end

