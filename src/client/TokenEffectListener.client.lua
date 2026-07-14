local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ActivateTokenClient = ReplicatedStorage:WaitForChild("RemoteFunctions").ActivateTokenClient

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local ClientCocoonFolder = workspace:WaitForChild("Assets").Parts.Balls

local CocoonRegistry = require(ReplicatedStorage:WaitForChild("Shared").GameData.CocoonRegistry)

local localPlayer = Players.LocalPlayer
local activeWaves = {}

local function magnetize(player, shouldDespawn, cocoon)
    cocoon.CanTouch = false
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    -- Phase 1: Send the cocoon up
    local popTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local popTween = TweenService:Create(cocoon, popTweenInfo, {
        CFrame = cocoon.CFrame * CFrame.new(0, 7, 0)
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

local function createPulseBeam(sourcePart, targetPart, waveSpeed)
	local att0 = Instance.new("Attachment")
	att0.Parent = sourcePart

	local att1 = Instance.new("Attachment")
	att1.Parent = targetPart

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	
	-- Visual styling for a glowing energy effect
	beam.Texture = "rbxassetid://2890349162" 
	beam.TextureMode = Enum.TextureMode.Stretch
    beam.TextureLength = 0.1
	beam.LightEmission = 0
	beam.LightInfluence = 0 
    
	beam.Transparency = NumberSequence.new(1)

	beam.Width0 = 3
	beam.Width1 = 3
    beam.Segments = 100
	beam.TextureSpeed = 1
	
	-- Adding a slight arc
	beam.CurveSize0 = 10
	beam.CurveSize1 = 10
    beam.FaceCamera = true
	
    beam.Parent = sourcePart

    task.spawn(function()  
        local proxy = Instance.new("NumberValue")
        proxy.Value = 0.001

        local tweenInfo = TweenInfo.new(
            waveSpeed, 
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )

        local wipeTween = TweenService:Create(proxy, tweenInfo, {Value = 0.999})

        local connection
        connection = RunService.RenderStepped:Connect(function()
            local t = proxy.Value
            beam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(t, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        end)

        wipeTween.Completed:Connect(function()
            connection:Disconnect()
            beam.Transparency = NumberSequence.new(0) 
            proxy:Destroy()
        end)

        wipeTween:Play()
    end)
	
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
                    local part = currentWave[i]
                    if (part) then
                        part:Destroy()
                    end
                    task.wait(waveSpeed)
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
            task.spawn(function()
                if (#currentWave >= 5) then
                    if (currentWave[1]) then
                        local beam = currentWave[1]:FindFirstChild("Beam")
                        if (beam) then    
                            local proxy = Instance.new("NumberValue")
                            -- Start just above 0 to prevent keypoint time overlap
                            proxy.Value = 0.001

                            local tweenInfo = TweenInfo.new(
                                waveSpeed, -- Duration in seconds
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            local wipeTween = TweenService:Create(proxy, tweenInfo, {Value = 0.999})

                            local connection
                            connection = RunService.RenderStepped:Connect(function()
                                local t = proxy.Value
                                
                                beam.Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1), -- Transparent behind the sweep
                                    NumberSequenceKeypoint.new(t, 1), -- Sharp transition to solid at the sweep position
                                    NumberSequenceKeypoint.new(1, 0)  -- Solid ahead of the sweep
                                })
                            end)

                            wipeTween.Completed:Connect(function()
                                connection:Disconnect()
                                -- Snap to fully transparent once the animation finishes
                                beam.Transparency = NumberSequence.new(1) 
                                proxy:Destroy()
                            end)

                            wipeTween:Play()
                            wipeTween.Completed:Wait()
                            currentWave[1]:Destroy()
                            table.remove(currentWave, 1)
                        end
                    end
                end
            end)
            local tempPart = Instance.new("Part")
            if (currentWave) then
                tempPart.Anchored = true
                tempPart.CanCollide = false
                tempPart.CanQuery = false
                tempPart.CanTouch = false
                tempPart.Transparency = 1
                tempPart.Position = cocoonMesh.Position
                tempPart.Parent = workspace
                createPulseBeam(currentWave[#currentWave], tempPart, waveSpeed)
            end
            
            cocoonPos = cocoonMesh.Position
            task.spawn(function()
                magnetize(localPlayer, false, cocoonMesh)
            end)
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