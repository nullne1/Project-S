local Token = {}
Token.__index = Token

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

function Token.new(wormCFrame, farm, player)
    local self = setmetatable({}, Token)

    self.Farm = farm
    self.Player = player

    self.Model = game:GetService("ServerStorage").Tokens.BasicToken:Clone()
	self.Model.Parent = workspace.Assets.Parts.Tokens
    self.Model:PivotTo(CFrame.new(wormCFrame.X, wormCFrame.Y + 2, wormCFrame.Z))
	self.Model.CFrame *= CFrame.Angles(90, 2, 0)
	-- self.Main = self.Model.Main
	self.IsActive = true 
    -- weldModelToPrimary(self.Model)
	
    return self
end

function Token:despawn()
	if self.Model then
		self.Model:Destroy()
	end
	setmetatable(self, nil)
	table.clear(self)
end

function Token:rise()
    local TweenService = game:GetService("TweenService")

    local riseTweenInfo = TweenInfo.new(
        3,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
	)
	local rotateTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)

	local tokenRiseTween = TweenService:Create(
		self.Model,
		riseTweenInfo,
		{Position = Vector3.new(self.Model.Position.X, self.Model.Position.Y + 10, self.Model.Position.Z), Transparency = 1}
	)
	tokenRiseTween:Play()
	tokenRiseTween.Completed:Wait()
	if (self.IsActive) then
		self:despawn()
	end
end

return Token