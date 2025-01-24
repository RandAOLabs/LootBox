-- Mock randomModule before requiring loot-box
local mockRandomModule = {
    processRandomResponse = function() return "test-uuid", 12345 end,
    requestRandom = function() end,
    generateUUID = function() return "test-uuid" end
}

-- Mock the random module factory function
package.loaded["src.utils.random"] = function()
    return mockRandomModule
end

local lootBox = require("src.loot-box")
local prizes = require("src.prizes")
local tokenSender = require("src.utils.token-sender")

-- Mock tokenSender
tokenSender.sendTokens = function() end

describe("Loot Box", function()
    before_each(function()
        -- Clear any existing prizes
        while #prizes.getPrizeTokens() > 0 do
            prizes.removePrize(prizes.getPrizeTokens()[1])
        end
    end)

    describe("initiateLootbox and pending list", function()
        it("should add lootbox to pending list when initiated", function()
            local msg = { From = "test-sender" }

            -- Verify no pending lootboxes initially
            assert.are.equal(0, #lootBox.listPendingLootboxes())

            -- Initiate lootbox
            local success = lootBox.initiateLootbox(msg)
            assert.is_true(success)

            -- Verify lootbox is in pending list
            local pending = lootBox.listPendingLootboxes()
            assert.are.equal(1, #pending)
            assert.are.equal("test-uuid", pending[1].id)
            assert.are.equal("test-sender", pending[1].From)
        end)
    end)

    describe("fulfillLootbox", function()
        it("should call tokenSender.sendTokens when fulfilled", function()
            -- Add a test prize
            prizes.addPrizeToken("test-prize")

            -- Track if prize was sent with all required parameters
            local tokenSent = false
            tokenSender.sendTokens = function(prizeToken, from, amount, message)
                assert.is_not_nil(prizeToken, "prizeToken should be provided")
                assert.is_not_nil(from, "from should be provided")
                assert.is_not_nil(amount, "amount should be provided")
                assert.is_not_nil(message, "message should be provided")
                tokenSent = true
            end

            local success = lootBox.fulfillLootbox({ From = "test-sender", Data = "test-data" })
            assert.is_true(success)
            assert.is_true(tokenSent, "tokenSender.sendTokens should have been called")
        end)

        it("should remove lootbox from pending list after fulfillment", function()
            -- Add a test prize
            prizes.addPrizeToken("test-prize")

            -- First initiate a lootbox
            local msg = { From = "test-sender" }
            lootBox.initiateLootbox(msg)

            -- Verify it's in pending list
            assert.are.equal(1, #lootBox.listPendingLootboxes())

            -- Now fulfill it
            local success = lootBox.fulfillLootbox({ From = "test-sender", Data = "test-data" })
            assert.is_true(success)

            -- Verify it's no longer in pending list
            assert.are.equal(0, #lootBox.listPendingLootboxes())
        end)
    end)

    describe("selectRandomPrize", function()
        it("should return nil when no prizes available", function()
            -- First initiate a lootbox
            local msg = { From = "test-sender" }
            lootBox.initiateLootbox(msg)

            -- Ensure no prizes exist
            while #prizes.getPrizeTokens() > 0 do
                prizes.removePrize(prizes.getPrizeTokens()[1])
            end

            -- Try to fulfill it
            local success, err = lootBox.fulfillLootbox({ From = "test-sender", Data = "test-data" })
            assert.is_false(success)
            assert.are.equal("No prizes available", err)
        end)

        it("should select a prize when prizes are available", function()
            -- First initiate a lootbox
            local msg = { From = "test-sender" }
            lootBox.initiateLootbox(msg)

            -- Add test prizes
            prizes.addPrizeToken("prize1")
            prizes.addPrizeToken("prize2")

            -- Try to fulfill it
            local success = lootBox.fulfillLootbox({ From = "test-sender", Data = "test-data" })
            assert.is_true(success)

            -- Verify a prize was selected (count decreased)
            assert.are.equal(1, #prizes.getPrizeTokens())
        end)
    end)
end)
