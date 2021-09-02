-- Quick-add
function DistributeTo(it, item, chance)
    local n = #it+1;
    it[n] = item;
    it[n+1] = chance;
end

local loot = ZConomy.config.Loot;

DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet2", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet3", loot.WalletChance);
DistributeTo(SuburbsDistributions.all.inventorymale.items, "Base.Wallet4", loot.WalletChance);

loot = nil;

function ZCAddMoney(roomName, containerType, container)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnAddMoney(roomName, containerType, container);
        return;
    end

    -- Add amount to money in cash registers
    if containerType == "cashregister" then
        local stacks = container:FindAll('Money');
        local loot = ZConomy.config.Loot;
        for i = 0, stacks:size()-1 do
            ZConomy.updateMoney(stacks:get(i), ZombRand(loot.RegisterMinBills, loot.RegisterMaxBills+1) .. '.' .. ZombRand(loot.RegisterMinChange, loot.RegisterMaxChange+1));
        end
    end
end

function ZCZombieDead(zombie)
    if not zombie:isFemale() then return end

    -- Helper function to check if a table contains a given value
    function contains(t, value)
        for k,v in ipairs(t) do
            if v == value then
                return true;
            end
        end
        return false;
    end

    local loot = ZConomy.config.Loot;
    -- Floor and clamp between [0,100]
    local chance = math.max(0, math.min(100, math.floor(loot.PurseChance)));
    local rolls = {};
    local rand;
    -- Roll (0 < $chance < 100) number of times and store the numbers
    while table.length(rolls) < chance do
        rand = ZombRand(100); -- 0-99
        if not contains(rolls, rand) then
            table.insert(rolls, rand);
        end
    end
    -- Roll a random number
    if not contains(rolls, ZombRand(100)) then return end

    local purse = zombie:getInventory():AddItem("Purse");
    local money = purse:getItemContainer():AddItem("Money");
    ZConomy.updateMoney(money, ZombRand(loot.PurseMinBills, loot.PurseMaxBills+1) .. '.' .. ZombRand(loot.PurseMinChange, loot.PurseMaxChange+1));
end

Events.OnFillContainer.Add(ZCAddMoney);
Events.OnZombieDead.Add(ZCZombieDead);