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
    if not value or not isInteger(value) or value ~= constants.LOOTBOX_COST then
        ao.send(ao_utils.sendResponse(
            msg.From,
            "Error",
            {
                message = string.format(
                    "Incorrect payment amount. Lootbox cost is %d tokens, received %d",
                    constants.LOOTBOX_COST,
                    value
                )
            }
        ))
        return false
    end
    return value
end

return {
    isPaymentToken = isPaymentToken,
    checkPaid = checkPaid
}
