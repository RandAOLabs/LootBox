local lootBox = require("src.loot-box")
local prizes = require("src.prizes")
local tokenSender = require("src.utils.token-sender")

-- Mock the tokenSender.sendTokens function
tokenSender.sendTokens = function() end

describe("Loot Box", function()
    describe("fulfillLootbox", function()
        -- Reset prizes before each test
        before_each(function()
            -- Clear any existing prizes
            while #prizes.getPrizeTokens() > 0 do
                prizes.removePrize(prizes.getPrizeTokens()[1])
            end
        end)

        it("should return false when no prizes are available", function()
            local success, err = lootBox.fulfillLootbox({ Sender = "test-sender" })
            assert.is_false(success)
            assert.are.equal("No prizes available", err)
        end)

        it("should successfully distribute all prizes from 5 down to 0", function()
            -- Add 5 test prizes
            local testPrizes = { "prize1", "prize2", "prize3", "prize4", "prize5" }
            for _, prize in ipairs(testPrizes) do
                prizes.addPrizeToken(prize)
            end

            -- Track which prizes were given
            local givenPrizes = {}
            -- Mock token.sendTokens to track prizes
            tokenSender.sendTokens = function(prizeToken)
                table.insert(givenPrizes, prizeToken)
            end

            -- Open 5 lootboxes
            for i = 1, 5 do
                local numPrizesBefore = #prizes.getPrizeTokens()
                assert.are.equal(6 - i, numPrizesBefore)

                local success = lootBox.fulfillLootbox({ Sender = "test-sender" })
                assert.is_true(success)

                local numPrizesAfter = #prizes.getPrizeTokens()
                assert.are.equal(numPrizesBefore - 1, numPrizesAfter)
            end

            -- Verify all prizes were given
            assert.are.equal(5, #givenPrizes)
            assert.are.equal(0, #prizes.getPrizeTokens())

            -- Try one more time - should fail
            local success, err = lootBox.fulfillLootbox({ Sender = "test-sender" })
            assert.is_false(success)
            assert.are.equal("No prizes available", err)
        end)

        it("should remove prize from available list after sending", function()
            -- Add a test prize
            prizes.addPrizeToken("test-prize")

            -- Track if prize was sent
            local prizeSent = false
            tokenSender.sendTokens = function(prizeToken)
                assert.are.equal("test-prize", prizeToken)
                prizeSent = true
            end

            local success = lootBox.fulfillLootbox({ Sender = "test-sender" })
            assert.is_true(success)
            assert.is_true(prizeSent)

            -- Verify prize was removed
            assert.are.equal(0, #prizes.getPrizeTokens())
        end)
    end)
end)
