local prizes = require('src.prizes')
local tokenSender = require('src.utils.token-sender')
local randomModule = require('src.utils.random')()

-- Store callback IDs for active loot box requests
local pendingLootboxes = {}

local function selectRandomPrize(randomNumber)
    local availablePrizes = prizes.getPrizeTokens()
    if #availablePrizes == 0 then
        return nil
    end
    local index = (randomNumber % #availablePrizes) + 1
    return availablePrizes[index]
end

local function initiateLootbox(msg)
    local callbackId = randomModule.generateUUID()
    pendingLootboxes[callbackId] = msg.From
    randomModule.requestRandom(callbackId)
    return true
end

local function fulfillLootbox(msg)
    local callbackId, entropy = randomModule.processRandomResponse(msg.From, msg.Data)
    local sender = pendingLootboxes[callbackId]
    if not sender then
        return false, "No pending loot box found for this callback"
    end

    if not entropy then
        return false, "Invalid entropy value received"
    end

    local randomNumber = math.floor(entropy)

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
