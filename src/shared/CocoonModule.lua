local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")

local Zone = require(game.ReplicatedStorage.ZonePluginModule.Zone)
local PlayerData = require(game:GetService("ReplicatedStorage").Shared.PlayerDataModule)
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(wormBody : Part, spawnCFrame : CFrame, farm : Part, player: string) : table
    local self = setmetatable({}, Cocoon)

    self.WormBody = wormBody
    self.SpawnCFrame = spawnCFrame
    self.Farm = farm
    self.Player = player

    return self
end

function Cocoon:start() : nil
    local ball = Cocoon.createCocoon(self.WormBody, self.SpawnCFrame)
    local ballZone = Zone.new(ball)
    Cocoon.spinCocoon(ball, self.Farm, self.WormBody)
    local notCollected = true
    ball.Touched:Connect(function(part)
        if (notCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(self.Player)) then
            notCollected = false
            PlayerData.addBalls(self.Player, 1)
            ball.Parent = ServerStorage
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
    local ball = ServerStorage.Balls.BasicBall:Clone()
    ball.Transparency = 1
    ball.Parent = workspace.Assets.Parts.Balls
    ball.CFrame = spawnCFrame

    return ball
end
return Cocoon