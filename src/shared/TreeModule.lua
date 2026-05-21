local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local TreeDespawned = ServerStorage.BindableEvents.TreeDespawned

local TreeRegistry = require(game.ReplicatedStorage.Shared.GameData.TreeRegistry)

local Tree = {}
Tree.__index = Tree

function Tree.new(modelTemplate, spawnCFrame, farm) : table
	local self = setmetatable({}, Tree)

	-- Setup the physical model
	self.Mesh = modelTemplate:Clone()
	self.Mesh.Anchored = true
	self.Mesh.CanCollide = false
	self.Mesh.CanTouch = false
	self.Mesh:PivotTo(spawnCFrame)
	self.Farm = farm
	local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
	self.Mesh.Parent = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].Trees

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
	TreeRegistry[self.Mesh] = {
		module = self,
		uses = self.Uses,
		cocoonUses = self.Uses
	}
	return self
end

function Tree:Despawn()
	TreeDespawned:Fire(self.Farm)
	self.Mesh:Destroy()
	self.DropArea:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Tree
