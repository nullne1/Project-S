local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local PlantDespawned = ServerStorage.BindableEvents.PlantDespawned

local PlantRegistry = require(game.ReplicatedStorage.Shared.GameData.PlantRegistry)

local Plant = {}
Plant.__index = Plant

function Plant.new(modelTemplate, spawnCFrame, farm) : table
	local self = setmetatable({}, Plant)

	-- Setup the physical model
	self.Mesh = modelTemplate:Clone()
	self.Mesh.Anchored = true
	self.Mesh.CanCollide = false
	self.Mesh.CanTouch = false
	self.Mesh:PivotTo(spawnCFrame)
	self.Farm = farm
	local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
	self.Mesh.Parent = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].Plants

	self.DropArea = Instance.new("Part")
	self.DropArea.Name = "DropArea"
	self.DropArea.Shape = Enum.PartType.Cylinder
	self.DropArea.Size = Vector3.new(1, 20, 20)
	self.DropArea.Transparency = 1
	self.DropArea.CanCollide = false
	self.DropArea.CanTouch = false
	self.DropArea.Anchored = true
	self.DropArea.CFrame = CFrame.new(Vector3.new(self.Mesh.Position.X, farm.Floor.Position.Y, self.Mesh.Position.Z)) * CFrame.Angles(0, 0, math.rad(90))
	self.DropArea.Parent = self.Mesh

	self.Uses = 2
	PlantRegistry[self.Mesh] = {
		module = self,
		uses = self.Uses,
		cocoonUses = self.Uses
	}
	return self
end

function Plant:Despawn()
	PlantDespawned:Fire(self.Farm)
	self.Mesh:Destroy()
	self.DropArea:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Plant
