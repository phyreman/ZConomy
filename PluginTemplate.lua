-- This happens when the player attempts to make a purchase
-- OnPurchase(PlayerObject, WorldObject, InventoryItem)
function OnPurchase(player, clickedObject, money)
    -- Your code here
end

-- This happens when the player takes money from a wallet
-- OnLootWallet(Object, InventoryItem, PlayerObject)
function OnLootWallet(inputItems, result, player)
    -- Your code here
end

-- This happens when a crowbar is used to pry something open
-- OnPryOpen(WorldObject, PlayerObject)
function OnPryOpen(object, player)
    -- Your code here
end

-- This happens when the player wants to play an arcade game
-- OnPryOpen(WorldObject, PlayerObject)
function OnPlayArcade(object, player)
    -- Your code here
end

-- This happens when a player checks for spare change in a
-- payphone or an arcade machine
-- OnCheckForChange(WorldObject, PlayerInventory)
function OnCheckForChange(object, inventory)
    -- Your code here
end

local pluginHooks = {
    ["id"] = "Your_Plugin_ID",
    ["OnPryOpen"] = OnPryOpen,
    ["OnLootWallet"] = OnLoot,
    ["OnPurchase"] = OnPurchase,
    ["OnPlayArcade"] = OnPlayArcade,
    ["OnCheckForChange"] = OnCheckForChange
};
triggerEvent("OnZConomyPluginRequest", pluginHooks);