local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local WormFoundTree = ServerStorage.BindableEvents.WormFoundTree

local farm = workspace.Assets.Parts.Farms

local Worm = {};

Worm.__index = Worm

function Worm.new(name, speed, spawnCFrame, farm, player)
	local self = setmetatable({}, Worm)
	
	self.Name = name
	self.Speed = speed
	self.SpawnCFrame = spawnCFrame
	self.Farm = farm
	self.Player = player

	self.WormBody = ServerStorage.Worms.BasicWorm:Clone()
    self.WormBody.CFrame = self.SpawnCFrame

	treeArray = self.Farm.Trees:GetChildren()

	local indexArray = {}
	for i = 1, #treeArray, 1 do
		indexArray[i] = i
	end


	for i = 1, #treeArray, 1 do
		-- pick a random tree's indexes, then delete its index so it doesn't get picked again
		local randomIndexIndex = math.random(1, #indexArray)
		local randomIndex = indexArray[randomIndexIndex]
		table.remove(indexArray, randomIndexIndex)
		treeModel = treeArray[randomIndex]

		local uses = treeModel:GetAttribute("Uses") or 0
		local isAlive = treeModel:GetAttribute("IsAlive") or false
		if (uses > 0 and isAlive) then
			self.TargetTree = treeModel
			WormFoundTree:Fire(self.TargetTree)
			break
		end

	end
	
	return self
end

function Worm:start()
	-- looks for available tree, if not found then stop execution
	if (not self.TargetTree) then
		print("no available tree found")
		setmetatable(self, nil)
    	table.clear(self)
	else
		self.WormBody.Parent = workspace.Assets.Parts.Worms
		CocoonFinished.Event:Connect(function(finishedWormBody)
			if (finishedWormBody == self.WormBody) then
				self.WormBody:Destroy()
				setmetatable(self, nil)
    			table.clear(self)
			end
		end)
		self:goToLeaf()
		self:pupate()
	end
end

function Worm:cocoonStart()
end

-- function Worm:findTree()
-- 	for _, treeModel in ipairs(self.Farm.Trees:GetChildren()) do
-- 		local uses = treeModel:GetAttribute("Uses") or 0
-- 		local isAlive = treeModel:GetAttribute("IsAlive") or false
-- 		if (uses > 0 and isAlive) then
-- 			self.TargetTree = treeModel
-- 			WormFoundTree:Fire(self.TargetTree)
-- 			break
-- 		end
-- 	end
-- 	return self.TargetTree
-- end

function Worm:pupate()
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	-- fire cocoon event
	CocoonStart:Fire(self.WormBody, self.Farm, self.Player, self.TargetTree)

	-- makes worm look in different directions, mimicing pupating
	local pupateGoal = {}
	local pupateTween = TweenService:Create(self.WormBody, linearTweenInfo, pupateGoal)

	while (not self.CocoonFinished and self.WormBody) do
		local orientationChange = math.random(0, 1)
		local degreeChange = math.rad(math.random(0, 90))
		if (orientationChange == 0) then
			pupateGoal = {CFrame = self.WormBody.CFrame * CFrame.Angles(0, degreeChange, 0)}
		else
			pupateGoal = {CFrame = self.WormBody.CFrame * CFrame.Angles(0, 0, degreeChange)}
		end
		pupateTween = TweenService:Create(self.WormBody, linearTweenInfo, pupateGoal)
		pupateTween:Play()

		pupateTween.Completed:Wait()                 
	end
end

function Worm:goToLeaf()
	local wormSize = self.WormBody.Size.Y

	local trunk = self.TargetTree.Trunk
	local treeCFrame = trunk.CFrame
	local branch = self:findBranch()
	local leaf = branch.Leaf

	local floorPos = self.Farm.Floor.Position.Y + wormSize

	local distance = (Vector3.new(self.WormBody.Position.X, 0, self.WormBody.Position.Z) - Vector3.new(trunk.Position.X, 0, trunk.Position.Z)).Magnitude
	local movementTweenInfo = TweenInfo.new(
		(distance / 14) / self.Speed,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	local linearTweenInfo = TweenInfo.new(
		1, 
		Enum.EasingStyle.Linear, 
		Enum.EasingDirection.In
	)

	-- worm rotation setup
	self.WormBody.CFrame = CFrame.lookAt(self.WormBody.Position, Vector3.new(treeCFrame.X, 4, treeCFrame.Z))
	self.WormBody.CFrame = self.WormBody.CFrame * CFrame.Angles(0, math.rad(90), 0)
	local wormFrontVector = self.WormBody.CFrame.RightVector * 2

	local floorTween = TweenService:Create(self.WormBody, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.In ), {Position = Vector3.new(self.WormBody.Position.X, floorPos, self.WormBody.Position.Z)})
	local trunkTween = TweenService:Create(self.WormBody, movementTweenInfo, {Position = Vector3.new(trunk.Position.X, 1, trunk.Position.Z) - wormFrontVector})

	-- maybe add branch tween later on to make it look better
	local leafGoal = {
		Position = Vector3.new(leaf.Position.X, leaf.Position.Y + leaf.Size.X - 0.25, leaf.Position.Z),
	}
	local leafTween = TweenService:Create(self.WormBody, linearTweenInfo, leafGoal)

	floorTween:Play()
	floorTween.Completed:Wait()
	trunkTween:Play()
	trunkTween.Completed:Wait()
	leafTween:Play()
	leafTween.Completed:Wait()
end

function Worm:findBranch()
	local branches = self.TargetTree.Trunk:GetChildren()
	return branches[math.random(1, #branches)]
end

function Worm:createWorm()
	self.WormBody = ServerStorage.Worms.BasicWorm:Clone()
    self.WormBody.CFrame = self.SpawnCFrame
end

return Worm
