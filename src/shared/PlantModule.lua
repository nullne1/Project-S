local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local PlantDespawned = ServerStorage.BindableEvents.PlantDespawned

local PlantRegistry = require(game:GetService("ReplicatedStorage").Shared.GameData.PlantRegistry)
local PlantDropRegistry = require(game:GetService("ReplicatedStorage").Shared.GameData.PlantDropRegistry)

local Plant = {}
Plant.__index = Plant

function Plant.new(name, modelTemplate, spawnCFrame, farm) : table
	local self = setmetatable({}, Plant)
	self.Name = name
	self.SpawnCFrame = spawnCFrame
	self.OnFire = false

	-- Setup the physical model
	self.Mesh = modelTemplate:Clone()
	self.Mesh.Anchored = true
	self.Mesh.CanCollide = false
	self.Mesh.CanTouch = false
	self.Mesh.Size = Vector3.new(8, 5, 8)
	-- self.Mesh.Color = Color3.fromHex("#316f20")
	self.OriginalColor = Color3.fromHex("#316f20")
	self.Mesh:PivotTo(spawnCFrame)
	self.Farm = farm

	-- initial fire time - how long it takes for first stack
	self.FireStacks = 0
	self.InitialFireTime = 3
	self.TimeDecreasePerStack = 0.2
	self.TweenTime = self.InitialFireTime

	self.StartTime = 0
	self.EndTime = 0
	
	self.DropArea = Instance.new("Part")
	self.DropArea.Name = "DropArea"
	self.DropArea.Shape = Enum.PartType.Cylinder
	self.DropArea.Size = Vector3.new(1, 15, 15)
	self.DropArea.Transparency = 1
	self.DropArea.CanCollide = false
	self.DropArea.CanTouch = false
	self.DropArea.Anchored = true
	self.DropArea.CFrame = CFrame.new(Vector3.new(self.Mesh.Position.X, farm.Floor.Position.Y, self.Mesh.Position.Z)) * CFrame.Angles(0, 0, math.rad(90))
	self.DropArea.Parent = self.Mesh
	
	self.Uses = 1000
	self.RealTimeUses = self.Uses
	
	local minX = 4.2
	local minY = 3.2

	local maxX = 8.4
	local maxY = 7.2
	
	self.IncreaseFactorXZ = (8.4 - minX) / self.Uses  
	self.IncreaseFactorY = (7.2 - minY) / self.Uses

	self.DecreaseFactorXZ = (maxX - minX) / self.Uses
	self.DecreaseFactorY = (maxY - minY) / self.Uses
	
	self.Mesh.Size = Vector3.new(maxX, maxY, maxX)

	local farmIndex = table.find(workspace.Assets.Parts.Farms:GetChildren(), farm)
	self.Mesh.Parent = workspace.Assets.Parts.Farms:GetChildren()[farmIndex].Plants

	PlantRegistry[self.Mesh] = self

	self.ElapsedTime = 0

	return self
end

function Plant:setFire()
	self.OnFire = true
	self.FireStacks = 1
	
	local startTime = os.time()
	self.StartTime = startTime
	-- RunService.Heartbeat:Connect(function()
	-- 	if self.EndTime and not (os.time() >= self.EndTime) then
	-- 		print(os.time() - self.StartTime)
	-- 		self.ElapsedTime += 1
	-- 	end
	-- 	task.wait(1)
	-- end)
	self.EndTime = startTime + 8
	local fire = Instance.new("Fire")
	fire.Heat = 10
	fire.Name = "fire"
	fire.Parent = self.Mesh
	while self.Uses and self.Uses > 0 do
		self.Mesh.Color = Color3.fromHex("FF0000")
		self.TweenTime = self.InitialFireTime - self.TimeDecreasePerStack * (self.FireStacks - 1)

		if (self.TweenTime <= 0.01) then
			self.TweenTime = 0.01
		end
		
		local RecoverTween = TweenService:Create(
			self.Mesh,
			TweenInfo.new(self.TweenTime, Enum.EasingStyle.Linear),
			{Color = self.OriginalColor}
		)
		self.RealTimeUses -= 1
		self:depleteUse()
		RecoverTween:Play()
		RecoverTween.Completed:Wait()
		if self.EndTime and os.time() >= self.EndTime then
			self.OnFire = false
			self.Mesh:FindFirstChild("fire"):Destroy()
			self.FireStacks = 0
			break
		end
	end
end

function Plant:depleteUse()
	self.Uses -= 1

	if (self.Uses <= 0) then
		self:despawn()
	else
		local currentSize = self.Mesh.Size
		local TweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local ExpandTween = TweenService:Create(self.Mesh, TweenInfo, {Size = Vector3.new(currentSize.X - self.DecreaseFactorXZ, currentSize.Y - self.DecreaseFactorY, currentSize.Z - self.DecreaseFactorXZ)})
		ExpandTween:Play()
	end
end

function Plant:disappearTween()
	local currentSize = self.Mesh.Size
	local TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local ExplodeTween = TweenService:Create(self.Mesh, TweenInfo, 
	{	
		Size = Vector3.new(0, 0, 0)
	})
	ExplodeTween:Play()
	ExplodeTween.Completed:Wait()
end

function Plant:despawn()
	PlantRegistry[self.Mesh] = nil
	PlantDespawned:Fire(self.Name, self.SpawnCFrame, self.Farm)
	self:disappearTween()
	self.Mesh:Destroy()
	self.DropArea:Destroy()
    setmetatable(self, nil)
    table.clear(self)
end

return Plant
