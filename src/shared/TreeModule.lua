local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local TreeDespawned = ServerStorage.BindableEvents.TreeDespawned

local TreeRegistry = require(game.ReplicatedStorage.Shared:WaitForChild("TreeRegistry"))

local Tree = {}
Tree.__index = Tree

function Tree.new(modelTemplate, spawnCFrame, farm) : table
	local self = setmetatable({}, Tree)

	-- Setup the physical model
	self.Model = modelTemplate:Clone()
	self.Model:PivotTo(spawnCFrame)
	self.Farm = farm
	local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
	self.Model.Parent = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].Trees
	self.Zone = zone
	self.Uses = 10
	TreeRegistry[self.Model] = {
		module = self,
		uses = self.Uses,
		cocoonUses = self.Uses
	}
	return self
end

function Tree:Despawn()
	local despawnTween
	for _, part in pairs(self.Model:GetDescendants()) do
		-- Check if it's a part that can have transparency
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			despawnTween = TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Transparency = 1})
			despawnTween:Play()
		end
	end
	despawnTween.Completed:Wait()
	TreeDespawned:Fire(self.Farm)
	self.Model:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Tree
