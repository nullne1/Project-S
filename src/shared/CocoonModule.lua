local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonActivated = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonActivated
local DropMoth = ReplicatedStorage:WaitForChild("RemoteEvents").DropMoth

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(cocoonID, farm, targetPlant, wormCFrame, targetPos, player, moth)
    local self = setmetatable({}, Cocoon)
	
	self.CocoonID = cocoonID
    self.Farm = farm
	self.TargetPlant = targetPlant
	self.TargetPos = targetPos

	self.Ball = game:GetService("ReplicatedStorage").Balls.BasicBall:Clone()
    self.Ball.CanQuery = false
    self.Ball.Transparency = 1
	self.Ball.Anchored = true
    self.Ball.Parent = workspace.Assets.Parts.Balls
    self.Ball.CFrame = wormCFrame
	self.Ball.Name = self.CocoonID

    self.Moth = moth

	self.CanBeCollected = false

    return self
end

function Cocoon:magnetize(player, shouldDespawn)
    self.Ball.CanTouch = false
    self.Ball.CanQuery = false
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    self.CanBeCollected = false

    -- Phase 1: Send the cocoon up
    local popTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local popTween = TweenService:Create(self.Ball, popTweenInfo, {
        CFrame = self.Ball.CFrame * CFrame.new(0, 7, 0)
    })
    popTween:Play()
    popTween.Completed:Wait()

    -- Phase 2: Magnetize towards the player
    local connection
    local speed = 10 
    local acceleration = 80 

    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.Ball or not self.Ball.Parent or not rootPart or not rootPart.Parent then
            if connection then connection:Disconnect() end
            return
        end

        local direction = rootPart.Position - self.Ball.Position
        local distance = direction.Magnitude

        speed = speed + (acceleration * deltaTime)
        local moveDistance = speed * deltaTime

        if distance <= moveDistance then
            connection:Disconnect()
			if (shouldDespawn) then
				self:despawn()
			end
        else
            self.Ball.Position = self.Ball.Position + (direction.Unit * moveDistance)
        end
    end)
end

function Cocoon:launch()
	local RunService = game:GetService("RunService")

	local startPos = self.Ball.Position
	local targetPos = self.TargetPos
	local timeDuration = 1
	local arcHeight = 25 -- How high the ball loops up

	-- Calculate a midpoint apex for our quadratic interpolation
	local midPoint = (startPos + targetPos) / 2 + Vector3.new(0, arcHeight, 0)

	local currentTime = 0

	-- Extremely fast, lightweight frame loop
	local connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		currentTime = currentTime + deltaTime
		local t = math.clamp(currentTime / timeDuration, 0, 1)
		
		-- The Quadratic Equation for a Bezier Curve (P0, P1, P2)
		local currentPos = (1 - t)^2 * startPos + 2 * (1 - t) * t * midPoint + t^2 * targetPos
		self.Ball.Position = currentPos
		
		if (t >= 1 or not self.Ball) then
            self.Ball.CanQuery = true
            CocoonActivated:FireServer(self.CocoonID)
            DropMoth:FireServer(self.Moth)
			connection:Disconnect() -- Clean up the loop
			self.Ball.Position = targetPos
			self.CanBeCollected = true
		end
	end)
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