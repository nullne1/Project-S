local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CocoonModule = require(game:GetService("ReplicatedStorage").Shared.CocoonModule)
local PlayerData = require(ReplicatedStorage.Shared.PlayerDataModule)
local TreeRegistry = require(ReplicatedStorage.Shared.TreeRegistry)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart
local CocoonFinished = ServerStorage.BindableEvents.CocoonFinished

local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk
local CollectedWorm = ReplicatedStorage.RemoteEvents.CollectedWorm

local function calculateFinalSilk(player)
    local flatSilk = PlayerData.getBasicData(player, "flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= PlayerData.getBasicData(player, "critChance")) then
        finalSilk += finalSilk * PlayerData.getBasicData(player, "critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

CocoonStart.Event:Connect(function(type, wormBody, farm, player, targetTree)
    local cocoon = CocoonModule.new(wormBody.CFrame, farm, player, targetTree)
    PlayerData.assignEntityToPlayer(player, cocoon.Ball)
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
    local canBeCollected
    cocoon.Ball.Touched:Connect(function(part)
        if (notCollected and canBeCollected and part.Parent:FindFirstChild("Humanoid") and tostring(part.Parent) == tostring(player)) then
            notCollected = false
            
            -- calculate final silk amount from player data
            local finalSilkInfo = calculateFinalSilk(player)
            PlayerData.addWorm(player, type)
            PlayerData.addSilk(player, finalSilkInfo["finalSilk"])
            
            CollectedSilk:FireClient(player, cocoon.Ball.Position, finalSilkInfo)
            cocoon:despawn()
        end
    end)

    -- start pupating and despawn tree if its the last
    cocoon:spinCocoon()
    CocoonFinished:Fire(wormBody)
    cocoon:launch()
    canBeCollected = true
    
	if (lastCocoon) then
		treeData["module"]:Despawn()
	end
end)