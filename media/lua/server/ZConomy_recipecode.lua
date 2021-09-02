function Money_OnLoot(inputItems, result, player)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnLootWallet(inputItems, result, player);
        return;
    end
    
    local inv = player:getInventory();
    local loot = ZConomy.config.Loot;
    if not inv:contains("Money") then
        -- Set money amount
        ZConomy.updateMoney(result, ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. "." .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1));
    else
        -- Combine money stacks
        local money = inv:FindAndReturn("Base.Money");
        local moneyData = money:getModData();
        ZConomy.updateMoney(result, tonumber(moneyData.amount) + tonumber(ZombRand(loot.WalletMinBills,loot.WalletMaxBills+1) .. '.' .. ZombRand(loot.WalletMinChange,loot.WalletMaxChange+1)));

        inv:Remove(money);
    end
end