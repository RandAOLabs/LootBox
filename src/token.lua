local payment = require('src.payment')
local prizes = require('src.prizes')
local lootBox = require('src.loot-box')
local tokenSender = require('src.utils.token-sender')

local token = {}

function token.handleCreditNotice(msg)
    -- Check if it's a payment token
    if payment.isPaymentToken(msg.From) then
        if not payment.checkPaid(msg) then
            tokenSender.returnTokens(msg, "Incorrect payment amount")
            return false
        end

        if not lootBox.initiateLootbox(msg) then
            tokenSender.returnTokens(msg, "No prizes available")
            return false
        end

        return true
    end

    -- Check if it's a prize token
    if prizes.isPrizeToken(msg.From) then
        prizes.addPrizeToken(msg.From)
        return true
    end

    -- If neither payment nor prize token, return tokens with error
    local err = "Invalid Token: " .. msg.From .. " is neither a payment nor prize token"
    print(err)
    tokenSender.returnTokens(msg, err)
    return false
end

return token
