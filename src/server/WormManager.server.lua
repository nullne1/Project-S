local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local WormModule = require(game:GetService("ReplicatedStorage").Shared.WormModule)

local playerEnteredFarm = ServerStorage.BindableEvents:WaitForChild("PlayerEnteredFarm")
local playerExitedFarm = ServerStorage.BindableEvents:WaitForChild("PlayerExitedFarm")
		
local activatedEvent

function setupSpawner(spawner : Model) : nil
    -- setup basket activation on farm entered
    playerEnteredFarm.Event:Connect(function(player, farm)
        activatedEvent = spawner.Activated:Connect(function()
            local worm = WormModule.new("name", 1, spawner.Handle.CFrame, farm, player)
            worm:start()
        end)
    end)

    -- setup spawner deactivation on farm exited
    playerExitedFarm.Event:Connect(function()
        if activatedEvent then
            activatedEvent:Disconnect()
            activatedEvent = nil
        end
    end)
end

CollectionService:GetInstanceAddedSignal("WormSpawner"):Connect(setupSpawner)
