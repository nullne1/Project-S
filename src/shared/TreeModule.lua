local ServerStorage = game:GetService("ServerStorage")

local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local WormFoundTree = ServerStorage.BindableEvents.WormFoundTree
local TreeDespawned = ServerStorage.BindableEvents.TreeDespawned

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
	self.Model:SetAttribute("IsAlive", true)
	self.Model:SetAttribute("Uses", 1)

	-- Setup properties
	self.Zone = zone

	-- setup tree despawn
	self.Connect1 = WormFoundTree.Event:Connect(function(tree)
		if (tree == self.Model) then
			self.Model:SetAttribute("Uses", self.Model:GetAttribute("Uses") - 1)
			if (self.Model:GetAttribute("Uses") == 0) then
				self.Model:SetAttribute("IsAlive", false)
			end
		end
	end)

	self.Connect2 = CocoonFinished.Event:Connect(function()
		if (not self.Model:GetAttribute("IsAlive")) then
			task.wait(1)
			self:Despawn()
		end
	end)


	return self
end

function Tree:Despawn()
	self.Model:Destroy()
	TreeDespawned:Fire(self.Farm)
    setmetatable(self, nil)
    table.clear(self)
end

return Tree
