local prizeTokens = {}
local prizesAvailable = {}

local function isPrizeToken(tokenId)
    return prizeTokens[tokenId] == true
end

local function addPrizeToken(tokenId)
    if not prizeTokens[tokenId] then
        prizeTokens[tokenId] = true
        table.insert(prizesAvailable, tokenId)
    end
end

local function getPrizeTokens()
    return prizesAvailable
end

local function removePrize(tokenId)
    for i, prize in ipairs(prizesAvailable) do
        if prize == tokenId then
            table.remove(prizesAvailable, i)
            prizeTokens[tokenId] = nil
            return true
        end
    end
    return false
end

local function listAvailablePrizes(msg)
    local available = getPrizeTokens()
    local response = { prizes = available }
    msg.reply({ Data = ao.json.encode(response) })
    if #available == 0 then
        return false, "No prizes available"
    end
    return true, { prizes = available }
end

return {
    isPrizeToken = isPrizeToken,
    addPrizeToken = addPrizeToken,
    getPrizeTokens = getPrizeTokens,
    removePrize = removePrize,
    listAvailablePrizes = listAvailablePrizes
}
