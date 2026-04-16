local Worm = {};

Worm.__index = Worm

function Worm.new(type, speed, spawnCFrame, farm, player)
	local self = setmetatable({}, Worm)
	
	self.Type = type
	self.Speed = speed
	self.SpawnCFrame = spawnCFrame
	self.Farm = farm
	self.Player = player

	self.WormBody = game:GetService("ServerStorage").Worms.BasicWorm:Clone().Body
    self.WormBody.CFrame = self.SpawnCFrame

	return self
end

function Worm:despawn()
	self.WormBody:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

function Worm:pupate()
	local TweenService = game:GetService("TweenService")
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

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
	local TweenService = game:GetService("TweenService")
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

return Worm
