local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local WormModule = require(game:GetService("ReplicatedStorage").Shared.WormModule)

local playerEnteredFarm = ServerStorage.BindableEvents:WaitForChild("PlayerEnteredFarm")
local playerExitedFarm = ServerStorage.BindableEvents:WaitForChild("PlayerExitedFarm")
		

function setupSpawner(spawner)
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
    spawner.Activated:Connect(function()
        -- Check our dictionary to see if the person who clicked is currently in a farm
        local character = spawner.Parent 
        local player = game.Players:GetPlayerFromCharacter(character)
        local farm

        if player then 
            farm = playerCurrentFarm[player]
        end

        if farm then
            -- They are inside! Spawn the worm for THEM, in THEIR farm.
            local worm = WormModule.new("name", 2, spawner.Handle.CFrame, farm, player)
            worm:start()
        else
            print("not in farm")
        end
    end)

    -- Clean up if they leave the game entirely
    game.Players.PlayerRemoving:Connect(function(player)
        playerCurrentFarm[player] = nil
    end)
end


CollectionService:GetInstanceAddedSignal("WormSpawner"):Connect(setupSpawner)
