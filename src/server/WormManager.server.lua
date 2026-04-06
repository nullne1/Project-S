local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WormModule = require(game:GetService("ReplicatedStorage").Shared.WormModule)
local TreeRegistry = require(ReplicatedStorage.Shared.TreeRegistry)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)

local playerEnteredFarm = ServerStorage.BindableEvents.PlayerEnteredFarm
local playerExitedFarm = ServerStorage.BindableEvents.PlayerExitedFarm
local CocoonStart = game:GetService("ServerStorage").BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local SpawnReady = ServerStorage.BindableEvents.SpawnReady
local playerCooldowns = {}

local function getWorm(player)
    local availableWorms = PlayerData.getBasicData(player, "silkWorms")
    for key, value in availableWorms do
        if value > 0 then
            return key
        end
    end

    return nil
end

local function findTree(farm)
    -- look for available tree
    local treeArray = farm.Trees:GetChildren()
    -- fill array with indexes of treeArray
	local indexArray = {}
	for i = 1, #treeArray, 1 do
		indexArray[i] = i
	end

    local treeModule
    local foundTreeData
	for i = 1, #treeArray, 1 do
		-- pick a random tree's indexes, then delete its index so it doesn't get picked again in the case that the tree is dead
		local randomIndexIndex = math.random(1, #indexArray)
		local randomIndex = indexArray[randomIndexIndex]
		table.remove(indexArray, randomIndexIndex)
		local treeModel = treeArray[randomIndex]
		treeData = TreeRegistry[treeModel]
		if (treeData["uses"] > 0) then
			treeModule = treeData["module"]
            foundTreeData = treeData
			break
		end
	end

    return treeModule, foundTreeData
end

local function startWorm(spawner, player, farm)
    local wormType = getWorm(player)
    local treeModule, treeData = findTree(farm)
    if (treeModule and wormType) then
        -- all conditions are met, spawn worm
        PlayerData.useWorm(player, wormType)
        treeData["uses"] -= 1
        local worm = WormModule.new(wormType, 2, spawner.Handle.CFrame, farm, player)
        worm.TargetTree = treeModule.Model
		worm.WormBody.Parent = workspace.Assets.Parts.Worms
		CocoonFinished.Event:Connect(function(finishedWormBody)
			if (finishedWormBody == worm.WormBody) then
				worm:despawn()
			end
		end)
        task.spawn(function()
            worm:goToLeaf()
            CocoonStart:Fire(wormType, worm.WormBody, worm.Farm, worm.Player, worm.TargetTree)
            worm:pupate()
        end)
	else
        if (not treeModule) then
            print("no available tree found")
        end
        if (not wormType) then
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

    -- Clean up if they leave the game entirely
    game.Players.PlayerRemoving:Connect(function(player)
        playerCurrentFarm[player] = nil
    end)
end


CollectionService:GetInstanceAddedSignal("WormSpawner"):Connect(setupSpawner)
