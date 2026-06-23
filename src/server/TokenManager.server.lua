local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataModule = require(ReplicatedStorage.Shared.PlayerDataModule)
local TokenRegistry = require(ReplicatedStorage.Shared.GameData.TokenRegistry)

local CollectedToken = ReplicatedStorage.RemoteEvents.CollectedToken

CollectedToken.OnServerEvent:Connect(function(player, tokenName, tokenPosition, targetPlant)
    -- Activate its ability
    local abilityFunction = TokenRegistry.Abilities[tokenName]

    local farmFolder = workspace.Assets.Parts.Farms:FindFirstChild(PlayerDataModule.getBasicData(player, "lastFarmEntered"))
    if abilityFunction and farmFolder then
        abilityFunction(player, farmFolder, tokenPosition, targetPlant)
    else
        warn("No ability found for token type: " .. tostring(tokenName))
    end

end)