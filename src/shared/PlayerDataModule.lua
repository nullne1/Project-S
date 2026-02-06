PlayerData = {}

local sessionData = {}

-- GETTER: Access data safely using the player object
function PlayerData.getData(player) : nil
    return sessionData[player.UserId]
end

-- SETTER: Called ONLY by your Manager script when data loads
function PlayerData.setData(player, data) : nil
    sessionData[player.UserId] = data
end

-- CLEANUP: Called when player leaves to free up RAM
function PlayerData.removeData(player) : nil
    sessionData[player.UserId] = nil
end

function PlayerData.addBalls(player, amount) : nil
    local data = sessionData[player.UserId] -- Get the specific player's table
    if (data) then
        data.balls = data.balls + amount
    end
    print(data.balls)
end

return PlayerData