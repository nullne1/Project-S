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
	self.SpawnCFrame = spawnCFrame
	self.Farm = farm
	self.Player = player
	
	self.WormBody = game:GetService("ServerStorage").Worms:FindFirstChild(self.Type):Clone()
	self.WormBody:PivotTo(self.SpawnCFrame)
	weldModelToPrimary(self.WormBody)

	return self
end

function Worm:despawn()
	if self.WormBody then
		self.WormBody:Destroy()
	end
	setmetatable(self, nil)
	table.clear(self)
end

function Worm:pupate()
	local primaryPart = self.WormBody.PrimaryPart
	local linearTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	while (not self.CocoonFinished and self.WormBody) do
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
	local primaryPart = self.WormBody.PrimaryPart
	
	local wormSize = self.WormBody:GetExtentsSize().Y
	local trunk = self.TargetTree.Trunk
	local treeCFrame = trunk.CFrame
	local branch = self:findBranch()
	local leaf = branch.Leaf

	local floorPos = self.Farm.Floor.Position.Y + wormSize
	
	-- Get current position from the PrimaryPart
	local wormPos = primaryPart.Position

	local distance = (Vector3.new(wormPos.X, 0, wormPos.Z) - Vector3.new(trunk.Position.X, 0, trunk.Position.Z)).Magnitude
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
	local lookAtCFrame = CFrame.lookAt(wormPos, Vector3.new(treeCFrame.X, 4, treeCFrame.Z))
	lookAtCFrame = lookAtCFrame * CFrame.Angles(0, math.rad(90), 0)
	primaryPart.CFrame = lookAtCFrame
	
	-- Get the updated vectors after snapping rotation
	local wormFrontVector = primaryPart.CFrame.RightVector * 2
	local currentRotation = primaryPart.CFrame.Rotation

	-- Target CFrames
	local floorTargetCFrame = CFrame.new(Vector3.new(wormPos.X, floorPos, wormPos.Z)) * currentRotation
	local trunkTargetCFrame = CFrame.new(Vector3.new(trunk.Position.X, 1, trunk.Position.Z) - wormFrontVector) * currentRotation
	local leafTargetCFrame = CFrame.new(Vector3.new(leaf.Position.X, leaf.Position.Y + leaf.Size.X - 0.25, leaf.Position.Z)) * currentRotation

	-- Tween 1: Floor
	local floorTween = TweenService:Create(
		primaryPart, 
		TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
		{CFrame = floorTargetCFrame}
	)
	floorTween:Play()
	floorTween.Completed:Wait()
	
	-- Tween 2: Trunk 
	local trunkTween = TweenService:Create(
		primaryPart, 
		movementTweenInfo, 
		{CFrame = trunkTargetCFrame}
	)
	trunkTween:Play()
	trunkTween.Completed:Wait()
	
	-- Tween 3: Leaf
	local leafTween = TweenService:Create(
		primaryPart, 
		linearTweenInfo, 
		{CFrame = leafTargetCFrame}
	)
	leafTween:Play()
	leafTween.Completed:Wait()
end

