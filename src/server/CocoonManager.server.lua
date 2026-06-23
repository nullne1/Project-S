local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local PlantRegistry = require(ReplicatedStorage.Shared.GameData.PlantRegistry)
local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local CocoonRegistry = require(ReplicatedStorage.Shared.GameData.CocoonRegistry)

local CocoonStartClient = ReplicatedStorage.RemoteEvents.CocoonStartClient

local CollectedCocoon = ReplicatedStorage.RemoteEvents.CollectedCocoon
local CocoonFinished = ReplicatedStorage.RemoteEvents.CocoonFinished
local CollectedSilk = ReplicatedStorage.RemoteEvents.CollectedSilk

local CocoonStart = ServerStorage.BindableEvents.CocoonStart

CocoonStart.Event:Connect(function(player, type, wormModel, farm, targetPlant, wormCFrame, tokenSkills)
    local cocoonID = HttpService:GenerateGUID(false)
    if not CocoonRegistry[player.UserId] then
        CocoonRegistry[player.UserId] = {}
    end

    local targetPos = getCocoonTargetPos(targetPlant)
    CocoonRegistry[player.UserId][cocoonID] = targetPos

    CocoonStartClient:FireClient(player, cocoonID, type, wormModel, farm, targetPlant, wormCFrame, targetPos, tokenSkills)
end)

function getCocoonTargetPos(targetPlant)
	local dropAreaSize = targetPlant.DropArea.Size
	local radius = math.min(dropAreaSize.Y, dropAreaSize.Z) / 2
	local angle = math.random() * 2 * math.pi
	local dist = radius * math.sqrt(math.random())
	local offsetY = dist * math.cos(angle)
    local offsetZ = dist * math.sin(angle)
	local surfacePointWorldPos = targetPlant.DropArea.CFrame * Vector3.new(dropAreaSize.X / 2, offsetY, offsetZ)
	local finalRestingPos = Vector3.new(
        surfacePointWorldPos.X,
        surfacePointWorldPos.Y + (2 / 2), --REDO FOR VARIABLE SIZED COCOONS, THE FIRST 2 IS THE SIZE--
        surfacePointWorldPos.Z
    )
    
    return finalRestingPos
end

CollectedCocoon.OnServerEvent:Connect(function(player, cocoonID, type)
    local MAX_TOUCH_DISTANCE = 15
    local playerCocoons = CocoonRegistry[player.UserId]

    if not playerCocoons or not playerCocoons[cocoonID] then 
        return
    end

    local cocoonPosition = playerCocoons[cocoonID]

    local character = player.Character
    if character and character.PrimaryPart then
        local playerPosition = character.PrimaryPart.Position
        local distance = (playerPosition - cocoonPosition).Magnitude
        
        if distance <= MAX_TOUCH_DISTANCE then
            playerCocoons[cocoonID] = nil 

            local finalSilkInfo = calculateFinalSilk(player)
            PlayerDataModule.addWorm(player, type, 1)
            PlayerDataModule.addSilk(player, finalSilkInfo["finalSilk"])
            
            CollectedSilk:FireClient(player, cocoonPosition, finalSilkInfo)
        else
            warn(player.Name .. " tried to collect a cocoon from too far away!")
        end
    end
end)

function calculateFinalSilk(player)
    local flatSilk = PlayerDataModule.getBasicData(player, "flatSilk")
    local finalSilkInfo = {}
    local finalSilk = math.random(math.ceil(flatSilk - flatSilk * 0.1), math.ceil(flatSilk + flatSilk * 0.1))

    local rand = math.random()
    if (rand <= PlayerDataModule.getBasicData(player, "critChance")) then
        finalSilk += finalSilk * PlayerDataModule.getBasicData(player, "critBonus")
        finalSilkInfo["crit"] = true
    else
        finalSilkInfo["crit"] = false
    end
    finalSilkInfo["finalSilk"] = finalSilk

    return finalSilkInfo
end

CocoonFinished.OnServerEvent:Connect(function(player, wormModel, targetPlant)
    local plantData = PlantRegistry[targetPlant]

    -- detect if cocoon is last
    local lastCocoon
    if (plantData["cocoonUses"] == 1) then
		plantData["cocoonUses"] = 0
		lastCocoon = true
	else
        plantData["module"]:depleteUse()
		plantData["cocoonUses"] -= 1
		lastCocoon = false
	end

	if (lastCocoon) then
		plantData["module"]:Despawn(player)
	end
end)
