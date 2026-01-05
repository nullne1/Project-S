local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local WormModule = require(game:GetService("ReplicatedStorage").Shared.WormModule);

local playerEnteredFarm = game.ServerStorage.BindableEvents:WaitForChild("PlayerEnteredFarm")
local playerExitedFarm = game.ServerStorage.BindableEvents:WaitForChild("PlayerExitedFarm")
		
local playerInFarm = false
local activatedEvent

function setupBasket(basket : Model) : nil
    -- setup basket activation on farm entered
    playerEnteredFarm.Event:Connect(function(player, farm)
        activatedEvent = basket.Activated:Connect(function()
            local worm = WormModule.new("name", 1, basket.Handle.CFrame, farm)
            worm:start()
        end)
    end)

    -- setup basket deactivation on farm exited
    playerExitedFarm.Event:Connect(function()
        if activatedEvent then
            activatedEvent:Disconnect()
            activatedEvent = nil
        end
    end)
end

CollectionService:GetInstanceAddedSignal("WormSpawner"):Connect(setupBasket)
