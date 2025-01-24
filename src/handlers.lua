--- Handlers module
-- This module defines various handlers for processing messages.

local token = require('src.token')
local lootBox = require('src.loot-box')
local ao_utils = require('src.utils.ao-utils')
local prizes = require('src.prizes')

Handlers.add('creditNotice',
    Handlers.utils.hasMatchingTag('Action', 'Credit-Notice'),
    ao_utils.wrapHandler(token.handleCreditNotice)
)

Handlers.add(
    'randomResponse',
    Handlers.utils.hasMatchingTag('Action', 'Random-Response'),
    ao_utils.wrapHandler(lootBox.fulfillLootbox)
)

Handlers.add(
    'listPrizes',
    Handlers.utils.hasMatchingTag('Action', 'List-Prizes'),
    ao_utils.wrapHandler(prizes.listAvailablePrizes)
)
