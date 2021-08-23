function Money_OnLoot(items, result, player)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnLoot();
        return;
    end

    local inv = player:getInventory();
    local resultData = result:getModData();
    if not inv:contains("Money") then
        -- set value of money
        resultData.amount = string.format("%.2f", ZombRand(4) .. "." .. ZombRand(25,100));
        resultData.tooltip = {};
        resultData.tooltip.amount = resultData.amount;
    else
        -- combine money stacks
        local money = inv:FindAndReturn("Base.Money");
        -- string.gmatch returns a function, so we execute that anonymously to get the values
        local bills,change = string.gmatch(money:getModData().amount, "(%d+)\.(%d+)")();
        bills = bills + ZombRand(4);
        change = change + ZombRand(25,100);
        if change >= 100 then
            change = change - 100;
            bills = bills + 1;
        end
        resultData.amount = string.format("%.2f", bills .. "." .. change);
        resultData.tooltip = {};
        resultData.tooltip.amount = resultData.amount;
        inv:Remove(money);
    end
end