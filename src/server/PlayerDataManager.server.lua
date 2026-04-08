local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerDataModule)

local DataStore = DataStoreService:GetDataStore("1")

local DEFAULT_DATA = {
    -- silk
    silk = 0,
    silkWorms = {basicWorm = 10},
    peristentWorms = {basicWorm = 10},
    flatSilk = 50,

    critChance = 0.05,
    critBonus = 2,
    spawnSpeed = 1 / 10
}

Players.PlayerAdded:Connect(function(player)
    local key = "User_" .. player.UserId
    local success, result = pcall(function()
        return DataStore:GetAsync(key)
    end)
    
    
    if (success and not result) then
        PlayerData.setData(player, DEFAULT_DATA)
        print("Loaded data for " .. player.UserId, DEFAULT_DATA)
    elseif success and result then
        result["silkWorms"] = table.clone(result["peristentWorms"])
        PlayerData.setData(player, result)
        print("Loaded data for " .. player.UserId)
    else
        warn("Failed to load data for", player.Name)
        player:Kick("Data load failed. Please rejoin.")
    end
    -- local success, errorMessage = pcall(function()
    --     -- Ask Roblox for the first "page" of keys
    --     local pages = DataStore:ListKeysAsync()

    --     while true do
    --         -- Grab the keys from the current page
    --         local keys = pages:GetCurrentPage()
            
    --         for _, key in ipairs(keys) do
    --             -- We have the key name (e.g., "User_123"), now we fetch the actual data
    --             local data = DataStore:GetAsync(key.KeyName)
                
    --             print("Key: " .. key.KeyName)
    --             print(data) -- Prints the table/dictionary
    --             print("-------------------------")
                
    --             -- CRITICAL: You must wait between requests or Roblox will throttle and block you
    --             task.wait(0.5) 
    --         end

    --         -- If we reached the end of the database, break the loop
    --         if pages.IsFinished then
    --             break
    --         end

    --         -- Tell Roblox to load the next page of keys so the loop can continue
    --         pages:AdvanceToNextPageAsync()
    --     end
    -- end)
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

local function simpleDeepCopy(original)
    local copy = {}
    
    for key, value in pairs(original) do
        -- If the value is another table, pause and copy that one too!
        if type(value) == "table" then
            copy[key] = simpleDeepCopy(value)
        else
            -- Otherwise, just copy the raw value
            copy[key] = value
        end
    end
    
    return copy
end