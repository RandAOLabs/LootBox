local prizes = require("src.prizes")

describe("Prizes", function()
    -- Reset prizes before each test
    before_each(function()
        -- Clear any existing prizes
        while #prizes.getPrizeTokens() > 0 do
            prizes.removePrize(prizes.getPrizeTokens()[1])
        end
    end)

    it("should handle adding and listing a single prize", function()
        -- Initially should have no prizes
        local success, result = prizes.listAvailablePrizes()
        assert.is_false(success)
        assert.are.equal("No prizes available", result)

        -- Add a prize
        prizes.addPrizeToken("test-prize-1")

        -- Should now list one prize
        success, result = prizes.listAvailablePrizes()
        assert.is_true(success)
        assert.are.equal(1, #result.prizes)
        assert.are.equal("test-prize-1", result.prizes[1])
    end)

    it("should handle removing prizes", function()
        -- Add a prize
        prizes.addPrizeToken("test-prize-1")

        -- Remove it
        local removed = prizes.removePrize("test-prize-1")
        assert.is_true(removed)

        -- List should be empty
        local success, result = prizes.listAvailablePrizes()
        assert.is_false(success)
        assert.are.equal("No prizes available", result)
    end)

    it("should handle multiple prizes", function()
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
        local success, result = prizes.listAvailablePrizes()
        assert.is_true(success)
        assert.are.equal(5, #result.prizes)

        -- Verify each prize is in the list
        for i, prize in ipairs(testPrizes) do
            assert.are.equal(prize, result.prizes[i])
        end
    end)
end)
