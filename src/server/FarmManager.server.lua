local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local Zone = require(ReplicatedStorage.ZonePluginModule.Zone)
local TreeModule = require(ReplicatedStorage.Shared.TreeModule)

local playerEnteredFarm = ServerStorage.BindableEvents:WaitForChild("PlayerEnteredFarm")
local playerExitedFarm = ServerStorage.BindableEvents:WaitForChild("PlayerExitedFarm")
local TreeDespawned = ServerStorage.BindableEvents.TreeDespawned

local farmsFolder = workspace.Assets.Parts.Farms
local treeTemplates = ServerStorage.Bushes:GetChildren()

local rng = Random.new()
local MAX_TREES_PER_ZONE = 50
local MIN_SPACING = 10	
local TREE_DROP_RADIUS = 10

local function zoneSetup() 
	local farmDict = {}
	for _, farm in ipairs(farmsFolder:GetChildren()) do
    	-- creates a zone based on farmArea part
		local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
		local farmArea = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].FarmArea
		farmArea.Anchored = true
		farmArea.CanCollide = false
		farmArea.CanQuery = true
		farmArea.CanTouch = true

		-- redo this maybe for instanced farms

		local farmZone = Zone.new(farmArea)
		farmArray = {}
		farmZone.playerEntered:Connect(function(player)
			playerEnteredFarm:Fire(player, farm)
		end)

		farmZone.playerExited:Connect(function(player)
			playerExitedFarm:Fire(player, farm)
		end)
	end
end

local function spawnTreeTween(mesh)
	local spawnTween = TweenService:Create(mesh, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Transparency = 0})
	spawnTween:Play()
end

local function getRandomPointInCylinder(farmFloor)
	-- SWAPPED AXES for a flat Roblox Cylinder: 
	-- Y is now used for the wide radius
	local radius = farmFloor.Size.Y / 2 - TREE_DROP_RADIUS

	local angle = rng:NextNumber() * math.pi * 2
	local dist = radius * math.sqrt(rng:NextNumber())

	-- X is now used to push the tree up to the flat top surface
	-- Y and Z are used for the wide circular spread
	local offset = Vector3.new(farmFloor.Size.X - 6.4, math.cos(angle) * dist, math.sin(angle) * dist)

	return farmFloor.CFrame * offset
end

local function getValidSpawnPoint(zonePart, currentZoneTrees)
	local testPos = getRandomPointInCylinder(zonePart)
	local isTooClose = false

	-- Check distance against OTHER trees currently tracked in this zone
	for _, treeObj in ipairs(currentZoneTrees) do
		if treeObj.Mesh then

			local distance = (treeObj.Mesh.Position - testPos).Magnitude
			if distance < MIN_SPACING then
				isTooClose = true
				break
			end
		end
	end

	if not isTooClose then
		return Vector3.new(testPos.X, testPos.Y - 3.8, testPos.Z)
	end

	return nil 
end

local activeTrees = {}

local function spawnInitialTrees()
	-- make load time depend on if every zone is fully filled by making dictionary of zones with true or false
	local duration = 5
	local start_time = os.time()
	local end_time = start_time + duration
	while true do
		for _, zoneFolder in ipairs(farmsFolder:GetChildren()) do
			local zone = zoneFolder.Floor
			-- Ensure a table exists for this zone
			if not activeTrees[zone] then
				activeTrees[zone] = {}
			end

			local currentZoneTrees = activeTrees[zone]

			-- 1. Clean up the table (remove trees that despawned or died)

			-- 2. Spawn a new tree if the zone isn't full
			if #currentZoneTrees < MAX_TREES_PER_ZONE then
				local spawnPos = getValidSpawnPoint(zone, currentZoneTrees)
				if spawnPos then
					local template = treeTemplates[math.random(1, #treeTemplates)]

					-- Handle rotation to keep trees upright and varied
					local originalRotation = template:GetPivot().Rotation
					local finalCFrame = CFrame.new(spawnPos) * originalRotation

					-- Create the object using our OOP module
					local newTree = TreeModule.new(template, finalCFrame, zone.Parent)
					spawnTreeTween(newTree.Mesh)
					
					-- Store it in our tracking table
					table.insert(currentZoneTrees, newTree)
				end
			end
			--print(#currentZoneTrees)
		end
		if os.time() >= end_time then
        	break -- Exit the loop
    	end
		task.wait()
	end
end

local function replaceTree(farm)
    local farmFloor = farm.Floor
    
    if not activeTrees[farmFloor] then
        activeTrees[farmFloor] = {}
    end
    
    local currentZoneTrees = activeTrees[farmFloor]
	for i, treeObj in ipairs(currentZoneTrees) do
		if next(treeObj) == nil then
			table.remove(currentZoneTrees, i)
		end
	end

	local start_time = os.time()
	local duration = 0.1
	local end_time = start_time + duration
	while (#currentZoneTrees < MAX_TREES_PER_ZONE) do
        local spawnPos = getValidSpawnPoint(farmFloor, currentZoneTrees)
        if spawnPos then
            local template = treeTemplates[math.random(1, #treeTemplates)]
            local originalRotation = template:GetPivot().Rotation
            local finalCFrame = CFrame.new(spawnPos) * originalRotation
            
            local newTree = TreeModule.new(template, finalCFrame, farmFloor.Parent)
			spawnTreeTween(newTree.Mesh)
            table.insert(currentZoneTrees, newTree)
        end
		if os.time() >= end_time then
        	break -- Exit the loop
    	end
		task.wait()
	end
end

local function farmSetup()
	zoneSetup()
	spawnInitialTrees()
	TreeDespawned.Event:Connect(replaceTree)
end

farmSetup()
