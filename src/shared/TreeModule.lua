local ServerStorage = game:GetService("ServerStorage")

local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local CocoonStart = ServerStorage.BindableEvents.CocoonStart

local Tree = {}
Tree.__index = Tree

function Tree.new(modelTemplate, spawnCFrame, farm) : table
	local self = setmetatable({}, Tree)

	-- Setup the physical model
	self.Model = modelTemplate:Clone()
	self.Model:PivotTo(spawnCFrame)
	print(workspace.Assets.Parts.Farms:GetChildren()[table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)])
	local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
	self.Model.Parent = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].Trees
	self.Model:SetAttribute("IsAlive", true)
	self.Uses = 4

	-- Setup properties
	self.Zone = zone

	-- setup tree despawn
	CocoonStart.Event:Connect(function(wormBody, farm, player, tree)
		if (tree == self.Model) then
			self.Uses -= 1
			if (self.Uses == 0) then
				self.Model:SetAttribute("IsAlive", false)
			end
		end
	end)

	CocoonFinished.Event:Connect(function()
		if (not self.Model:GetAttribute("IsAlive")) then
			self:Despawn()
		end
	end)


	return self
end

function Tree:Despawn()
	self.Model:Destroy()
end

return Tree
