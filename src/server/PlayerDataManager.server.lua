local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local cocoonDataStore = DataStoreService:GetDataStore("CocoonStats")

Players.PlayerAdded:Connect(function(player)
    local key = "User " .. player.UserId
    local savedCocoons = 0

    local success, result = pcall(function()
        return cocoonDataStore:GetAsync(key)
    end)

    if success and result then
        savedCocoons = result
    end

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local cocoons = Instance.new("IntValue")
    cocoons.Name = "Cocoons"
    cocoons.Value = savedCocoons
    cocoons.Parent = leaderstats
end)

Players.PlayerRemoving:Connect(function(player)
    local key = "User_" .. player.UserId
	local currentCocoons = player.leaderstats.Cocoons.Value
    local success, err = pcall(function()
		myDataStore:SetAsync(key, currentCocoons)
	end)
	
	if not success then
		warn("Could not save data: " .. err)
	end
end)