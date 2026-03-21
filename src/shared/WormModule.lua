local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local WormFoundTree = ServerStorage.BindableEvents.WormFoundTree

local farmsFolder = workspace.Assets.Parts.Farms

local Worm = {};

Worm.__index = Worm

function Worm.new(name : string, speed : number, spawnCFrame : CFrame, farm : Folder, player : string) : table
	local self = setmetatable({}, Worm)
	
	self.Name = name
	self.Speed = speed
	self.SpawnCFrame = spawnCFrame
	self.Farm = farm
	self.Player = player
	self.NearBranch = false
	
	return self
end

function Worm:start() : nil
	-- create worm
	local wormBody = Worm.createWorm(self.SpawnCFrame)
	CocoonFinished.Event:Connect(function(finishedWormBody)
		if (finishedWormBody == wormBody) then
			wormBody:Destroy()
		end
	end)
	tree = Worm.findTree(self.Farm)
	local tree = Worm.goToLeaf(wormBody, self.Farm, tree)
	Worm.pupate(wormBody, self.Farm, self.Player, tree)
end

function Worm.findTree(farm)
	local treeFound = false
	local tree;
	while (not treeFound) do
		tree = farm.Trees:GetChildren()[(math.random(1, #farm.Trees:GetChildren()))]
		if (tree:GetAttribute("Uses") or 0 > 0 and tree:GetAttribute("IsAlive") or false) then
			treeFound = true
			WormFoundTree:Fire(tree)
			break
		end
		task.wait()
	end
	return tree
end

function Worm.pupate(wormBody, farm, player, tree) : nil
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	-- fire cocoon event
	CocoonStart:Fire(wormBody, farm, player, tree)

	-- makes worm look in different directions, mimicing pupating
	local pupateGoal = {}
	local pupateTween = TweenService:Create(wormBody, linearTweenInfo, pupateGoal)

	local cocoonFinished = false
	while (not cocoonFinished) do
		local orientationChange = math.random(0, 1)
		local degreeChange = math.rad(math.random(0, 90))
		if (orientationChange == 0) then
			pupateGoal = {CFrame = wormBody.CFrame * CFrame.Angles(0, degreeChange, 0)}
		else
			pupateGoal = {CFrame = wormBody.CFrame * CFrame.Angles(0, 0, degreeChange)}
		end
		pupateTween = TweenService:Create(wormBody, linearTweenInfo, pupateGoal)
		pupateTween:Play()
		pupateTween.Completed:Wait()
	end
end

function Worm.goToLeaf(wormBody : Part, farm : Folder, tree)
	local linearTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
	local wormSize = wormBody.Size.Y

	local trunk = tree.Trunk
	local treeCFrame = trunk.CFrame
	local branch = Worm.findBranch(tree)
	local leaf = branch.Leaf

	local floorPos = farm.Floor.Position.Y + wormSize

	-- worm rotation setup
	wormBody.CFrame = CFrame.lookAt(wormBody.Position, Vector3.new(treeCFrame.X, 4, treeCFrame.Z))
	wormBody.CFrame = wormBody.CFrame * CFrame.Angles(0, math.rad(90), 0)
	local wormFrontVector = wormBody.CFrame.RightVector * 2

	local floorTween = TweenService:Create(wormBody, linearTweenInfo, {Position = Vector3.new(wormBody.Position.X, floorPos, wormBody.Position.Z)})
	local trunkTween = TweenService:Create(wormBody, linearTweenInfo, {Position = Vector3.new(trunk.Position.X, 1, trunk.Position.Z) - wormFrontVector})
	-- maybe add branch tween later on to make it look better
	local leafGoal = {
		Position = Vector3.new(leaf.Position.X, leaf.Position.Y + leaf.Size.X - 0.25, leaf.Position.Z),
	}
	local leafTween = TweenService:Create(wormBody, linearTweenInfo, leafGoal)

	floorTween:Play()
	floorTween.Completed:Wait()
	trunkTween:Play()
	trunkTween.Completed:Wait()
	leafTween:Play()
	leafTween.Completed:Wait()
	return tree
end

function Worm.findBranch(tree : Model) : Part
	local branches = tree.Trunk:GetChildren()
	return branches[math.random(1, #branches)]
end

function Worm.createWorm(spawnCFrame : CFrame) : Part
	local wormBody = ServerStorage.Worms.BasicWorm:Clone()
    wormBody.CFrame = spawnCFrame
	wormBody.Parent = workspace.Assets.Parts.Worms
	
	return wormBody
end

return Worm
