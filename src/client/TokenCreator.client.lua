local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TokenModule = require(ReplicatedStorage:WaitForChild("Shared").TokenModule)

local CollectedToken = ReplicatedStorage:WaitForChild("RemoteEvents").CollectedToken
local CocoonStartClient = ReplicatedStorage:WaitForChild("RemoteEvents").CocoonStartClient

local localPlayer = Players.LocalPlayer

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
            local token = TokenModule.new(wormCFrame, farm, localPlayer, tokenSkill)
            local collected = false
            token.Mesh.Touched:Connect(function(otherPart)
                if (not collected and tostring(otherPart.Parent) == tostring(localPlayer)) then
                    collected = true
                    CollectedToken:FireServer(token.Mesh.Name, token.Mesh.Position)
                    token.Mesh:Destroy()
                end
            end)
            token:appear()
        end
    end
end)