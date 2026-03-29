local ServerStorage = game:GetService("ServerStorage")

local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local WormFoundTree = ServerStorage.BindableEvents.WormFoundTree
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
	self.Model:SetAttribute("IsAlive", true)
	self.Model:SetAttribute("Uses", 2)
	self.Zone = zone
	TreeRegistry[self.Model] = self

	-- setup tree despawn
	self.Connect1 = WormFoundTree.Event:Connect(function(tree)
		if (tree == self.Model) then
			self.Model:SetAttribute("Uses", self.Model:GetAttribute("Uses") - 1)
			if (self.Model:GetAttribute("Uses") == 0) then
				self.IsAlive = false
				self.Model:SetAttribute("IsAlive", false)
			end
		end
	end)

	-- self.Connect2 = CocoonFinished.Event:Connect(function(wormBody, tree)
	-- 	if tree == self.Model then
	-- 		if (not self.IsAlive) then
	-- 			self:Despawn()
	-- 		end
	-- 	end
	-- end)

	return self
end

function Tree:Despawn()
	--self.Connect2:Disconnect()
	TreeDespawned:Fire(self.Farm)
	self.Model:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Tree
