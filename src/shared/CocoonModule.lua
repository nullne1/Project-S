local TweenService = game:GetService("TweenService")
local Zone = require(game.ReplicatedStorage.ZonePluginModule.Zone)
local CocoonFinished = game:GetService("ServerStorage").BindableEvents.CocoonFinished

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(wormBody : Part, spawnCFrame : CFrame, farm : Part) : table
    local self = setmetatable({}, Cocoon)

    self.WormBody = wormBody
    self.SpawnCFrame = spawnCFrame
    self.Farm = farm

    return self
end

function Cocoon:start() : nil
    local ball = Cocoon.createCocoon(self.WormBody, self.SpawnCFrame)
    local ballZone = Zone.new(ball)
    Cocoon.spinCocoon(ball, self.Farm, self.WormBody)
    ball.Touched:Connect(function(part)
        if part.Parent:FindFirstChild("Humanoid") then
            print("+1 Cocoon")
            ball:Destroy()
        end
    end)
end

function Cocoon.spinCocoon(ball : Part, farm : Model, wormBody : Part) : nil
    local linearTweenInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
)
    local spinCocoonTween = TweenService:Create(ball, linearTweenInfo, {Transparency = 0})
    local dropTween = TweenService:Create(ball, linearTweenInfo, {Position = Vector3.new(ball.Position.X, farm.Floor.Position.Y + 2, ball.Position.Z)})
    spinCocoonTween:Play()
    spinCocoonTween.Completed:Wait()
    CocoonFinished:Fire(wormBody)
    dropTween:Play()
    dropTween.Completed:Wait()
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