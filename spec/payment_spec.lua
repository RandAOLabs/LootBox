local payment = require("src.payment")
local constants = require("src.constants")
local ao_utils = require("src.utils.ao-utils")

describe("Payment", function()
    before_each(function()
        -- Mock ao.send and json
        _G.ao = {
            send = function() end
        }
        _G.json = {
            encode = function(obj) return obj end
        }
    end)

    describe("checkPaid", function()
        it("should return false if payment is less than lootbox cost", function()
            local responseMessage = nil
            ao.send = function(msg)
                responseMessage = msg
            end

            local msg = {
                From = "test-token",
                Quantity = tostring(constants.LOOTBOX_COST - 1)
            }
            local result = payment.checkPaid(msg)

            assert.is_false(result)
            assert.are.equal("Error", responseMessage.Action)
        end)

        it("should return false if payment is more than lootbox cost", function()
            local responseMessage = nil
            ao.send = function(msg)
                responseMessage = msg
            end

            local msg = {
                From = "test-token",
                Quantity = tostring(constants.LOOTBOX_COST + 1)
            }
            local result = payment.checkPaid(msg)

            assert.is_false(result)
            assert.are.equal("Error", responseMessage.Action)
        end)

        it("should return value if payment matches lootbox cost exactly", function()
            local responseMessage = nil
            ao.send = function(msg)
                responseMessage = msg
            end

            local msg = {
                From = "test-token",
                Quantity = tostring(constants.LOOTBOX_COST)
            }
            local result = payment.checkPaid(msg)

            assert.are.equal(constants.LOOTBOX_COST, result)
            assert.is_nil(responseMessage) -- No error message should be sent
        end)

        it("should reject decimal values", function()
            local responseMessage = nil
            ao.send = function(msg)
                responseMessage = msg
            end

            local msg = {
                From = "test-token",
                Quantity = tostring(constants.LOOTBOX_COST + 0.5)
            }
            local result = payment.checkPaid(msg)

            assert.is_false(result)
            assert.are.equal("Error", responseMessage.Action)
        end)

        it("should reject non-numeric values", function()
            local responseMessage = nil
            ao.send = function(msg)
                responseMessage = msg
            end

            local msg = {
                From = "test-token",
                Quantity = "not-a-number"
            }
            local result = payment.checkPaid(msg)

            assert.is_false(result)
            assert.are.equal("Error", responseMessage.Action)
        end)
    end)

    describe("isPaymentToken", function()
        it("should return true for valid payment token", function()
            assert.is_true(payment.isPaymentToken(constants.TokenInUse))
        end)

        it("should return false for invalid payment token", function()
            assert.is_false(payment.isPaymentToken("invalid-token"))
        end)
    end)
end)
