local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)

local GetPlayerData = ReplicatedStorage.RemoteFunctions.GetPlayerData

GetPlayerData.OnServerInvoke = function(player, data)
	return PlayerDataModule.getBasicData(player, data)
end


