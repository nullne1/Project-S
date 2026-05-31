local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryOpened = ReplicatedStorage:WaitForChild("BindableEvents").InventoryOpened
local InventoryClosed = ReplicatedStorage:WaitForChild("BindableEvents").InventoryClosed

InventoryOpened.Event:Connect(function()
    print("Inventory has been opened")
end)

InventoryClosed.Event:Connect(function()
    print("Inventory has been closed")
end)