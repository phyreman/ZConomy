--
-- The following examples are based off the actual code used in the mod.
-- NOTE: The ZombRand() function returns a number in the range of [min,max), so 1 is added to maximums
-- in order to reach those maximums, otherwise they will be excluded. So ZombRand(100) returns 0-99.
--
-- This happens when the player attempts to make a purchase
-- OnPurchase(PlayerObject, WorldObject, InventoryItem)
function OnPurchase(player, clickedObject, money)
    -- Walk to the machine's location
    luautils.walkAdj(player, object:getSquare(), false);
    -- Turn player towards machine to face it
    player:faceThisObject(object);

    local objType = object:getContainer():getType():gsub("vending", "");
    -- Charge money
    ZConomy.addToMoney(money, -tonumber(ZConomy.config.Prices[objType:gsub("^%l", string.upper)]));

    -- Pick list of items depending on type of machine
    local items;
    local prefix;
    if objType == "snack" then
        items = ZConomy.config.Snacks;
        prefix = "Snack";
    elseif objType == "pop" then
        items = ZConomy.config.Drinks;
        prefix = "Drink";
    end
    -- Add item to machine
    object:getContainer():AddItem(items[prefix..tostring(ZombRand(1, table.length(items)+1))]);
    local objectData = object:getModData();
    -- Reduce number of remaining vends
    objectData.ZC_Remaining = objectData.ZC_Remaining - 1;
    -- Send data to server (required for multiplayer)
    object:transmitModData();
end

-- This happens when the player takes money from a wallet
-- OnLootWallet(Object, InventoryItem, PlayerObject)
function OnLootWallet(inputItems, result, player)
    local inv = player:getInventory();
    local resultData = result:getModData();
    local loot = ZConomy.config.Loot;
    if not inv:contains("Money") then
        -- Set amount for money in player's inventory
        ZConomy.updateMoney(result, ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. "." .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1));
    else
        -- Add amounts and set it for the new money object
        local money = inv:FindAndReturn("Base.Money");
        local moneyData = money:getModData();
        ZConomy.updateMoney(result, tonumber(moneyData.amount) + tonumber(ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. '.' .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1)));
        -- Remove the old money object so we don't have two in the inventory
        inv:Remove(money);
    end
end

-- This happens when a crowbar is used to pry something open
-- OnPryOpen(WorldObject, PlayerObject)
function OnPryOpen(object, player)
    -- Walk to machine's location
    luautils.walkAdj(player, object:getSquare(), false);
    -- Perform timed action to pry open machine with a crowbar
    ISTimedActionQueue.add(ZCPryOpenAction:new(player, object));
end

-- This happens when the player wants to play an arcade game
-- OnPryOpen(WorldObject, PlayerObject)
function OnPlayArcade(object, player)
    -- Walk to arcade's location
    luautils.walkAdj(player, object:getSquare(), false);
    -- Perform timed action to play the arcade machine
    ISTimedActionQueue.add(ZCPlayArcadeAction:new(player, object, money));
end

-- This happens when a player checks for spare change in a
-- payphone or an arcade machine
-- OnCheckForChange(WorldObject, PlayerInventory)
function OnCheckForChange(object, inventory)
    -- Walk to machine's location
    luautils.walkAdj(player, object:getSquare(), false);
    -- Turn player towards machine to face it
    player:faceThisObject(object);

    -- Look in player's inventory for money and add it if not there
    local inventory = player:getInventory();
    local money = inventory:FindAndReturn("Base.Money") or inventory:AddItem("Base.Money");
    local change = {0.25,0.5,0.75,1};
    -- Randomly choose an amount of change to give when looking in coin slots of machines
    ZConomy.addToMoney(money, change[ZombRand(1,5)]);
    -- Mark the machine so it can't be looted again
    object:getModData().ZC_Looted = true;
    -- Send data to server (required for multiplayer)
    object:transmitModData();
end

local pluginHooks = {
    ["id"] = "Your_Plugin_ID", -- Change this to match your mod's plugin ID
    ["OnPryOpen"] = OnPryOpen,
    ["OnLootWallet"] = OnLoot,
    ["OnPurchase"] = OnPurchase,
    ["OnPlayArcade"] = OnPlayArcade,
    ["OnCheckForChange"] = OnCheckForChange
};
triggerEvent("OnZConomyPluginRequest", pluginHooks);