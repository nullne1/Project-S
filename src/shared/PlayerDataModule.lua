PlayerData = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetPlayerData = ReplicatedStorage.RemoteFunctions.GetPlayerData
local UsedWorm = ReplicatedStorage.RemoteEvents.UsedWorm
local CollectedWorm = ReplicatedStorage.RemoteEvents.CollectedWorm

local sessionData = {}

-- GETTER: Access data safely using the player objec
function PlayerData.getData(player)
    return sessionData[player.UserId]
end

-- SETTER: Called ONLY by your Manager script when data loads
function PlayerData.setData(player, data)
    sessionData[player.UserId] = data
end

-- CLEANUP: Called when player leaves to free up RAM
function PlayerData.removeData(player)
    sessionData[player.UserId] = nil
end

function PlayerData.assignEntityToPlayer(player, entity)
    local playerTag = "OwnedBy_" .. tostring(player.UserId)
    game:GetService("CollectionService"):AddTag(entity, playerTag)
end

function PlayerData.getBasicData(player, data)
    local requestedData = sessionData[player.UserId][data]
    if (requestedData) then
        return requestedData
    end

    return nil
end

function PlayerData.addItem(player, item)
    if (item and not sessionData[player.UserId]["items"][item]) then
        sessionData[player.UserId]["items"][item] = 1
    elseif (item) then
        sessionData[player.UserId]["items"][item] += 1
    end
end

function PlayerData.useWorm(player, type)
    sessionData[player.UserId]["silkWorms"][type] -= 1
    UsedWorm:FireClient(player, type)
end

function PlayerData.addWorm(player, type)
    sessionData[player.UserId]["silkWorms"][type] += 1
    CollectedWorm:FireClient(player)
end

function PlayerData.addSilk(player, amount)
    local data = sessionData[player.UserId] -- Get the specific player's table
    if (data) then
        data.silk += amount
    end
end

GetPlayerData.OnServerInvoke = function(player)
    return sessionData[player.UserId]["items"]
end



return PlayerData