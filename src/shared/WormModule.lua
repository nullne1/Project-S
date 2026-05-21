local TweenService = game:GetService("TweenService")

local Worm = {};
Worm.__index = Worm

local function weldModelToPrimary(model)
	local primaryPart = model.PrimaryPart
	if not primaryPart then 
		warn("Model does not have a PrimaryPart assigned!")
		return 
	end

	-- Loop through everything inside the model
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primaryPart then
			-- Create a new WeldConstraint
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = primaryPart
			weld.Part1 = part
			weld.Parent = primaryPart
			
			-- CRITICAL: Unanchor the child part so it can follow the weld
			part.Anchored = false 
		end
	end
	
	-- Ensure the PrimaryPart is the only thing Anchored
	primaryPart.Anchored = true
end

function Worm.new(type, speed, spawnCFrame, farm, player)
	local self = setmetatable({}, Worm)
	
	self.Type = type
	self.Speed = speed
	self.Farm = farm
	self.Player = player
	
	self.Model = game:GetService("ServerStorage").Worms:FindFirstChild(self.Type):Clone()
	self.Model.Parent = workspace.Assets.Parts.Worms
	self.Model:PivotTo(spawnCFrame)
	weldModelToPrimary(self.Model)

	self.Body = self.Model.Body

	return self
end

function Worm:despawn()
	if self.Model then
		self.Model:Destroy()
	end
	setmetatable(self, nil)
	table.clear(self)
end

function Worm:pupate()
	local primaryPart = self.Model.PrimaryPart
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	while (not self.CocoonFinished and self.Model) do
		local orientationChange = math.random(0, 1)
		local degreeChange = math.rad(math.random(0, 90))
		
		local currentCFrame = primaryPart.CFrame
		local targetCFrame
		
		if (orientationChange == 0) then
			targetCFrame = currentCFrame * CFrame.Angles(0, degreeChange, 0)
		else
			targetCFrame = currentCFrame * CFrame.Angles(0, 0, degreeChange)
		end
		
		-- Tween the PrimaryPart directly!
		local pupateTween = TweenService:Create(primaryPart, linearTweenInfo, {CFrame = targetCFrame})
		pupateTween:Play()
		pupateTween.Completed:Wait()                 
	end
end

function Worm:goToLeaf()
	-- The part we will be animating
	local primaryPart = self.Model.PrimaryPart
	
	local wormSize = self.Model:GetExtentsSize().Y

	local floorPos = self.Farm.Floor.Position.Y + wormSize + 0.5
	
	-- Get current position from the PrimaryPart
	local wormPos = primaryPart.Position

	local distance = (Vector3.new(wormPos.X, 0, wormPos.Z) - Vector3.new(self.TargetTree.Position.X, 0, self.TargetTree.Position.Z)).Magnitude
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

	-- Rotate the worm to face the tree instantly
	local lookAtCFrame = CFrame.lookAt(wormPos, Vector3.new(self.TargetTree.CFrame.X, 4, self.TargetTree.CFrame.Z))
	lookAtCFrame = lookAtCFrame * CFrame.Angles(0, math.rad(90), 0)
	primaryPart.CFrame = lookAtCFrame
	
	-- Get the updated vectors after snapping rotation
	local wormFrontVector = primaryPart.CFrame.RightVector * 2
	local currentRotation = primaryPart.CFrame.Rotation

	-- Target CFrames
	local floorTargetCFrame = CFrame.new(Vector3.new(wormPos.X, floorPos, wormPos.Z)) * currentRotation
	local trunkTargetCFrame = CFrame.new(Vector3.new(self.TargetTree.Position.X, wormPos.Y - 2, self.TargetTree.Position.Z)) * currentRotation

	-- Tween 1: Floor
	local floorTween = TweenService:Create(
		primaryPart, 
		TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
		{CFrame = floorTargetCFrame}
	)
	floorTween:Play()
	floorTween.Completed:Wait()

	-- self:animate()
	
	-- Tween 2: Trunk 
	local trunkTween = TweenService:Create(
		primaryPart, 
		movementTweenInfo, 
		{CFrame = trunkTargetCFrame}
	)
	trunkTween:Play()
	trunkTween.Completed:Wait()
end

function Worm:findBranch()
	local branches = self.TargetTree.Trunk:GetChildren()
	return branches[math.random(1, #branches)]
end

return Worm