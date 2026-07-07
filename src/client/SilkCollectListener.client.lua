local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local billboardText = ReplicatedStorage.Assets.BillboardText

local CollectedSilk = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedSilk

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local localPlayer = Players.LocalPlayer

CollectedSilk.OnClientEvent:Connect(function(startPos, silkInfo)
    
    -- float text
    local tempPart = Instance.new("Part")
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Transparency = 1
    tempPart.Position = startPos
    RaycastIgnore:Fire(tempPart)
    tempPart.Parent = workspace

    local billboardText = billboardText:Clone()
    billboardText.Size = UDim2.new(0, 0, 0, 0)
    billboardText.TextLabel.Size = UDim2.new(0, 0, 0, 0)
    billboardText.TextLabel.Text = "+" .. silkInfo["finalSilk"]
    billboardText.Parent = tempPart

    -- tween constants
    local floatTime = 1
    local fadeOutTime = 0.1

    local critFloatTime = 1
    local critFadeOutTime = 0.1

    local linearTweenInfoIn = TweenInfo.new(
		floatTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)

    local critLinearTweenInfoIn = TweenInfo.new(
		critFloatTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)

    local fadeOutTwInfo = TweenInfo.new(
		fadeOutTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
        0,
        false,
        critFloatTime - critFadeOutTime
	)

    local critFadeOutTwInfo = TweenInfo.new(
		fadeOutTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
        0,
        false,
        critFloatTime - critFadeOutTime
	)

    local sizeTweenInfo = TweenInfo.new(
        0.1,
        Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
    )

    local critSizeTweenInfo = TweenInfo.new(
        0.1,
        Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
    )


    local randDiff= math.random(-5, 5)
    local endPos = Vector3.new(startPos.X + randDiff, startPos.Y + 5, startPos.Z + randDiff)
    -- size tween
    local billboardTextTween
    local silkTextTween
    local floatTween
    local fadeOutTween
    local critSize = UDim2.new(0, 110, 0, 110)
    local normalSize = UDim2.new(0, 55, 0, 55)

    if (silkInfo["crit"]) then
        billboardTextTween = TweenService:Create(billboardText, critSizeTweenInfo, {Size = critSize})
        silkTextTween = TweenService:Create(billboardText.TextLabel, critSizeTweenInfo, {Size = critSize})
        floatTween = TweenService:Create(tempPart, critLinearTweenInfoIn, {Position = endPos})
        fadeOutTween = TweenService:Create(billboardText.TextLabel, critFadeOutTwInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
    else
        billboardTextTween = TweenService:Create(billboardText, sizeTweenInfo, {Size = normalSize})
        silkTextTween = TweenService:Create(billboardText.TextLabel, sizeTweenInfo, {Size = normalSize})
        floatTween = TweenService:Create(tempPart, linearTweenInfoIn, {Position = endPos})
        fadeOutTween = TweenService:Create(billboardText.TextLabel, fadeOutTwInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
    end

    billboardTextTween:Play()
    silkTextTween:Play()
    floatTween:Play()
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()
    tempPart:Destroy()
    -- jump tween
    -- bounce tween
end)