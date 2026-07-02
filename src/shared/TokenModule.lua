local Token = {}
Token.__index = Token

function Token.new(wormCFrame, farm, player, type, targetPlant)
    local self = setmetatable({}, Token)

    self.Farm = farm
    self.Player = player
	self.Type = type

    self.Mesh = game:GetService("ReplicatedStorage"):WaitForChild("Tokens"):FindFirstChild(self.Type):Clone()
	self.Mesh.Parent = workspace.Assets.Parts.Tokens
    self.Mesh:PivotTo(CFrame.new(wormCFrame.X, wormCFrame.Y + 5.5, wormCFrame.Z))
	self.Mesh.CFrame *= CFrame.Angles(0, math.rad(-90), 0)
	
	self.TargetSize = self.Mesh.Size
	
	self.Mesh.Size = Vector3.new(0.001, 0.001, 0.001)

	-- === THE ANIMATION SETTINGS ===
    -- math.rad(360) means 1 full rotation per second. Multiply it to go faster!
    local spinSpeed = math.rad(180)
    local floatSpeed = 0 -- Moves up 0.5 studs per second
	local RunService = game:GetService("RunService")
    -- === THE ANIMATION LOOP ===
    self.AnimConnection = RunService.Heartbeat:Connect(function(deltaTime)
        -- Safety check to ensure the token hasn't been destroyed
        if self.Mesh then
            -- 1. Spin it in local space using CFrame.Angles
            local rotatedCFrame = self.Mesh.CFrame * CFrame.Angles(0, spinSpeed * deltaTime, 0)
            
            -- 2. Move it up in world space by adding a Vector3
            self.Mesh.CFrame = rotatedCFrame + Vector3.new(0, floatSpeed * deltaTime, 0)
        end
    end)
	
    return self
end

function Token:despawn()
	if self.AnimConnection then
        self.AnimConnection:Disconnect()
        self.AnimConnection = nil
    end

	if self.Mesh then
		self.Mesh:Destroy()
	end

	setmetatable(self, nil)
	table.clear(self)
end

function Token:appear()
    local TweenService = game:GetService("TweenService")

	local disappearTweenInfo = TweenInfo.new(
		6,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	local tokenAppearTween = TweenService:Create(
		self.Mesh,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Size = self.TargetSize}
	)

	local tokenDisappearTween = TweenService:Create(
		self.Mesh,
		disappearTweenInfo,
		{Transparency = 1}
	)

	tokenAppearTween:Play()
	tokenAppearTween.Completed:Wait()
	tokenDisappearTween:Play()
	tokenDisappearTween.Completed:Wait()

	self:despawn()
end

return Token