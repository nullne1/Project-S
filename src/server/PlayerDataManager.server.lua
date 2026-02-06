local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerDataModule)

local DataStore = DataStoreService:GetDataStore("CocoonStats")

local DEFAULT_DATA = {
    balls = 0
}

Players.PlayerAdded:Connect(function(player)
    local key = "User " .. player.UserId
    local savedCocoons = 0

    local success, result = pcall(function()
        return DataStore:GetAsync(key)
    end)

    if (success and not result) then
        PlayerData.setData(player, DEFAULT_DATA)
        print("Loaded data for", DEFAULT_DATA)
    elseif success and result then
        PlayerData.setData(player, {balls = result})
        print("Loaded data for", player.name)
    else
        warn("Failed to load data for", player.Name)
        player:Kick("Data load failed. Please rejoin.")
    end

    -- local leaderstats = Instance.new("Folder")
    -- leaderstats.Name = "leaderstats"
    -- leaderstats.Parent = player

    -- local cocoons = Instance.new("IntValue")
    -- cocoons.Name = "Cocoons"
    -- cocoons.Value = savedCocoons
    -- cocoons.Parent = leaderstats
end)

Players.PlayerRemoving:Connect(function(player)
    local key = "User_" .. player.UserId
    local success, err = pcall(function()
		DataStore:SetAsync(key, PlayerData.getData(player))
	end)
	
	if (not success) then
		warn("Could not save data: " .. err)
	end

    PlayerData.removeData(player)
    -- local currentCocoons = player.leaderstats.Cocoons.Value
end)