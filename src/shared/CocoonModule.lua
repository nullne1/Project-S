local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zone = require(game.ReplicatedStorage.ZonePluginModule.Zone)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)

local CollectSilk = ReplicatedStorage.RemoteEvents.CollectSilk

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
            CollectSilk:FireClient(self.Player, ball.Position, "+100")
        end
    end)
end

function Cocoon.launch(ball : Part, farm : Folder) : nil
	local startPos = ball.Position
	local targetPos = Cocoon.getTargetPos(ball, farm)
	
	local timeDuration = 1
	local ARC_HEIGHT_GRAVITY = 100
	local realGravity = workspace.Gravity
	
	local attachment = Instance.new("Attachment", ball)
	local antiGravity = Instance.new("VectorForce", ball)
	antiGravity.Attachment0 = attachment
	antiGravity.RelativeTo = Enum.ActuatorRelativeTo.World
	antiGravity.Enabled = false -- Start disabled
	
	local lift = ball:GetMass() * (realGravity - ARC_HEIGHT_GRAVITY)
	antiGravity.Force = Vector3.new(0, lift, 0)
	antiGravity.Enabled = true
	
	local displacement = targetPos - startPos
	local virtualGravityVector = Vector3.new(0, -ARC_HEIGHT_GRAVITY, 0)
	local antigravity = 0.5 * virtualGravityVector * (timeDuration * timeDuration)
	
	local requiredVelocity = (displacement - antigravity) / timeDuration
	ball.Anchored = false
	ball.AssemblyLinearVelocity = requiredVelocity
	ball.AssemblyAngularVelocity = Vector3.new(5, 5, 5) 

	--print("Floating to target in " .. timeDuration .. " seconds...")

	task.wait(timeDuration + 0.1)

	ball.Anchored = true
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	ball.Position = targetPos
	antiGravity.Enabled = false
	--print("Launched to:", targetPos)
end

function Cocoon.getTargetPos(ball : Part, farm : Folder) : CFrame
	local floorArea = farm.Floor
	local radius = math.min(floorArea.Size.Y, floorArea.Size.Z) / 2
	local angle = math.random() * 2 * math.pi
	local dist = radius * math.sqrt(math.random())
	local offsetX = dist * math.cos(angle)
	local offsetZ = dist * math.sin(angle)
	return floorArea.CFrame * Vector3.new(floorArea.Size.X / 2 - ball.Size.Z + 0.8, offsetX, offsetZ)
end

function Cocoon.spinCocoon(ball : Part, farm : Folder, wormBody : Part) : nil
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

	Cocoon.launch(ball, farm)

    --dropTween:Play()
    --dropTween.Completed:Wait()
end

function Cocoon.createCocoon(worm : Part, spawnCFrame : CFrame) : Part
    local ball = ServerStorage.Balls.BasicBall:Clone()
    ball.Transparency = 1
    ball.Parent = workspace.Assets.Parts.Balls
    ball.CFrame = spawnCFrame

    return ball
end
return Cocoon