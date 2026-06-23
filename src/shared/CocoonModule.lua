local Cocoon = {}
Cocoon.__index = Cocoon
function Cocoon.new(cocoonID, farm, targetPlant, wormCFrame, targetPos)

    local self = setmetatable({}, Cocoon)
	
	self.CocoonID = cocoonID
    self.Farm = farm
	self.TargetPlant = targetPlant
	self.TargetPos = targetPos

	self.Ball = game:GetService("ReplicatedStorage").Balls.BasicBall:Clone()
    self.Ball.Transparency = 1
    self.Ball.Parent = workspace.Assets.Parts.Balls
    self.Ball.CFrame = wormCFrame
	self.Ball.Name = self.CocoonID

    return self
end

function Cocoon:launch()
	local startPos = self.Ball.Position
	local targetPos = self.TargetPos
	
	local timeDuration = 1
	local ARC_HEIGHT_GRAVITY = 100
	local realGravity = workspace.Gravity
	
	local attachment = Instance.new("Attachment", self.Ball)
	local antiGravity = Instance.new("VectorForce", self.Ball)
	antiGravity.Attachment0 = attachment
	antiGravity.RelativeTo = Enum.ActuatorRelativeTo.World
	antiGravity.Enabled = false -- Start disabled
	
	local lift = self.Ball:GetMass() * (realGravity - ARC_HEIGHT_GRAVITY)
	antiGravity.Force = Vector3.new(0, lift, 0)
	antiGravity.Enabled = true
	
	local displacement = targetPos - startPos
	local virtualGravityVector = Vector3.new(0, -ARC_HEIGHT_GRAVITY, 0)
	local antigravity = 0.5 * virtualGravityVector * (timeDuration * timeDuration)
	
	local requiredVelocity = (displacement - antigravity) / timeDuration
	self.Ball.Anchored = false
	self.Ball.AssemblyLinearVelocity = requiredVelocity
	self.Ball.AssemblyAngularVelocity = Vector3.new(5, 5, 5) 

	--print("Floating to target in " .. timeDuration .. " seconds...")

	task.wait(timeDuration - 0.04)

	self.Ball.Anchored = true
	self.Ball.AssemblyLinearVelocity = Vector3.zero
	self.Ball.AssemblyAngularVelocity = Vector3.zero
	self.Ball.Position = targetPos
	antiGravity.Enabled = false
	--print("Launched to:", targetPos)
end

function Cocoon:spinCocoon()
    local linearTweenInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
	)
    local spinCocoonTween = game:GetService("TweenService"):Create(self.Ball, linearTweenInfo, {
		Transparency = 0, 
		Position = Vector3.new(self.Ball.Position.X, self.Ball.Position.Y + 0.5, self.Ball.Position.Z),
		Size = Vector3.new(2, 2, 2)
	})

    spinCocoonTween:Play()
    spinCocoonTween.Completed:Wait()
end

function Cocoon:despawn()
	self.Ball:Destroy()
	setmetatable(self, nil)
    table.clear(self)
end

return Cocoon