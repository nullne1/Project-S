local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(ReplicatedStorage.Shared.CocoonModule);
local Zone = require(ReplicatedStorage.ZonePluginModule.Zone)

local CocoonStart = game:GetService("ServerStorage").BindableEvents.CocoonStart
local CocoonFinished = game:GetService("ServerStorage").BindableEvents.CocoonFinished


local Worm = {};

Worm.__index = Worm

function Worm.new(name : string, speed : number, spawnCFrame : CFrame, farm : Model, player : string) : table
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
	Worm.goToLeaf(wormBody, self.Farm)
	Worm.pupate(wormBody, self.Farm)
end

function Worm.pupate(wormBody : Part, farm : Model) : nil
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	-- fire cocoon event
	CocoonStart:Fire(wormBody, farm)

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

function Worm.goToLeaf(wormBody : Part, farm : Model) : nil
	local linearTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
	local wormSize = wormBody.Size.Y

	-- get tree info
	local trunk = farm.Tree.Trunk
	local treeCFrame = trunk.CFrame
	local branch = Worm.findBranch(farm)
	local leaf = branch.Leaf

	local treeTarget = CFrame.new(treeCFrame.X, 1, treeCFrame.Z)
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
end

function Worm.findBranch(farm : Model) : Part
	local branches = farm.Tree.Trunk:GetChildren()
	return branches[math.random(1, #branches)]
end

function Worm.createWorm(spawnCFrame : CFrame) : Part
	local wormBody = Instance.new("Part")
	local eyes = Instance.new("Decal")
	
	wormBody.Anchored = true
	wormBody.CanCollide = false
	wormBody.Shape = "Cylinder"
	wormBody.Size = Vector3.new(3, 1, 1)
    wormBody.Color = Color3.fromHex("#D5DCCE")
	wormBody.Material = "Carpet"
	wormBody.TopSurface = Enum.SurfaceType.Smooth
	wormBody.BottomSurface = Enum.SurfaceType.Smooth
	wormBody.Parent = workspace.Assets.Blocks.Worms
    wormBody.CFrame = spawnCFrame
	
	eyes.Texture = "http://www.roblox.com/asset/?id=885449864"
	eyes.Face = Enum.NormalId.Right
	eyes.Parent = wormBody
	
	return wormBody
end

return Worm
