local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local TokenModule = require(ReplicatedStorage:WaitForChild("Shared").TokenModule)

local CollectedToken = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedToken
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient
local RemoteRaycastIgnore= ReplicatedStorage:WaitForChild("RemoteEvents").RaycastIgnore
local CollectedToken = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedToken

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- raycast filter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoredInstances = {
	localPlayer.Character,
	workspace.Assets.Parts.Farms.Farm1:WaitForChild("FarmArea"),
	workspace.Assets.Parts.Farms.Farm2:WaitForChild("FarmArea"),
	workspace.Assets.Parts.Farms.Farm3:WaitForChild("FarmArea")
}

raycastParams.FilterDescendantsInstances = ignoredInstances

RaycastIgnore.Event:Connect(function(part)
    if (#ignoredInstances >= 10000) then
        ignoredInstances = {
            localPlayer.Character,
            workspace.Assets.Parts.Farms.Farm1:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm2:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm3:WaitForChild("FarmArea")
        }
    end
	table.insert(ignoredInstances, part)

	raycastParams.FilterDescendantsInstances = ignoredInstances
end)

RemoteRaycastIgnore.OnClientEvent:Connect(function(part)
    if (#ignoredInstances >= 10000) then
        ignoredInstances = {
            localPlayer.Character,
            workspace.Assets.Parts.Farms.Farm1:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm2:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm3:WaitForChild("FarmArea")
        }
    end
	table.insert(ignoredInstances, part)

	raycastParams.FilterDescendantsInstances = ignoredInstances
end)

local activeTokensData = {}

mouse.Move:Connect(function()
    local mouseLocation = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)

    if raycastResult then
        local hitPart = raycastResult.Instance
        
        -- Instead of checking the folder, we check if the part exists in our dictionary.
        -- If it does, we instantly retrieve the correct targetPlant for this specific mesh.
        local tokenTargetPlant = activeTokensData[hitPart]
        
        if tokenTargetPlant then
            -- Remove it from the dictionary so it can't be collected twice
            activeTokensData[hitPart] = nil
            
            CollectedToken:FireServer(hitPart.Name, hitPart.Position, tokenTargetPlant)
            hitPart:Destroy()
        end
    end
end)

CocoonStartClient.OnClientEvent:Connect(function(cocoonID, type, wormModel, farm, targetPlant, wormCFrame, targetPos, tokenSkills)
    if (tokenSkills) then
        -- total += 1
        local tokenSkill
        local counter = 0
        local rng = math.random()
        for _, tokenInfo in tokenSkills do
            counter += tokenInfo["chance"]
            if (rng <= counter) then
                -- if (tokenInfo["token"] == "BasicToken") then
                --     b += 1
                -- elseif (tokenInfo["token"] == "CollectToken") then
                --     c += 1
                -- elseif (tokenInfo["token"] == "FireToken") then
                --     f += 1
                -- end
                -- if (total % 100 == 0) then
                --     print("\nBasic: " .. b .. "\nCollect: " .. c .. "\nFire" .. f .. "\nTotal: " .. total)
                -- end
                tokenSkill = tokenInfo["token"]
                break
            end
        end

        if (tokenSkill) then
            local token = TokenModule.new(wormCFrame, farm, localPlayer, tokenSkill, targetPlant)
            activeTokensData[token.Mesh] = targetPlant
            local collected = false

            token.Mesh.Touched:Connect(function(otherPart)
                if (not collected and tostring(otherPart.Parent) == tostring(localPlayer)) then
                    collected = true
                    CollectedToken:FireServer(token.Mesh.Name, token.Mesh.Position, targetPlant)
                    token.Mesh:Destroy()
                end
            end)
            token:appear()
        end
    end
end)