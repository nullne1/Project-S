local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ActivateTokenClient = ReplicatedStorage:WaitForChild("RemoteFunctions").ActivateTokenClient

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local ClientCocoonFolder = workspace:WaitForChild("Assets").Parts.Balls

ActivateTokenClient.OnClientInvoke = function(tokenType, farm, tokenPosition, collectedIDs, collectedID)
    if (tokenType == "WaterToken") then
        local cocoonMesh = ClientCocoonFolder:FindFirstChild(collectedID)

        if (cocoonMesh) then
            local cocoonPos = cocoonMesh.Position
            cocoonMesh:Destroy()
            return cocoonPos
        end  

        return nil
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
            local cocoonMesh = ClientCocoonFolder:FindFirstChild(cocoonID)
            if (cocoonMesh) then
                cocoonMesh:Destroy()
            end    
        end
        return nil
    else 
        return nil
    end
end