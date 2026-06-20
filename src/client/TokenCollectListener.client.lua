local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RaycastIgnore = ReplicatedStorage:WaitForChild("BindableEvents").RaycastIgnore
local CollectedToken = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedToken

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

local function checkHover()
    -- Get the current 2D position of the mouse on the screen
    local mouseLocation = UserInputService:GetMouseLocation()
    
    -- Create a laser pointing from the camera, through the mouse, into the world
    local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        
        -- Now we check if the part we hit is a Token!
        if hitPart:IsDescendantOf(workspace.Assets.Parts.Tokens) then
            CollectedToken:FireServer(hitPart.Name, hitPart.Position)
            hitPart:Destroy()
        end
    end
end

-- Fire the check whenever the player moves their mouse (Swiping)
mouse.Move:Connect(checkHover)

-- Fire the check if they click/tap (Just in case they don't move the mouse)
mouse.Button1Down:Connect(checkHover)