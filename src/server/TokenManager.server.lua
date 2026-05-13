local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TokenManager = {}
TokenManager.ActiveTokens = {} -- THE DICTIONARY

local TokenModule = require(ReplicatedStorage.Shared.TokenModule)
local TokenRegistry = require(ReplicatedStorage.Shared.GameData.TokenRegistry)

local CocoonStart = ServerStorage.BindableEvents.CocoonStart

CocoonStart.Event:Connect(function(type, wormModel, farm, player, targetTree, wormCFrame, tokenSkills)
    local tokenSkill
    for key, value in pairs(tokenSkills) do
        local rng = math.random()
        -- if token ability is chosen and has lower chance than a previously chosen ability, choose that ability
        if (rng <= value and tokenSkill and value < tokenSkills[tokenSkill]) then
            tokenSkill = key
        elseif (rng <= value) then
            tokenSkill = key
        end
    end
    if (tokenSkill) then
        local token = TokenModule.new(wormCFrame, farm, player, tokenSkill)
        TokenManager.ActiveTokens[token.Model] = token
        token:rise()
    end
end)

local CollectedToken = ReplicatedStorage.RemoteEvents:WaitForChild("CollectedToken")

CollectedToken.OnServerEvent:Connect(function(player, tokenModel)
    -- Grab the OOP Object out of the dictionary using the Model the client sent us
    local tokenObject = TokenManager.ActiveTokens[tokenModel]
    -- DEFENSIVE CHECK: Ensure the token exists, belongs to the player, and hasn't been collected yet
    if tokenObject and tokenObject.IsActive and tokenObject.Player == player then
        -- Flip the kill switch
        tokenObject.IsActive = false 

        -- Activate its ability
        local abilityFunction = TokenRegistry.Abilities[tokenObject.Type]
            
        if abilityFunction then
            abilityFunction(player, tokenObject.Farm, tokenObject.Model.Position)
        else
            warn("No ability found for token type: " .. tostring(tokenObject.Type))
        end
        
        -- Clean up the Token and remove it from our dictionary
        tokenObject:despawn()
        TokenManager.ActiveTokens[tokenModel] = nil 
    end
end)



