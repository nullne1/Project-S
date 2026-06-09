local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TokenModule = require(ReplicatedStorage:WaitForChild("Shared").TokenModule)
local TokenRegistry = require(ReplicatedStorage:WaitForChild("Shared").GameData.TokenRegistry)

local CollectedToken = ReplicatedStorage:WaitForChild("BindableEvents").CollectedToken
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient

local TokenManager = {}
TokenManager.ActiveTokens = {} -- THE DICTIONARY

local LocalPlayer = Players.LocalPlayer

CocoonStartClient.OnClientEvent:Connect(function(type, wormModel, farm, targetPlant, wormCFrame, tokenSkills)
    if (tokenSkills) then
        -- total += 1
        local tokenSkill
        local counter = 0
        local rng = math.random()
        for _, tokenInfo in tokenSkills do
            counter += tokenInfo["chance"]
            if (rng <= counter) then
                -- if (tokenInfo["token"] == "BasicToken") then
                --     b += 1
                -- elseif (tokenInfo["token"] == "CollectToken") then
                --     c += 1
                -- elseif (tokenInfo["token"] == "FireToken") then
                --     f += 1
                -- end
                -- if (total % 100 == 0) then
                --     print("\nBasic: " .. b .. "\nCollect: " .. c .. "\nFire" .. f .. "\nTotal: " .. total)
                -- end
                tokenSkill = tokenInfo["token"]
                break
            end
        end

        if (tokenSkill) then
            local token = TokenModule.new(wormCFrame, farm, LocalPlayer, tokenSkill)
            local collected = false
            token.Model.Touched:Connect(function(otherPart)
                if (not collected and tostring(otherPart.Parent) == tostring(LocalPlayer)) then
                    collected = true
                    activateToken(LocalPlayer, token.Model)
                end
            end)
            TokenManager.ActiveTokens[token.Model] = token
            token:appear()
        end
    end
end)

function activateToken(tokenModel)
    -- Grab the OOP Object out of the dictionary using the Model the client sent us
    local tokenObject = TokenManager.ActiveTokens[tokenModel]
    -- DEFENSIVE CHECK: Ensure the token exists, belongs to the player, and hasn't been collected yet
    if tokenObject and tokenObject.IsActive and tokenObject.Player == LocalPlayer then
        -- Flip the kill switch
        tokenObject.IsActive = false 

        -- Activate its ability
        local abilityFunction = TokenRegistry.Abilities[tokenObject.Type]

        if abilityFunction then
            abilityFunction(LocalPlayer, tokenObject.Farm, tokenObject.Model.Position)
        else
            warn("No ability found for token type: " .. tostring(tokenObject.Type))
        end
        
        -- Clean up the Token and remove it from our dictionary
        tokenObject:despawn()
        TokenManager.ActiveTokens[tokenModel] = nil 
    end
end

CollectedToken.Event:Connect(activateToken)