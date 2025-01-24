local prizes = require("src.prizes")

describe("Prizes", function()
    before_each(function()
        -- Mock ao global
        _G.ao = {
            json = {
                encode = function(obj) return obj end
            }
        }

        -- Clear any existing prizes
        while #prizes.getPrizeTokens() > 0 do
            prizes.removePrize(prizes.getPrizeTokens()[1])
        end
    end)

    it("should handle adding and listing a single prize", function()
        -- Create mock msg object
        local replyData
        local msg = {
            reply = function(response)
                replyData = response.Data
            end
        }

        -- Initially should have no prizes
        local success, result = prizes.listAvailablePrizes(msg)
        assert.is_false(success)
        assert.are.equal("No prizes available", result)
        assert.is_not_nil(replyData, "Should have reply data")

        -- Add a prize
        prizes.addPrizeToken("test-prize-1")

        -- Should now list one prize
        success, result = prizes.listAvailablePrizes(msg)
        assert.is_true(success)
        assert.are.equal(1, #result.prizes)
        assert.are.equal("test-prize-1", result.prizes[1])
        assert.is_not_nil(replyData, "Should have reply data")
    end)

    it("should handle removing prizes", function()
        -- Create mock msg object
        local replyData
        local msg = {
            reply = function(response)
                replyData = response.Data
            end
        }

        -- Add a prize
        prizes.addPrizeToken("test-prize-1")

        -- Remove it
        local removed = prizes.removePrize("test-prize-1")
        assert.is_true(removed)

        -- List should be empty
        local success, result = prizes.listAvailablePrizes(msg)
        assert.is_false(success)
        assert.are.equal("No prizes available", result)
        assert.is_not_nil(replyData, "Should have reply data")
    end)

    it("should handle multiple prizes", function()
        -- Create mock msg object
        local replyData
        local msg = {
            reply = function(response)
                replyData = response.Data
            end
        }

        -- Add 5 prizes
        local testPrizes = {
            "prize1",
            "prize2",
            "prize3",
            "prize4",
            "prize5"
        }

        for _, prize in ipairs(testPrizes) do
            prizes.addPrizeToken(prize)
        end

        -- Verify all 5 prizes are listed
        local success, result = prizes.listAvailablePrizes(msg)
        assert.is_true(success)
        assert.are.equal(5, #result.prizes)

        -- Verify each prize is in the list
        for i, prize in ipairs(testPrizes) do
            assert.are.equal(prize, result.prizes[i])
        end

        assert.is_not_nil(replyData, "Should have reply data")
    end)
end)
