--- Handlers module
-- This module defines various handlers for processing messages.

local token = require('src.token')
local lootBox = require('src.loot-box')
local randomModule = require('src.utils.random')()

Handlers.add('creditNotice',
    Handlers.utils.hasMatchingTag('Action', 'Credit-Notice'),
    ao_utils.wrapHandler(token.handleCreditNotice)
)

Handlers.add(
    'randomResponse',
    Handlers.utils.hasMatchingTag('Action', 'Random-Response'),
    function(msg)
        local success, error = lootBox.fulfillLootbox(msg)
        if not success then
            print("Lootbox fulfillment failed: " .. (error or "unknown error"))
        end
    end
)
