local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ActivateTokenClient = ReplicatedStorage:WaitForChild("RemoteFunctions").ActivateTokenClient

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local ClientCocoonFolder = workspace:WaitForChild("Assets").Parts.Balls

local CocoonRegistry = require(ReplicatedStorage:WaitForChild("Shared").GameData.CocoonRegistry)

local localPlayer = Players.LocalPlayer
local activeWaves = {}

local function magnetize(player, shouldDespawn, cocoon)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    -- Phase 1: Send the cocoon up
    local popTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local popTween = TweenService:Create(cocoon, popTweenInfo, {
        Position = cocoon.Position + Vector3.new(0, 5, 0)
    })
    popTween:Play()
    popTween.Completed:Wait()

    -- Phase 2: Magnetize towards the player
    local connection
    local speed = 10 
    local acceleration = 80 

    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not cocoon or not cocoon.Parent or not rootPart or not rootPart.Parent then
            if connection then connection:Disconnect() end
            return
        end

        local direction = rootPart.Position - cocoon.Position
        local distance = direction.Magnitude

        speed = speed + (acceleration * deltaTime)
        local moveDistance = speed * deltaTime

        if distance <= moveDistance then
            connection:Disconnect()
            cocoon.Transparency = 1
            if (shouldDespawn) then
                cocoon:Destroy()
            end
        else
            cocoon.Position = cocoon.Position + (direction.Unit * moveDistance)
        end
    end)
end

local function createPulseBeam(sourcePart, targetPart)
	local att0 = Instance.new("Attachment")
	att0.Parent = sourcePart

	local att1 = Instance.new("Attachment")
	att1.Parent = targetPart

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	
	-- Visual styling for a glowing energy effect
	beam.Texture = "rbxassetid://1417030805" 
	beam.TextureMode = Enum.TextureMode.Stretch
	beam.LightEmission = 0
	beam.LightInfluence = 0 
	
	beam.Color = ColorSequence.new(Color3.fromRGB(20, 140, 220)) -- Crimson
	beam.Width0 = 5
	beam.Width1 = 5
	beam.TextureSpeed = 0
	
	-- Adding a slight arc
	beam.CurveSize0 = 0
	beam.CurveSize1 = 0
	
	beam.FaceCamera = true
	beam.Parent = sourcePart
	
	return beam
end

ActivateTokenClient.OnClientInvoke = function(tokenType, farm, tokenPosition, collectedIDs, WaterTokenInfo)
    if (tokenType == "WaterToken") then
        local collectedID = WaterTokenInfo["CollectedID"]
        local lastBounce = WaterTokenInfo["LastBounce"]
        local waveID = WaterTokenInfo["WaveID"]
        local waveSpeed = WaterTokenInfo["WaveSpeed"]

        if (not activeWaves[waveID]) then
            activeWaves[waveID] = {}
        end

        local currentWave = activeWaves[waveID]
        
        if (lastBounce) then
            task.spawn(function()
                for i = 1, #currentWave, 1 do
                    local cocoon = currentWave[i]
                    if (cocoon) then
                        cocoon:Destroy()
                    end
                end        
                activeWaves[waveID] = nil
            end)
            return nil
        end

        local cocoonPos
        local cocoonMesh

        if (collectedID) then
            cocoonMesh = ClientCocoonFolder:FindFirstChild(collectedID)
        else
            return nil
        end
        
        if (cocoonMesh) then
            if (#currentWave > 7) then
                if (currentWave[1]) then
                    currentWave[1]:Destroy()
                    table.remove(currentWave, 1)
                end
            end
            local tempPart = Instance.new("Part")
            if (currentWave) then
                tempPart.Anchored = true
                tempPart.CanCollide = false
                tempPart.CanQuery = false
                tempPart.CanTouch = false
                tempPart.Transparency = 1
                tempPart.Position = cocoonMesh.Position
                tempPart.Parent = workspace
                createPulseBeam(currentWave[#currentWave], tempPart)
            end
            
            cocoonPos = cocoonMesh.Position
            magnetize(localPlayer, false, cocoonMesh)
            table.insert(currentWave, tempPart)
        end  

        return cocoonPos
    elseif (tokenType == "CollectToken") then
        local TweenShape = Instance.new("Part")
        TweenShape.Shape = "Cylinder"
        TweenShape.Anchored = true
        TweenShape.CanCollide = false
        TweenShape.CanQuery = false
        TweenShape.Size = Vector3.new(farm.FarmArea.Size.X, 0, 0)
        TweenShape.CFrame = CFrame.new(tokenPosition.X, farm.FarmArea.Position.Y, tokenPosition.Z) * CFrame.Angles(0, 0, math.rad(90))
        TweenShape.Color = Color3.fromHex("#d358be")
        TweenShape.Material = Enum.Material.ForceField
        TweenShape.CastShadow = false
        TweenShape.Parent = workspace
        
        local CollectTweenInfo = TweenInfo.new(
            0.25,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )

        local CollectTween = TweenService:Create(
            TweenShape,
            CollectTweenInfo,
            {Size = Vector3.new(farm.FarmArea.Size.X, 20, 10)}
        )
        
        task.spawn(function()
            CollectTween:Play()
            CollectTween.Completed:Wait()
            TweenShape:Destroy()
        end)

        for _, cocoonID in pairs(collectedIDs) do
            task.spawn(function()
                local cocoonMesh = ClientCocoonFolder:FindFirstChild(cocoonID)
                if (cocoonMesh) then
                    magnetize(localPlayer, true, cocoonMesh)
                end    
            end)
        end
        return nil
    else 
        return nil
    end
end