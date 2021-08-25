function Money_OnLoot(inputItems, result, player)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnLootWallet(inputItems, result, player);
        return;
    end
    
    local inv = player:getInventory();
    local resultData = result:getModData();
    local loot = ZConomy.config.Loot;
    if not inv:contains("Money") then
        -- set value of money
        resultData.amount = string.format("%.2f", ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. "." .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1));
        resultData.tooltip = {};
        resultData.tooltip.amount = resultData.amount;
    else
        -- combine money stacks
        local money = inv:FindAndReturn("Base.Money");
        local moneyData = money:getModData();
        resultData.amount = string.format("%.2f", tonumber(moneyData.amount) + tonumber(ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. '.' .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1)));
        resultData.tooltip = {};
        resultData.tooltip.amount = resultData.amount;

        inv:Remove(money);
    end
end