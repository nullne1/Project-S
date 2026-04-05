local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)
local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local TreeRegistry = require(ReplicatedStorage.Shared.TreeRegistry)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished
local CollectSilk = ReplicatedStorage.RemoteEvents.CollectSilk

local function calculateFinalSilk(player)
    local playerData = PlayerDataModule.getData(player)
    local flatSilk = playerData["flatSilk"]
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= playerData["critChance"]) then
        finalSilk += finalSilk * playerData["critBonus"]
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

CocoonStart.Event:Connect(function(wormBody, farm, player, targetTree)
    local cocoon = CocoonModule.new(wormBody, wormBody.CFrame, farm, player, targetTree)
    local treeData = TreeRegistry[targetTree]

    -- detect if cocoon is last
    local lastCocoon
    if (treeData["cocoonUses"] == 1) then
		treeData["cocoonUses"] = 0
		lastCocoon = true
	else
		treeData["cocoonUses"] -= 1
		lastCocoon = false
	end

    -- detect player
    local notCollected = true
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and cocoon.CanBeCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(player)) then
            notCollected = false

            -- calculate final silk amount from player data
            local finalSilkInfo = calculateFinalSilk(player)

            PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
            CollectSilk:FireClient(player, cocoon.Ball.Position, finalSilkInfo)
            cocoon:Despawn()
        end
    end)

    -- start pupating and despawn tree if its the last
    cocoon:spinCocoon()

    CocoonFinished:Fire(cocoon.WormBody, targetTree)
    
	if (lastCocoon) then
		treeData["module"]:Despawn()
	end
end)