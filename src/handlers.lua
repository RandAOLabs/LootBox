--- Handlers module
-- This module defines various handlers for processing messages.

local token = require('src.token')
local lootBox = require('src.loot-box')

Handlers.add('creditNotice',
    Handlers.utils.hasMatchingTag('Action', 'Credit-Notice'),
    ao_utils.wrapHandler(token.handleCreditNotice)
)

Handlers.add('entropy',
    Handlers.utils.hasMatchingTag('Action', 'Entropy'),
    ao_utils.wrapHandler(lootBox.fulfillLootbox)
)
