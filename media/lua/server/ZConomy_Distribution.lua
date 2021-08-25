--require "Items/Distributions";

-- Quick-add
function DistributeTo(itemTable, item, chance)
    local n = #itemTable+1;
    itemTable[n] = item;
    itemTable[n+1] = chance;
end

-- Quick-add
-- function DistributeTo(table, item, chance)
--     local t,i,c,n = table,item,chance,#table+1;
--     t[n] = i;
--     t[n+1] = c;
-- end

local item_Wallet = "Base.Wallet";
local item_Wallet2 = "Base.Wallet2";
local item_Wallet3 = "Base.Wallet3";
local item_Wallet4 = "Base.Wallet4";
local item_Purse = "Base.Purse";

DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet2, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet3, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet4, 3);

DistributeTo(SuburbsDistributions.all.inventoryfemale.items, item_Purse, 1);

item_Purse = nil;
item_Wallet = nil;
item_Wallet2 = nil;
item_Wallet3 = nil;
item_Wallet4 = nil;

function ZCAddMoney(roomName, containerType, container)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnAddMoney(roomName, containerType, container);
        return;
    end

    -- Distribute money to purses
    if container:contains('Purse') then
        local purses = container:FindAll('Purse');
        local loot = ZConomy.config.Loot;
        local money;
        local moneyData;
        for i = 0, purses:size()-1 do
            -- 50/50 chance
            if ZombRand(2) > 0 then
                -- If successful, give 1.99-9.99 (ZombRand has a non-inclusive max value)
                money = purses:get(i):getItemContainer():AddItem('Base.Money');
                moneyData = money:getModData();
                moneyData.amount = ZombRand(loot.PurseMinBills,loot.PurseMaxBills+1) .. '.' .. ZombRand(loot.PurseMinChange,loot.PurseMaxChange+1);
                moneyData.tooltip = {};
                moneyData.tooltip.amount = moneyData.amount;
                ZConomy.log("Added $" .. moneyData.amount .. " to " .. roomName .. "[" .. containerType .. "]");
            end
        end
    end

    -- Add an amount to money found in stashes
    if container:contains('Money') then
        local stacks = container:FindAll('Money');
        local loot = ZConomy.config.Loot;
        local moneyData = nil;
        for i = 0, stacks:size()-1 do
            moneyData = stacks:get(i):getModData();
            moneyData.amount = ZombRand(loot.StashMinBills, loot.StashMaxBills+1) .. '.' .. ZombRand(loot.StashMinChange, loot.StashMaxChange+1);
            moneyData.tooltip = {};
            moneyData.tooltip.amount = moneyData.amount;
        end
    end
end

Events.OnFillContainer.Add(ZCAddMoney);