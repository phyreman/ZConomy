require "TimedActions/ZCPryOpenAction"

ZConomyContextMenu = {};
ZConomyContextMenu.initContextMenu = function(player, context, worldobjects)
    local object = worldobjects[1];
    local objectType = nil;
    local config = ZConomy.config;

    -- Can't work without power
    --TODO: Unless it's a cash register, which can be smashed
    if not (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier) or object:getSquare():haveElectricity() then
        getSpecificPlayer(player):Say("Looks like it needs power...");
        return;
    end

    if object:getContainer() then
        objectType = object:getContainer():getType():gsub("vending", "");
    end

    -- Skip if it's not a vending machine or gas pump
    local props = object:getSquare():getProperties();
    if not (objectType == "pop" or objectType == "snack") or (props:Is("fuelAmount") and props:Val("fuelAmount") < 1) then
        return;
    end

    -- Skip if machine is empty, otherwise "fill"
    local objectData = object:getModData();
    if not objectData.remaining then
        objectData.remaining = ZombRand(config.Options["StockMin"],config.Options["StockMax"]);
        object:transmitModData();
    elseif objectData.remaining < 1 then
        return;
    end

    local playerObj = getSpecificPlayer(player);
    local inventory = playerObj:getInventory();
    if inventory:contains("Crowbar") then
        -- break door open; make noise, spawn some items
        context:addOption(getText("ContextMenu_BreakOpen"), object, ZConomyContextMenu.openMachine, player);
    end

    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnPurchase(player, clickedObject);
        return;
    end
    if inventory:contains("Base.Money") then
        -- allow purchase from machine, silent
        local money = inventory:FindAndReturn("Base.Money");
        local moneyData = money:getModData();
        if tonumber(config.Prices[objectType]) <= tonumber(moneyData.amount) then
            local text = getText("ContextMenu_Buy"..objectType:gsub("^%l", string.upper));
            context:addOption(text, object, ZConomyContextMenu.purchase, moneyData);
        end
    end
end

ZConomyContextMenu.purchase = function(object, moneyData)
    local objectType = object:getContainer():getType():gsub("vending", "");
    -- charge money
    moneyData.amount = string.format("%.2f", tostring(tonumber(moneyData.amount) - tonumber(ZConomy.config.Prices[objectType])));
    moneyData.tooltip.amount = moneyData.amount;

    -- vend single random item
    --TODO: Add item vend sounds; only for player
    local items = {"Crisps","Crisps2","Crisps3"};
    if objectType == "pop" then
        -- drink
        items = {"Pop","Pop2","Pop3","PopBottle"};
    end
    object:getContainer():AddItem("Base."..items[ZombRand(#items)+1]);
    local objectData = object:getModData();
    objectData.remaining = objectData.remaining - 1;
    object:transmitModData();
end

ZConomyContextMenu.openMachine = function(object, player)
    -- make some noise
    ISTimedActionQueue.add(ZCPryOpenAction:new(getSpecificPlayer(player), object));
end

ZConomyContextMenu.manageInventory = function(srcContainer, destContainer, character)
    -- This happens after the item has been moved from src into dest
    -- if destContainer has more than 1 money object, combine them into 1
    local inv = destContainer;
    local stacks = inv:FindAll("Base.Money");
    if stacks:size() < 2 then return end
    local bills,change = string.gmatch(stacks:get(0):getModData().amount, "(%d+)\.(%d+)")();
    local billsDelta,changeDelta;
    for i = 1, stacks:size() - 1 do
        billsDelta,changeDelta = string.gmatch(stacks:get(i):getModData().amount, "(%d+)\.(%d+)")();
        bills = bills + billsDelta;
        change = change + changeDelta;
        if change >= 100 then
            change = change - 100;
            bills = bills + 1;
        end
    end
    inv:RemoveAll("Base.Money");
    local moneyData = inv:AddItem("Base.Money"):getModData();
    moneyData.amount = bills .. "." .. change;
    moneyData.tooltip = {};
    moneyData.tooltip.amount = moneyData.amount;
end

Events.OnFillWorldObjectContextMenu.Add(ZConomyContextMenu.initContextMenu);
Events.OnTransferInventoryItem.Add(ZConomyContextMenu.manageInventory);