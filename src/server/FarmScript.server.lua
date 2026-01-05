local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local Zone = require(game.ReplicatedStorage.ZonePluginModule.Zone)

local playerEnteredFarm = game.ServerStorage.BindableEvents:WaitForChild("PlayerEnteredFarm")
local playerExitedFarm = game.ServerStorage.BindableEvents:WaitForChild("PlayerExitedFarm")

function main()
    -- creates a zone based on farmArea part
    local farmArea = workspace.Assets.Blocks.Farms.Farm1.FarmArea
    farmArea.Anchored = true
    farmArea.CanCollide = false
    farmArea.CanQuery = true
    farmArea.CanTouch = true

    -- redo this maybe for instanced farms
    local farm = workspace.Assets.Blocks.Farms.Farm1

    local farmZone = Zone.new(farmArea)

    farmZone.playerEntered:Connect(function(player)
        playerEnteredFarm:Fire(player, farm)
    end)

    farmZone.playerExited:Connect(function(player)
        playerExitedFarm:Fire(player)
    end)
end

main()








--RunService.Heartbeat:Connect(function(deltaTime: number) 
--	local parts = workspace:GetPartsInPart(farmArea)
--	local hitCharacters = {}
--	for i, part in pairs(parts) do
--		if part.Parent:FindFirstChild("Humanoid") and not table.find(hitCharacters, part.Parent) then
--			table.insert(hitCharacters, part.Parent)
--		end
--	end
--	--[[ 
--	fix for multiplayer
--	--]]
--	if #hitCharacters > 0 then
--		for i, character in pairs(hitCharacters) do
--			remoteEvent:FireClient(PlayersService:FindFirstChild(tostring(hitCharacters[i])))
--		end
--	end
--end)

--farmArea.Touched:Connect(function(part: BasePart) 
--	local hitCharacters = {}
--	if part.Parent:FindFirstChild("Humanoid") and not table.find(hitCharacters, part.Parent) then
--		table.insert(hitCharacters, part.Parent)
--	end
--	if #hitCharacters > 0 then
--		for i, character in pairs(hitCharacters) do
--			remoteEvent:FireClient(PlayersService:FindFirstChild(tostring(hitCharacters[i])))
--		end
--	end
--end)

