local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local billboardText = ReplicatedStorage.Assets.BillboardText
local CollectSilk = ReplicatedStorage.RemoteEvents.CollectSilk

CollectSilk.OnClientEvent:Connect(function(startPos, text) 
    -- float text
    local tempPart = Instance.new("Part")
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Transparency = 1
    tempPart.Position = startPos
    tempPart.Parent = workspace

    local billboardText = billboardText:Clone()
    billboardText.Size = UDim2.new(0, 0, 0, 0)
    billboardText.TextLabel.Size = UDim2.new(0, 0, 0, 0)
    billboardText.TextLabel.Text = text
    billboardText.Parent = tempPart

    -- tween constants
    local floatTime = 1
    local fadeOutTime = 0.1

    local linearTweenInfoIn = TweenInfo.new(
		floatTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)

    local fadeOutTwInfo = TweenInfo.new(
		fadeOutTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
        0,
        false,
        floatTime - fadeOutTime
	)

    local sizeTweenInfo = TweenInfo.new(
        floatTime + fadeOutTime,
        Enum.EasingStyle.Bounce,
		Enum.EasingDirection.Out
    )

    local randDiff= math.random(-4, 4)
    local endPos = Vector3.new(startPos.X, startPos.Y + 5, startPos.Z + randDiff)
    -- size tween
    local billboardTextTween = TweenService:Create(billboardText, sizeTweenInfo, {Size = UDim2.new(0, 100, 0, 100)})
    local silkTextTween = TweenService:Create(billboardText.TextLabel, sizeTweenInfo, {Size = UDim2.new(0, 100, 0, 100)})
    local floatTween = TweenService:Create(tempPart, linearTweenInfoIn, {Position = endPos})
    local fadeOutTween = TweenService:Create(billboardText.TextLabel, fadeOutTwInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
    billboardTextTween:Play()
    silkTextTween:Play()
    floatTween:Play()
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()
    tempPart:Destroy()
    -- jump tween
    -- bounce tween
end)