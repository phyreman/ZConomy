-- Set global helper function for adding items to the distribution table
if DistributeTo == nil then
    DistributeTo = function(_table, item, chance)
        local n = #_table+1;
        _table[n] = item;
        _table[n+1] = chance;
    end
end

local loot = ZConomy.config.Loot;

DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet2", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet3", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet4", loot.WalletChance);

loot = nil;

ZConomy.AddMoneyEventHandler = function(roomName, containerType, container)
    -- Add amount to money in cash registers
    if containerType == "cashregister" then
        local stacks = container:FindAll("Money");
        local loot = ZConomy.config.Loot;
        for i = 0, stacks:size()-1 do
            ZConomy.updateMoney(stacks:get(i), ZombRand(loot.RegisterMinBills, loot.RegisterMaxBills+1) .. "." .. ZombRand(loot.RegisterMinChange, loot.RegisterMaxChange+1));
        end
    end
    -- Add amount to money in stashes
    if containerType == "plankstash" then
        local stacks = container:getAllTypeRecurse("Money");
        local loot = ZConomy.config.Loot;
        for i = 0, stacks:size()-1 do
            ZConomy.updateMoney(stacks:get(i), ZombRand(loot.StashMinBills, loot.StashMaxBills+1) .. "." .. ZombRand(loot.StashMinChange, loot.StashMaxChange+1));
        end
    end
    -- Show containers being filled when in debug mode
    if ZConomy.debug then
        print("Filled " .. roomName .. " - " .. containerType);
    end
end

ZConomy.ZombieDeadEventHandler = function(zombie)
    if not zombie:isFemale() then return end

    local loot = ZConomy.config.Loot;
    -- Floor and clamp between [0,100]
    local chance = math.max(0, math.min(100, math.floor(loot.PurseChance)));
    local rolls = {};
    local rand;
    -- Roll (0 < $chance < 100) number of times and store the numbers
    while table.length(rolls) < chance do
        rand = ZombRand(100); -- 0-99
        if not ZConomy.tableContains(rolls, rand) then
            table.insert(rolls, rand);
        end
    end
    -- Roll a random number
    if not ZConomy.tableContains(rolls, ZombRand(100)) then return end

    local purse = zombie:getInventory():AddItem("Purse");
    local money = purse:getItemContainer():AddItem("Money");
    ZConomy.updateMoney(money, ZombRand(loot.PurseMinBills, loot.PurseMaxBills+1) .. "." .. ZombRand(loot.PurseMinChange, loot.PurseMaxChange+1));
end

-- Helper function to check if a table contains a given value
ZConomy.tableContains = function(t, value)
    for k,v in ipairs(t) do
        if v == value then
            return true;
        end
    end
    return false;
end

Events.OnFillContainer.Add(ZConomy.AddMoneyEventHandler);
Events.OnZombieDead.Add(ZConomy.ZombieDeadEventHandler);
