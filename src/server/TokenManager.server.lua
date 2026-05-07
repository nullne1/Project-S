local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TokenManager = {}
TokenManager.ActiveTokens = {} -- THE DICTIONARY

local TokenModule = require(ReplicatedStorage.Shared.TokenModule)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart

CocoonStart.Event:Connect(function(type, wormModel, farm, player, targetTree, wormCFrame)
    local token = TokenModule.new(wormCFrame, farm, player)
    TokenManager.ActiveTokens[token.Model] = token
    token:rise()
end)

local CollectedToken = ReplicatedStorage.RemoteEvents:WaitForChild("CollectedToken")

CollectedToken.OnServerEvent:Connect(function(player, tokenModel)
    -- Grab the OOP Object out of the dictionary using the Model the client sent us
    local tokenObject = TokenManager.ActiveTokens[tokenModel]
    -- DEFENSIVE CHECK: Ensure the token exists, belongs to the player, and hasn't been collected yet
    if tokenObject and tokenObject.IsActive and tokenObject.Player == player then
        -- Flip the kill switch
        tokenObject.IsActive = false 
        
        -- Give the reward
        local PlayerData = require(game.ReplicatedStorage.Shared.PlayerDataModule)
        PlayerData.addSilk(player, 5) 
        
        -- Clean up the Token and remove it from our dictionary
        tokenObject:despawn()
        TokenManager.ActiveTokens[tokenModel] = nil 
    end
end)



