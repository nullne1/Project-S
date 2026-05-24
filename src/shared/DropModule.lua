local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantDropRegistry = require(ReplicatedStorage.Shared.GameData.PlantDropRegistry)
local CollectedDrop = ReplicatedStorage.RemoteEvents.CollectedDrop

local Drop = {}
Drop.__index = Drop

function Drop.new(parent, spawnCFrame, farm, player) 
    local self = setmetatable({}, Drop)

    self.Parent = parent
    self.SpawnCFrame = spawnCFrame
    self.Farm = farm
    self.Player = player

    local plantDrops = PlantDropRegistry.Drops[self.Parent]
	self.DropMesh = ServerStorage.Drops:FindFirstChild(plantDrops[1], true):Clone()
	self.DropMesh.Anchored = true
	self.DropMesh.CFrame = CFrame.new(self.SpawnCFrame.X, self.Farm.Floor.Position.Y, self.SpawnCFrame.Z)
    -- self.DropMesh.CFrame *= CFrame.Angles(self.DropMesh.CFrame.X, math.rad(math.random(0, 360)), self.DropMesh.CFrame.Z)
	self.DropMesh.Position = Vector3.new(self.DropMesh.Position.X, self.DropMesh.Position.Y + self.DropMesh.Size.X / 2 + 1, self.DropMesh.Position.Z)
	self.DropMesh.CanCollide = false
	self.DropMesh.Parent = workspace.Assets.Parts.Drops

    local collected = false
    self.DropMesh.Touched:Connect(function(otherPart)
        if (not collected and tostring(otherPart.Parent) == tostring(player)) then
            collected = true
            CollectedDrop:FireClient(player, self.DropMesh)
            self:despawn()
        end
    end)

    return self
end

function Drop:hover()
    local part = self.DropMesh
    local RunService = game:GetService("RunService")

    -- == SETTINGS ==
    local hoverHeight = 0.2   -- How high it bobs up and down
    local hoverSpeed = 2      -- How fast it bobs
    local spinSpeed = 2       -- How fast it rotates

    -- Store the original position so it hovers in place and doesn't drift
    local startCFrame = part.CFrame
    local timePassed = 0

    -- Connect to Heartbeat for smooth, frame-rate independent movement
    RunService.Heartbeat:Connect(function(deltaTime)
        timePassed += deltaTime

        -- Calculate the up/down bounce using a sine wave
        local bounce = math.sin(timePassed * hoverSpeed) * hoverHeight

        -- Apply the bounce and rotation to the part's CFrame
        part.CFrame = startCFrame 
            * CFrame.new(0, bounce, 0) 
            * CFrame.Angles(0, timePassed * spinSpeed, 0)
    end)
end

function Drop:despawn()
	self.DropMesh:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Drop