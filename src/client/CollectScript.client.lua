local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local silkText = ReplicatedStorage.Assets.SilkText
local CollectSilk = ReplicatedStorage.RemoteEvents.CollectSilk

CollectSilk.OnClientEvent:Connect(function(startPos, text) 
    -- float text
    local tempPart = Instance.new("Part")
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Transparency = 1
    tempPart.Position = startPos
    tempPart.Parent = workspace

    local collectText = silkText:Clone()
    collectText.TextLabel.Text = text
    collectText.Parent = tempPart

    local linearTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
    local endPos = Vector3.new(startPos.X, startPos.Y + 10, startPos.Z)

    local floatTween = TweenService:Create(tempPart, linearTweenInfo, {Position = endPos})
    local collectTextTween = TweenService:Create(collectText.TextLabel, linearTweenInfo, {TextTransparency = 1})
    collectTextTween:Play()
    floatTween:Play()
end)