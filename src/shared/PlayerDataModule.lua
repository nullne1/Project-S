PlayerData = {}

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

function PlayerData.getBasicData(player, data)
    local data = sessionData[player.UserId][data]
    if (data) then
        return data
    end

    return nil
end

function PlayerData.useWorm(player, type)
    sessionData[player.UserId]["silkWorms"][type] -= 1
end

function PlayerData.addWorm(player, type)
    sessionData[player.UserId]["silkWorms"][type] += 1
    print(sessionData[player.UserId]["silkWorms"][type])
end

function PlayerData.addSilk(player, amount)
    local data = sessionData[player.UserId] -- Get the specific player's table
    if (data) then
        data.silk += amount
    end
end

return PlayerData