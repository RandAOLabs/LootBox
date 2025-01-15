local constants = require('src.constants')
local ao_utils = require('src.utils.ao-utils')

local paymentTokens = {
    -- List of valid payment tokens
    [constants.TokenInUse] = true
}

local function isPaymentToken(tokenId)
    return paymentTokens[tokenId] == true
end

local function isInteger(n)
    return type(n) == "number" and n == math.floor(n)
end

local function checkPaid(msg)
    local value = tonumber(msg.Quantity)

    -- Handle non-numeric values
    if not value then
        ao_utils.sendError(msg.From, "Invalid payment amount. Must be a number.")
        return false
    end

    -- Handle non-integer values
    if not isInteger(value) then
        ao_utils.sendError(msg.From, "Invalid payment amount. Must be an integer.")
        return false
    end

    -- Handle incorrect payment amount
    if value ~= constants.LOOTBOX_COST then
        ao_utils.sendError(msg.From, string.format(
            "Incorrect payment amount. Lootbox cost is %d tokens, received %d",
            constants.LOOTBOX_COST,
            value
        ))
        return false
    end
    return value
end

return {
    isPaymentToken = isPaymentToken,
    checkPaid = checkPaid
}
