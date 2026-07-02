local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local TokenModule = require(ReplicatedStorage:WaitForChild("Shared").TokenModule)

local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient
local RemoteRaycastIgnore= ReplicatedStorage:WaitForChild("RemoteEvents").RaycastIgnore
local CollectedToken = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedToken

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local mouse = localPlayer:GetMouse()

-- raycast filter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoredInstances = {
    character:GetChildren(),
	character:GetDescendants(),
	workspace.Assets.Parts.Farms.Farm1:WaitForChild("FarmArea"),
	workspace.Assets.Parts.Farms.Farm2:WaitForChild("FarmArea"),
	workspace.Assets.Parts.Farms.Farm3:WaitForChild("FarmArea")
}

raycastParams.FilterDescendantsInstances = ignoredInstances

RaycastIgnore.Event:Connect(function(part)
    if (#ignoredInstances >= 10000) then
        ignoredInstances = {
            character:GetChildren(),
            character:GetDescendants(),
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
            character:GetChildren(),
            character:GetDescendants(),
            workspace.Assets.Parts.Farms.Farm1:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm2:WaitForChild("FarmArea"),
            workspace.Assets.Parts.Farms.Farm3:WaitForChild("FarmArea")
        }
    end
	table.insert(ignoredInstances, part)

	raycastParams.FilterDescendantsInstances = ignoredInstances
end)

local activeTokensData = {}
local COLLECT_RANGE = 1500

mouse.Move:Connect(function()
    local currentParams = RaycastParams.new()
    currentParams.FilterType = raycastParams.FilterType
    
    -- We will build a temporary ignore list for this specific tap
    local ignoreList = raycastParams.FilterDescendantsInstances or {}
    currentParams.FilterDescendantsInstances = ignoreList

    local mouseLocation = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    while true do
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * COLLECT_RANGE, raycastParams)

        if not raycastResult then break end
        local hitPart = raycastResult.Instance
            
        -- Instead of checking the folder, we check if the part exists in our dictionary.
        -- If it does, we instantly retrieve the correct targetPlant for this specific mesh.
        local tokenTargetPlant = activeTokensData[hitPart]
            
        if tokenTargetPlant then
            -- Remove it from the dictionary so it can't be collected twice
            activeTokensData[hitPart] = nil
            
            CollectedToken:FireServer(hitPart.Name, hitPart.Position, tokenTargetPlant)
            hitPart:Destroy()
            table.insert(ignoreList, hitPart)
            currentParams.FilterDescendantsInstances = ignoreList
        else
            break
        end
    end
end)

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local currentParams = RaycastParams.new()
    currentParams.FilterType = raycastParams.FilterType
    
    local ignoreList = raycastParams.FilterDescendantsInstances or {}
    currentParams.FilterDescendantsInstances = ignoreList

    local unitRay = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
    while true do
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * COLLECT_RANGE, raycastParams)

        if not raycastResult then break end

        local hitPart = raycastResult.Instance
            
            -- Instead of checking the folder, we check if the part exists in our dictionary.
            -- If it does, we instantly retrieve the correct targetPlant for this specific mesh.
        local tokenTargetPlant = activeTokensData[hitPart]
            
        if tokenTargetPlant then
            -- Remove it from the dictionary so it can't be collected twice
            activeTokensData[hitPart] = nil
            CollectedToken:FireServer(hitPart.Name, hitPart.Position, tokenTargetPlant)
            hitPart:Destroy()
            
            table.insert(ignoreList, hitPart)
            currentParams.FilterDescendantsInstances = ignoreList
        else
            break
        end
    end
end)

UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
    if gameProcessed then return end 

    local tapPosition = touchPositions[1]
    local unitRay = camera:ScreenPointToRay(tapPosition.X, tapPosition.Y)
    
    local currentParams = RaycastParams.new()
    currentParams.FilterType = raycastParams.FilterType
    
    local ignoreList = raycastParams.FilterDescendantsInstances or {}
    currentParams.FilterDescendantsInstances = ignoreList

    -- Keep raycasting until we hit something that ISN'T a token
    while true do
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * COLLECT_RANGE, currentParams)

        -- If we hit the sky/nothing, stop the loop entirely
        if not raycastResult then break end 

        local hitPart = raycastResult.Instance
        local tokenTargetPlant = activeTokensData[hitPart]

        if tokenTargetPlant then
            -- We found a token! Collect it.
            activeTokensData[hitPart] = nil
            CollectedToken:FireServer(hitPart.Name, hitPart.Position, tokenTargetPlant)
            hitPart:Destroy()
            
            -- Add this specific token to our ignore list
            table.insert(ignoreList, hitPart)
            currentParams.FilterDescendantsInstances = ignoreList
        else
            -- We hit a non-token (like the ground, a tree, or a wall).
            -- Stop piercing and break the loop.
            break 
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