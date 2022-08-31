ZConomyMoney_OnLoot = function(input, result, player)
    local inv = player:getInventory();
    local loot = ZConomy.config.Loot;
    if not inv:contains("Money") then
        -- Set money amount
        ZConomy.updateMoney(result, tonumber(ZombRand(loot.WalletMinBills, loot.WalletMaxBills+1) .. "." .. ZombRand(loot.WalletMinChange, loot.WalletMaxChange+1)));
    else
        -- Combine money stacks
        local money = inv:FindAndReturn("Base.Money");
        local amount = money:getModData().amount;
        ZConomy.updateMoney(result, amount + tonumber(ZombRand(loot.WalletMinBills, loot.WalletMaxBills+1) .. '.' .. ZombRand(loot.WalletMinChange, loot.WalletMaxChange+1)));

        inv:Remove(money);
    end
    -- Add Empty Wallet to inventory
    inv:AddItem(input:get(0):getType() .. "Empty");
end
