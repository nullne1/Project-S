local TweenService = game:GetService("TweenService")

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(worm : Part, spawnCFrame : CFrame) : table
    local self = setmetatable({}, Cocoon)

    self.Worm = worm
    self.SpawnCFrame = spawnCFrame

    return self
end

function Cocoon:start() : nil
    local ball = Cocoon.createCocoon(self.Worm, self.SpawnCFrame)
    local linearTweenInfo = TweenInfo.new(
        4, 
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
)
    local spinCocoonTween = TweenService:Create(ball, linearTweenInfo, {Transparency = 0})
    spinCocoonTween:Play()

end

function Cocoon.createCocoon(worm : Part, spawnCFrame : CFrame) : Part
    local ball = Instance.new("Part")
    ball.Anchored = true
    ball.CanCollide = false
    ball.Shape = "Ball"
    ball.Transparency = 1
    ball.Size = Vector3.new(worm.Size.X + 0.5, worm.Size.X + 0.5, worm.Size.X + 0.5)
    ball.Material = "Snow"
    ball.Parent = workspace.Assets.Blocks.Balls
    ball.CFrame = spawnCFrame

    return ball
end
return Cocoon