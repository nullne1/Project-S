local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local TreeRegistry = require(game.ReplicatedStorage.Shared:WaitForChild("TreeRegistry"))

local CollectSilk = ReplicatedStorage.RemoteEvents.CollectSilk

local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished

local Cocoon = {}
Cocoon.__index = Cocoon

function Cocoon.new(wormBody, spawnCFrame, farm, player, targetTree)
    local self = setmetatable({}, Cocoon)

    self.WormBody = wormBody
    self.SpawnCFrame = spawnCFrame
    self.Farm = farm
    self.Player = player
	self.PlayerData = PlayerDataModule.getData(player)
	self.TargetTree = targetTree
	self.TreeData = TreeRegistry[self.TargetTree]
	self.DropAreaSize = self.TargetTree.DropArea.Size
	self.DropAreaCFrame = self.TargetTree.DropArea.CFrame
	self.Ball = ServerStorage.Balls.BasicBall:Clone()
    self.Ball.Transparency = 1
    self.Ball.Parent = workspace.Assets.Parts.Balls
    self.Ball.CFrame = self.SpawnCFrame
	
	if (self.TreeData["cocoonUses"] == 1) then
		self.TreeData["cocoonUses"] = 0
		self.Last = true
	else
		self.TreeData["cocoonUses"] -= 1
		self.Last = false
	end
	
	local flatSilk = self.PlayerData["flatSilk"]
	self.FlatSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

	-- start
	self:spinCocoon()
    local notCollected = true
    self.Ball.Touched:Connect(function(part)
        if (notCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(self.Player)) then
            notCollected = false
            PlayerDataModule.addSilk(self.Player, self.FlatSilk)
            self.Ball.Parent = ServerStorage
            CollectSilk:FireClient(self.Player, self.Ball.Position, "+" .. self.FlatSilk)
        end
    end)

    return self
end

function Cocoon:launch()
	local startPos = self.Ball.Position
	local targetPos = self:getTargetPos()
	
	local timeDuration = 1
	local ARC_HEIGHT_GRAVITY = 100
	local realGravity = workspace.Gravity
	
	local attachment = Instance.new("Attachment", self.Ball)
	local antiGravity = Instance.new("VectorForce", self.Ball)
	antiGravity.Attachment0 = attachment
	antiGravity.RelativeTo = Enum.ActuatorRelativeTo.World
	antiGravity.Enabled = false -- Start disabled
	
	local lift = self.Ball:GetMass() * (realGravity - ARC_HEIGHT_GRAVITY)
	antiGravity.Force = Vector3.new(0, lift, 0)
	antiGravity.Enabled = true
	
	local displacement = targetPos - startPos
	local virtualGravityVector = Vector3.new(0, -ARC_HEIGHT_GRAVITY, 0)
	local antigravity = 0.5 * virtualGravityVector * (timeDuration * timeDuration)
	
	local requiredVelocity = (displacement - antigravity) / timeDuration
	self.Ball.Anchored = false
	self.Ball.AssemblyLinearVelocity = requiredVelocity
	self.Ball.AssemblyAngularVelocity = Vector3.new(5, 5, 5) 

	--print("Floating to target in " .. timeDuration .. " seconds...")

	task.wait(timeDuration + 0.1)

	self.Ball.Anchored = true
	self.Ball.AssemblyLinearVelocity = Vector3.zero
	self.Ball.AssemblyAngularVelocity = Vector3.zero
	self.Ball.Position = targetPos
	antiGravity.Enabled = false
	--print("Launched to:", targetPos)
end

function Cocoon:getTargetPos()
	local radius = math.min(self.DropAreaSize.Y, self.DropAreaSize.Z) / 2
	local angle = math.random() * 2 * math.pi
	local dist = radius * math.sqrt(math.random())
	local offsetX = dist * math.cos(angle)
	local offsetZ = dist * math.sin(angle)
	return self.DropAreaCFrame * Vector3.new(self.DropAreaSize.X / 2 - self.Ball.Size.Z + 5.4, offsetX, offsetZ)
end

function Cocoon:spinCocoon()
    local linearTweenInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
	)
    local spinCocoonTween = TweenService:Create(self.Ball, linearTweenInfo, {Transparency = 0})
    spinCocoonTween:Play()
    spinCocoonTween.Completed:Wait()
	CocoonFinished:Fire(self.WormBody, self.TargetTree)
	if (self.Last) then
		self.TreeData["module"]:Despawn()
	end
	self:launch()
end

return Cocoon