-- Quick-add
function DistributeTo(table, item, chance)
    local t,i,c,n = table,item,chance,#table+1;
    t[n] = i;
    t[n+1] = c;
end

local item_Wallet = "Base.Wallet";
local item_Wallet2 = "Base.Wallet2";
local item_Wallet3 = "Base.Wallet3";
local item_Wallet4 = "Base.Wallet4";
local item_Purse = "Base.Purse";

DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet2, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet3, 3);
DistributeTo(SuburbsDistributions.all.inventorymale.items, item_Wallet4, 3);

DistributeTo(SuburbsDistributions.mechanic.wardrobe.items, item_Wallet, 2);
DistributeTo(SuburbsDistributions.mechanic.wardrobe.items, item_Wallet2, 2);
DistributeTo(SuburbsDistributions.mechanic.wardrobe.items, item_Wallet3, 2);
DistributeTo(SuburbsDistributions.mechanic.wardrobe.items, item_Wallet4, 2);

DistributeTo(SuburbsDistributions.all.inventoryfemale.items, item_Purse, 1);

function ZCAddMoney(roomName, containerType, container)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnAddMoney(roomName, containerType, container);
        return;
    end

    -- Distribute money to containers
    if container:contains('Purse') then
        local purses = container:FindAll('Purse');
        for i = 0, purses:size() - 1 do
            -- 50/50 chance
            if ZombRand(2) > 0 then
                -- If successful, give 0.25-3.99 (ZombRand has a non-inclusive max value)
                local moneyData = purses:get(i):getItemContainer():AddItem('Base.Money'):getModData();
                moneyData.amount = ZombRand(4) .. '.' .. ZombRand(25,100);
                moneyData.tooltip = {};
                moneyData.tooltip.amount = moneyData.amount;
            end
        end
    end
end

Events.OnFillContainer.Add(ZCAddMoney);