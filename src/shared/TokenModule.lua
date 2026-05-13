local Token = {}
Token.__index = Token

function Token.new(wormCFrame, farm, player, type)
    local self = setmetatable({}, Token)

    self.Farm = farm
    self.Player = player
	self.Type = type

    self.Model = game:GetService("ServerStorage").Tokens:FindFirstChild(self.Type):Clone()
	self.Model.Parent = workspace.Assets.Parts.Tokens
    self.Model:PivotTo(CFrame.new(wormCFrame.X, wormCFrame.Y + 3.5, wormCFrame.Z))
	self.Model.Size = Vector3.new(0, 0, 0)
	self.Model.CFrame *= CFrame.Angles(math.rad(-90), 0, 0)

	-- === THE ANIMATION SETTINGS ===
    -- math.rad(360) means 1 full rotation per second. Multiply it to go faster!
    local spinSpeed = math.rad(360)
    local floatSpeed = 1 -- Moves up 0.5 studs per second
	local RunService = game:GetService("RunService")
    -- === THE ANIMATION LOOP ===
    self.AnimConnection = RunService.Heartbeat:Connect(function(deltaTime)
        -- Safety check to ensure the token hasn't been destroyed
        if self.Model then
            -- 1. Spin it in local space using CFrame.Angles
            local rotatedCFrame = self.Model.CFrame * CFrame.Angles(0, 0, spinSpeed * deltaTime)
            
            -- 2. Move it up in world space by adding a Vector3
            self.Model.CFrame = rotatedCFrame + Vector3.new(0, floatSpeed * deltaTime, 0)
        end
    end)

	self.IsActive = true 
    -- weldModelToPrimary(self.Model)
	
    return self
end

function Token:despawn()
	if self.AnimConnection then
        self.AnimConnection:Disconnect()
        self.AnimConnection = nil
    end

	if self.Model then
		self.Model:Destroy()
	end

	setmetatable(self, nil)
	table.clear(self)
end

function Token:rise()
    local TweenService = game:GetService("TweenService")

    local riseTweenInfo = TweenInfo.new(
        4,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
	)
	local rotateTweenInfo = TweenInfo.new(
		3,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	local tokenAppearTween = TweenService:Create(
		self.Model,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Size = Vector3.new(5, 0.5, 5)}
	)

	local tokenDisappearTween = TweenService:Create(
		self.Model,
		rotateTweenInfo,
		{Transparency = 1}
	)

	tokenAppearTween:Play()
	tokenAppearTween.Completed:Wait()
	tokenDisappearTween:Play()
	tokenDisappearTween.Completed:Wait()

	if (self.IsActive) then
		self:despawn()
	end
end

return Token