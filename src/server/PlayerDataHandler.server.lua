local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)

local InitializeInventory = ReplicatedStorage:WaitForChild("RemoteEvents").InitializeInventory

local DataStore = DataStoreService:GetDataStore("3")
local MY_KEY = "User_93142234"

local DEFAULT_DATA = {
    -- silk
    silk = 0,
    items = {},
    silkWorms = {basicWorm = math.huge},
    peristentWorms = {basicWorm = math.huge},
    flatSilk = 50,

    critChance = 0.05,
    critBonus = 2,
    spawnSpeed = 1 / 20,

    lastFarmEntered = nil
}

Players.PlayerAdded:Connect(function(player)
    local key = "User_" .. player.UserId
    local success, result = pcall(function()
        return DataStore:GetAsync(key)
    end)
    
    
    if (success and not result) then
        -- first time playing
        PlayerDataModule.setData(player, DEFAULT_DATA)
        InitializeInventory:FireClient(player)

        local MainGui = player.PlayerGui:WaitForChild("MainGui")
        -- fix this!! -------------------------------------------------------
        local SilkText = MainGui.DataFrame.SilkText
        local WormsText = MainGui.DataFrame.WormsText

        SilkText.Text = 0
        WormsText.Text = 10

        print("Set Default Data for " .. player.UserId)
    elseif success and result then
        result["silkWorms"] = table.clone(result["peristentWorms"])
        PlayerDataModule.setData(player, result)
        InitializeInventory:FireClient(player)

        local MainGui = player.PlayerGui:WaitForChild("MainGui")
        -- fix this!! -------------------------------------------------------
        local SilkText = MainGui.DataFrame.SilkText
        local WormsText = MainGui.DataFrame.WormsText

        SilkText.Text = result["silk"]
        WormsText.Text = result["silkWorms"]["basicWorm"]

        print("Loaded existing data for " .. player.UserId)
    else
        warn("Failed to load data for", player.Name)
        player:Kick("Data load failed. Please rejoin.")
    end

    -- custom data
    if (player.UserId == 93142234) then
        DataStore:SetAsync(key, PlayerDataModule.getData(player))
        local success, result = pcall(function()
            return DataStore:GetAsync(MY_KEY)
        end)
        local MainGui = player.PlayerGui:WaitForChild("MainGui")
        result["silkWorms"]["basicWorm"] = math.huge
        result["silkWorms"]["specialWorm"] = 0
        result["spawnSpeed"] = 1/20
        result["lastFarmEntered"] = nil
        PlayerDataModule.setData(player, result)

                -- fix this!! -------------------------------------------------------
        local SilkText = MainGui.DataFrame.SilkText
        local WormsText = MainGui.DataFrame.WormsText

        SilkText.Text = result["silk"]
        WormsText.Text = result["silkWorms"]["basicWorm"]
    end
    -- print PlayerDataModule
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

local function removePlayerEntities(player)
    local playerTag = "OwnedBy_" .. tostring(player.UserId)
    local playerEntities = CollectionService:GetTagged(playerTag)
    
    for index, entity in ipairs(playerEntities) do
        print(entity)
        entity:Destroy()
    end
end

local function onPlayerRemoving(player)
    removePlayerEntities(player)
    local key = "User_" .. player.UserId
    local success, err = pcall(function()
        print(PlayerDataModule.getData(player))
		DataStore:SetAsync(key, PlayerDataModule.getData(player))
	end)
	
	if (not success) then
		warn("Could not save data: " .. err)
	end
    PlayerDataModule.removeData(player)
end

Players.PlayerRemoving:Connect(onPlayerRemoving)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        -- Wrap in a coroutine so all players save simultaneously, bypassing the 30-second shutdown limit
        coroutine.wrap(onPlayerRemoving)(player)
    end
end)


-- local function simpleDeepCopy(original)
--     local copy = {}
    
--     for key, value in pairs(original) do
--         -- If the value is another table, pause and copy that one too!
--         if type(value) == "table" then
--             copy[key] = simpleDeepCopy(value)
--         else
--             -- Otherwise, just copy the raw value
--             copy[key] = value
--         end
--     end
    
--     return copy
-- end