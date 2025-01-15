local prizes = require('src.prizes')
local tokenSender = require('src.utils.token-sender')

local function generateRandomNumber()
    -- TODO: Implement random number generation
    return 1234
end

local function selectRandomPrize(randomNumber)
    local availablePrizes = prizes.getPrizeTokens()
    if #availablePrizes == 0 then
        return nil
    end
    local index = (randomNumber % #availablePrizes) + 1
    return availablePrizes[index]
end

local function initiateLootbox(msg)
    local randomNumber = generateRandomNumber()
    -- Store random number for later use in fulfillLootbox
    -- TODO: Implement storage/retrieval of random number
    return true
end

local function fulfillLootbox(msg)
    -- TODO: Extract entropy from message
    local randomNumber = 1234 -- Placeholder until we implement entropy extraction

    local selectedPrize = selectRandomPrize(randomNumber)
    if not selectedPrize then
        return false, "No prizes available"
    end

    -- Send the selected prize token to the winner and remove it from available prizes
    tokenSender.sendTokens(selectedPrize, msg.Sender, 1, "Congratulations! You won this prize from the Loot Box!")
    prizes.removePrize(selectedPrize)
    return true
end

return {
    initiateLootbox = initiateLootbox,
    fulfillLootbox = fulfillLootbox
}
