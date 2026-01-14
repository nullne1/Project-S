local TweenService = game:GetService("TweenService")

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(worm : Part, spawnCFrame : CFrame, farm : Part) : table
    local self = setmetatable({}, Cocoon)

    self.Worm = worm
    self.SpawnCFrame = spawnCFrame
    self.Farm = farm

    return self
end

function Cocoon:start() : nil
    local ball = Cocoon.createCocoon(self.Worm, self.SpawnCFrame)
    Cocoon.spinCocoon(ball, self.Farm)
end

function Cocoon.spinCocoon(ball : Part, farm : Model) : nil
    local linearTweenInfo = TweenInfo.new(
        3,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
)
    local spinCocoonTween = TweenService:Create(ball, linearTweenInfo, {Transparency = 0})
    local dropTween = TweenService:Create(ball, linearTweenInfo, {Position = Vector3.new(ball.Position.X, farm.Floor.Position.Y + 2, ball.Position.Z)})
    spinCocoonTween:Play()
    spinCocoonTween.Completed:Wait()
    dropTween:Play()
end

function Cocoon.createCocoon(worm : Part, spawnCFrame : CFrame) : Part
    local ball = Instance.new("Part")
    ball.Anchored = true
    ball.CanCollide = false
    ball.Shape = "Ball"
    ball.Transparency = 1
    ball.Size = Vector3.new(worm.Size.X + 0.5, worm.Size.X + 0.5, worm.Size.X + 0.5)
    ball.Material = "SmoothPlastic"
    ball.CastShadow = false
    ball.Parent = workspace.Assets.Blocks.Balls
    ball.CFrame = spawnCFrame

    return ball
end
return Cocoon