function Worm:findBranch()
	local branches = self.TargetTree.Trunk:GetChildren()
	return branches[math.random(1, #branches)]
end

return Worm
-- local TweenService = game:GetService("TweenService")

-- -- Helper function to tween a Model using PivotTo
-- local function tweenModel(model, tweenInfo, targetCFrame)
-- 	local cframeValue = Instance.new("CFrameValue")
-- 	cframeValue.Value = model:GetPivot()
	
-- 	local connection = cframeValue.Changed:Connect(function(newCFrame)
-- 		if model then
-- 			model:PivotTo(newCFrame)
-- 		end
-- 	end)
	
-- 	local tween = TweenService:Create(cframeValue, tweenInfo, {Value = targetCFrame})
	
-- 	-- Clean up our temporary values when the tween finishes
-- 	tween.Completed:Connect(function()
-- 		connection:Disconnect()
-- 		cframeValue:Destroy()
-- 	end)
	
-- 	return tween
-- end

-- local Worm = {};
-- Worm.__index = Worm

-- function Worm.new(type, speed, spawnCFrame, farm, player)
-- 	local self = setmetatable({}, Worm)
	
-- 	self.Type = type
-- 	self.Speed = speed
-- 	self.SpawnCFrame = spawnCFrame
-- 	self.Farm = farm
-- 	self.Player = player

-- 	-- Removed .Body since the whole model is the WormBody now
-- 	self.WormBody = game:GetService("ServerStorage").Worms.BasicWorm:Clone()
	
-- 	-- Use PivotTo instead of setting .CFrame
-- 	self.WormBody:PivotTo(self.SpawnCFrame)

-- 	return self
-- end

-- function Worm:despawn()
-- 	if self.WormBody then
-- 		self.WormBody:Destroy()
-- 	end
-- 	setmetatable(self, nil)
-- 	table.clear(self)
-- end

-- function Worm:pupate()
-- 	local linearTweenInfo = TweenInfo.new(
-- 		0.2,
-- 		Enum.EasingStyle.Linear,
-- 		Enum.EasingDirection.In
-- 	)

-- 	while (not self.CocoonFinished and self.WormBody) do
-- 		local orientationChange = math.random(0, 1)
-- 		local degreeChange = math.rad(math.random(0, 90))
		
-- 		local currentCFrame = self.WormBody:GetPivot()
-- 		local targetCFrame
		
-- 		if (orientationChange == 0) then
-- 			targetCFrame = currentCFrame * CFrame.Angles(0, degreeChange, 0)
-- 		else
-- 			targetCFrame = currentCFrame * CFrame.Angles(0, 0, degreeChange)
-- 		end
		
-- 		-- Use the helper function to tween the model
-- 		local pupateTween = tweenModel(self.WormBody, linearTweenInfo, targetCFrame)
-- 		pupateTween:Play()
-- 		pupateTween.Completed:Wait()                 
-- 	end
-- end

-- function Worm:goToLeaf()
-- 	local wormSize = self.WormBody:GetExtentsSize().Y

-- 	local trunk = self.TargetTree.Trunk
-- 	local treeCFrame = trunk.CFrame
-- 	local branch = self:findBranch()
-- 	local leaf = branch.Leaf

-- 	local floorPos = self.Farm.Floor.Position.Y + wormSize
	
-- 	local currentPivot = self.WormBody:GetPivot()
-- 	local wormPos = currentPivot.Position

-- 	local distance = (Vector3.new(wormPos.X, 0, wormPos.Z) - Vector3.new(trunk.Position.X, 0, trunk.Position.Z)).Magnitude
-- 	local movementTweenInfo = TweenInfo.new(
-- 		(distance / 14) / self.Speed,
-- 		Enum.EasingStyle.Linear,
-- 		Enum.EasingDirection.In
-- 	)

-- 	local linearTweenInfo = TweenInfo.new(
-- 		1, 
-- 		Enum.EasingStyle.Linear, 
-- 		Enum.EasingDirection.In
-- 	)

-- 	-- worm rotation setup
-- 	local lookAtCFrame = CFrame.lookAt(wormPos, Vector3.new(treeCFrame.X, 4, treeCFrame.Z))
-- 	lookAtCFrame = lookAtCFrame * CFrame.Angles(0, math.rad(90), 0)
	
-- 	self.WormBody:PivotTo(lookAtCFrame)
	
-- 	local updatedPivot = self.WormBody:GetPivot()
-- 	local wormFrontVector = updatedPivot.RightVector * 2
-- 	local currentRotation = updatedPivot.Rotation

-- 	-- Target CFrames
-- 	local floorTargetCFrame = CFrame.new(Vector3.new(wormPos.X, floorPos, wormPos.Z)) * currentRotation
-- 	local trunkTargetCFrame = CFrame.new(Vector3.new(trunk.Position.X, 1, trunk.Position.Z) - wormFrontVector) * currentRotation
-- 	local leafTargetCFrame = CFrame.new(Vector3.new(leaf.Position.X, leaf.Position.Y + leaf.Size.X - 0.25, leaf.Position.Z)) * currentRotation


-- 	-- SEQUENCE 1: Floor
-- 	local floorTween = tweenModel(
-- 		self.WormBody, 
-- 		TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
-- 		floorTargetCFrame
-- 	)
-- 	floorTween:Play()
-- 	floorTween.Completed:Wait()
	
-- 	-- SEQUENCE 2: Trunk 
-- 	-- (Created AFTER the floor tween finishes so it grabs the new starting position)
-- 	local trunkTween = tweenModel(
-- 		self.WormBody, 
-- 		movementTweenInfo, 
-- 		trunkTargetCFrame
-- 	)
-- 	trunkTween:Play()
-- 	trunkTween.Completed:Wait()
	
-- 	-- SEQUENCE 3: Leaf
-- 	-- (Created AFTER the trunk tween finishes)
-- 	local leafTween = tweenModel(
-- 		self.WormBody, 
-- 		linearTweenInfo, 
-- 		leafTargetCFrame
-- 	)
-- 	leafTween:Play()
-- 	leafTween.Completed:Wait()
-- end

-- function Worm:findBranch()
-- 	local branches = self.TargetTree.Trunk:GetChildren()
-- 	return branches[math.random(1, #branches)]
-- end

-- return Worm