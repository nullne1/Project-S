local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WormModule = require(game:GetService("ReplicatedStorage").Shared.WormModule)
local PlantRegistry = require(ReplicatedStorage.Shared.GameData.PlantRegistry)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)
local WormRegistry = require(ReplicatedStorage.Shared.GameData.WormRegistry)

local playerEnteredFarm = ServerStorage.BindableEvents.PlayerEnteredFarm
local playerExitedFarm = ServerStorage.BindableEvents.PlayerExitedFarm
local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local SpawnReady = ServerStorage.BindableEvents.SpawnReady


local playerCooldowns = {}
local activeWorms = {}

local function getWorm(player)
    local availableWorms = PlayerData.getBasicData(player, "silkWorms")
    for key, value in availableWorms do
        if value > 0 then
            return key
        end
    end

    return nil
end

local function findPlant(farm)
    -- look for available plant
    local plantArray = farm.Plants:GetChildren()
    -- fill array with indexes of plantArray
	local indexArray = {}
	for i = 1, #plantArray, 1 do
		indexArray[i] = i
	end

    local plantModule
    local foundPlantData
	for i = 1, #plantArray, 1 do
		-- pick a random plant's indexes, then delete its index so it doesn't get picked again in the case that the plant is dead
		local randomIndexIndex = math.random(1, #indexArray)
		local randomIndex = indexArray[randomIndexIndex]
		table.remove(indexArray, randomIndexIndex)
		local plantModel = plantArray[randomIndex]
		plantData = PlantRegistry[plantModel]
		if (plantData and plantData["uses"] > 0) then
			plantModule = plantData["module"]
            foundPlantData = plantData
			break
		end
	end

    return plantModule, foundPlantData
end

local function startWorm(spawner, player, farm)
    local wormType = getWorm(player)
    local plantModule, plantData = findPlant(farm)
    if (plantModule and wormType) then
        -- all conditions are met, spawn worm
        PlayerData.useWorm(player, wormType)
        plantData["uses"] -= 1

        -- spawn worm and insert
        local worm = WormModule.new(wormType, 1, spawner.Handle.CFrame, farm, player)
        PlayerData.assignEntityToPlayer(player, worm.Model)
        worm.TargetPlant = plantModule.Mesh

        if not activeWorms[player] then
            activeWorms[player] = {}
        end
        table.insert(activeWorms[player], worm)

        -- on cocoon finished, despawn worm and remove it from activeWorms
        local cocoonConnection
		cocoonConnection = CocoonFinished.Event:Connect(function(finishedWormModel)
			if (finishedWormModel == worm.Model) then

                -- loops backwards through player's worms and searches for the worm that finished
                local playerWorms = activeWorms[player]
                if playerWorms then
                    for i = #playerWorms, 1, -1 do
                        if playerWorms[i] == worm then
                            table.remove(playerWorms, i)
                            break -- Stop searching once we find and delete it
                        end
                    end
                end
                -- despawn worm
                if (worm) then
				    worm:despawn()
                end
                -- break connection
                if cocoonConnection then
                    cocoonConnection:Disconnect()
                    cocoonConnection = nil
                end
            end
		end)

        -- run tweens on separate thread
        task.spawn(function()
            if (worm) then
                worm:goToLeaf()
                pcall(function()
                    local tokenSkills = WormRegistry.Worms[wormType]["TokenSkills"]
                    if (tokenSkills) then
                        CocoonStart:Fire(wormType, worm.Model, worm.Farm, worm.Player, worm.TargetPlant, worm.Model.PrimaryPart.CFrame, tokenSkills)
                    end
                end)
                worm:pupate()
            end
        end)
	else
        if (not plantModule) then
            print("no available plant found")
        elseif (not wormType) then
            print("no silkworms left")
        else
            print("error")
        end
    end
end

local function onSpawn(player, spawner, playerCurrentFarm)
    -- Check our dictionary to see if the person who clicked is currently in a farm
    local farm
    
    if player then 
        farm = playerCurrentFarm[player]
    end

    if farm then
        -- They are inside! Spawn the worm for THEM, in THEIR farm.
        startWorm(spawner, player, farm)
    else
        print("not in farm")
    end
end

local function setupSpawner(spawner)
    local playerCurrentFarm = {} 
    -- 1. Track who is inside which farm

    playerEnteredFarm.Event:Connect(function(player, farm)
        -- Save the farm this specific player is standing in
        playerCurrentFarm[player] = farm 
    end)

    playerExitedFarm.Event:Connect(function(player, farm)
        -- If they leave the farm they were tracked in, clear their status
        if playerCurrentFarm[player] == farm then
            playerCurrentFarm[player] = nil
        end
    end)

    -- 2. Connect the spawner completely separately, just ONCE.
    local releasedPress

    spawner.Activated:Connect(function()
        local player = game.Players:GetPlayerFromCharacter(spawner.Parent)

        releasedPress = false
        while not releasedPress do
            local currentTime = os.clock()
            local lastSpawnTime = playerCooldowns[player.UserId] or 0
            local spawnSpeed = PlayerData.getBasicData(player, "spawnSpeed")
            
            -- if time elapsed since time of spawn is greater than spawnSpeed
            if currentTime - lastSpawnTime >= spawnSpeed then
                
                -- Put them on cooldown immediately
                playerCooldowns[player.UserId] = currentTime
                
                -- Spawn the worm
                onSpawn(player, spawner, playerCurrentFarm)

                -- Start a background timer to fire the "Ready" event
                task.delay(spawnSpeed, function()
                    SpawnReady:Fire(player)
                end)
            end
            
            task.wait() -- Wait one frame before checking the button hold again
        end
    end)
    spawner.Deactivated:Connect(function() releasedPress = true end)
    spawner.Unequipped:Connect(function() releasedPress = true end)

    -- Clean up if they leave the game entirely
    game.Players.PlayerRemoving:Connect(function(player)
        local playerWorms = activeWorms[player]
        
        if playerWorms then
            -- 1. Loop backwards (always best practice when destroying lists)
            for i = #playerWorms, 1, -1 do
                local wormObject = playerWorms[i]
                
                -- 2. DEFENSIVE CHECK: Is this a real object, and does it actually have a despawn method?
                if type(wormObject) == "table" and wormObject.despawn then
                    wormObject:despawn()
                end
                
                -- 3. Safely delete the slot, whether it was an empty shell or a real worm
                table.remove(playerWorms, i)
            end
        end
        
        -- 4. completely erase the player's key from the global dictionary
        activeWorms[player] = nil
        playerCurrentFarm[player] = nil
    end)
end




CollectionService:GetInstanceAddedSignal("WormSpawner"):Connect(setupSpawner)
