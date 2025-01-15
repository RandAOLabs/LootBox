local token = require("src.token")
local payment = require("src.payment")
local prizes = require("src.prizes")
local lootBox = require("src.loot-box")
local tokenSender = require("src.utils.token-sender")
local constants = require("src.constants")

describe("Token Handler", function()
    before_each(function()
        -- Mock dependencies
        payment.isPaymentToken = function(tokenId)
            return tokenId == "payment-token"
        end

        payment.checkPaid = function(msg)
            return tonumber(msg.Quantity) == constants.LOOTBOX_COST
        end

        prizes.isPrizeToken = function(tokenId)
            return tokenId == "prize-token"
        end

        lootBox.initiateLootbox = function()
            return true
        end
    end)

    describe("handleCreditNotice", function()
        it("should return tokens if not a payment token or prize token", function()
            local tokenReturned = false
            tokenSender.returnTokens = function(msg, err)
                assert.are.equal("unknown-token", msg.From)
                assert.are.equal("Invalid Token: unknown-token is neither a payment nor prize token", err)
                tokenReturned = true
            end

            local msg = {
                From = "unknown-token",
                Sender = "test-sender",
                Quantity = "1000"
            }
            local success = token.handleCreditNotice(msg)

            assert.is_false(success)
            assert.is_true(tokenReturned)
        end)

        it("should return tokens if payment amount is incorrect", function()
            local tokenReturned = false
            tokenSender.returnTokens = function(msg, err)
                assert.are.equal("payment-token", msg.From)
                assert.are.equal("Incorrect payment amount", err)
                tokenReturned = true
            end

            local msg = {
                From = "payment-token",
                Sender = "test-sender",
                Quantity = tostring(constants.LOOTBOX_COST + 100) -- Wrong amount
            }
            local success = token.handleCreditNotice(msg)

            assert.is_false(success)
            assert.is_true(tokenReturned)
        end)

        it("should return tokens if no prizes are available", function()
            local tokenReturned = false
            tokenSender.returnTokens = function(msg, err)
                assert.are.equal("payment-token", msg.From)
                assert.are.equal("No prizes available", err)
                tokenReturned = true
            end

            -- Mock lootBox.initiateLootbox to return false (no prizes)
            lootBox.initiateLootbox = function()
                return false
            end

            local msg = {
                From = "payment-token",
                Sender = "test-sender",
                Quantity = tostring(constants.LOOTBOX_COST)
            }
            local success = token.handleCreditNotice(msg)

            assert.is_false(success)
            assert.is_true(tokenReturned)
        end)

        it("should accept prize tokens and add them to available prizes", function()
            local prizeAdded = false
            prizes.addPrizeToken = function(tokenId)
                assert.are.equal("prize-token", tokenId)
                prizeAdded = true
            end

            local msg = {
                From = "prize-token",
                Sender = "test-sender",
                Quantity = "1"
            }
            local success = token.handleCreditNotice(msg)

            assert.is_true(success)
            assert.is_true(prizeAdded)
        end)
    end)
end)
