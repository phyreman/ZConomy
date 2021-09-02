ZConomy.initContextMenu = function(_player, context, worldobjects)
    local player = getSpecificPlayer(_player);
    local object = worldobjects[1];
    local objType = nil;
    local objTexture = object:getTextureName();
    local index = objTexture:find("_", -3, true);
    local objTextureID = tonumber(objTexture:sub(index+1));
    local objTextureName = objTexture:sub(0, index-1);
    local config = ZConomy.config;
    -- location_shop_accessories_01_[0-4] = white registers
    -- location_shop_accessories_01_[20-23] = black registers
    -- location_shop_accessories_01_[8,9,12,13] = soda fountain
    -- location_shop_accessories_01_[16,17] = snack machine
    -- location_shop_accessories_01_[18,19] = soda machine
    -- recreational_01_[16-24] = arcade machines
    -- street_decoration_01_[38,39] = payphones

    function validObject()
        if (objType == "pop" or objType == "snack") or
            (objTexture ~= nil and
                (objTextureName == "location_shop_accessories_01" and
                    (
                        objTextureID < 5 or
                        (objTextureID > 19 and objTextureID < 24)
                    )
                ) or
                (objTextureName == "street_decoration_01" and
                    (objTextureID > 37 and objTextureID < 40)
                ) or
                (objTextureName == "recreational_01" and
                    (objTextureID > 15 and objTextureID < 25)
                )
            ) then return true end
        --print("Unwatched Texture: " .. objTexture);
        return false;
    end
    
    if object:getContainer() then
        objType = object:getContainer():getType():gsub("vending", "");
    end

    -- Skip if invalid object
    if not validObject() then
        return
    end
    --context:addOption("Fix", object, fix);
    function fix(object)
        object:getModData().ZC_Looted = nil;
        object:getModData().ZC_Remaining = nil;
    end

    local objectData = object:getModData();

    -- Skip if machine is empty, otherwise "fill"
    if objectData.ZC_Remaining == nil then
        if objType ~= nil then
            if objType == "snack" then
                objectData.ZC_Remaining = ZombRand(config.Options.SnackStockMin,config.Options.SnackStockMax+1);
            else
                objectData.ZC_Remaining = ZombRand(config.Options.DrinkStockMin,config.Options.DrinkStockMax+1);
            end
        elseif objTextureName == "recreational_01" then
            objectData.ZC_Remaining = tonumber(ZombRand(config.Loot.ArcadeMinBills,config.Loot.ArcadeMaxBills+1)..'.'..ZombRand(config.Loot.ArcadeMinChange,config.Loot.ArcadeMaxChange+1));
        else
            objectData.ZC_Remaining = 1;
        end
        object:transmitModData();
    elseif objectData.ZC_Remaining <= 0 then
        return;
    end

    if (objTextureName == "street_decoration_01" or objTextureName == "recreational_01") and objectData.ZC_Looted == nil then
        -- Dig around for spare change from payphones
        if objTextureName == "street_decoration_01" then
            -- payphone
            objectData.ZC_Looted = false;
            context:addOption(getText("ContextMenu_CheckForChange"), object, ZConomy.checkForChange, player);
        else
            -- arcade
            objectData.ZC_Looted = false;
            context:addOption(getText("ContextMenu_CheckForChange"), object, ZConomy.checkForChange, player);
        end
    end

    local inventory = player:getInventory();

    -- Everything can be busted open with a crowbar, so it's the last check before the power check
    if inventory:contains("Crowbar") then
        -- break door open; make noise, spawn some items
        context:addOption(getText("ContextMenu_BreakOpen"), object, ZConomy.openMachine, player);
    end

    -- All of the following actions should require power, so we can stop here if there is none
    if not ((SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier) or object:getSquare():haveElectricity()) then
        player:Say("Looks like it needs power first.");
        return;
    end

    -- Only allow purchase if the player has money, it's a vending machine, and it has power
    if not inventory:contains("Money") then return end

    local money = inventory:FindAndReturn("Base.Money");
    local moneyData = money:getModData();
    if objType ~= nil then
        local realType = ZConomy._keys[objType];
        -- check if there's enough money to purchase the item
        if config.Prices[realType] <= tonumber(moneyData.amount) then
            context:addOption(getText("ContextMenu_Buy"..realType), player, ZConomy.purchase, object, money);
        end
    -- OR allow the player to spend money at the arcades to entertain themselves
    elseif objType == nil and objTextureName == "recreational_01" then
        -- check if there's enough money to play
        if config.Prices["Arcade"] <= tonumber(moneyData.amount) then
            context:addOption(getText("ContextMenu_PlayArcadeGame"), player, ZConomy.playArcadeGame, object, money);
        end
    end
end

ZConomy.openMachine = function(object, player)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnPryOpen(object, player);
        return;
    end
    luautils.walkAdj(player, object:getSquare(), false);
    ISTimedActionQueue.add(ZCPryOpenAction:new(player, object));
end

ZConomy.checkForChange = function(object, player)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnCheckForChange();
        return;
    end
    luautils.walkAdj(player, object:getSquare(), false);
    player:faceThisObject(object);

    -- Combine money stacks
    local inventory = player:getInventory();
    local money = inventory:FindAndReturn("Base.Money") or inventory:AddItem("Base.Money");
    local change = {0.25,0.5,0.75,1};
    ZConomy.addToMoney(money, change[ZombRand(1,5)]);

    object:getModData().ZC_Looted = true;
    object:transmitModData();
end

ZConomy.purchase = function(player, object, money)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnPurchase(player, object, money);
        return;
    end
    luautils.walkAdj(player, object:getSquare(), false);
    player:faceThisObject(object);

    local objType = object:getContainer():getType():gsub("vending", "");
    -- Charge money
    ZConomy.addToMoney(money, -tonumber(ZConomy.config.Prices[objType:gsub("^%l", string.upper)]));

    -- Vend single random item
    local items;
    local prefix;
    if objType == "snack" then
        items = ZConomy.config.Snacks;
        prefix = "Snack";
    elseif objType == "pop" then
        items = ZConomy.config.Drinks;
        prefix = "Drink";
    end
    object:getContainer():AddItem(items[prefix..tostring(ZombRand(1, table.length(items)+1))]);
    --TODO: Add item vend (ka-thunk) sound; only for player
    local objectData = object:getModData();
    objectData.ZC_Remaining = objectData.ZC_Remaining - 1;
    object:transmitModData();
end

ZConomy.playArcadeGame = function(player, object, money)
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnPlayArcade(player, object, money);
        return;
    end
    luautils.walkAdj(player, object:getSquare(), false);
    ISTimedActionQueue.add(ZCPlayArcadeAction:new(player, object, money));
end

ZConomy.manageInventory = function(srcContainer, destContainer, character)
    -- This happens after the item has been moved from src into dest
    -- if destContainer has more than 1 money object, combine them into 1
    if srcContainer == nil or destContainer == nil or character == nil or destContainer:contains("Money") == false then
        return
    end
    local stacks = destContainer:FindAll("Money");
    if stacks:size() < 2 then return end

    -- Get amount of first money object
    local amount = tonumber(stacks:get(0):getModData().amount);
    -- Then add the value of each other object to the original
    for i = 1, stacks:size() - 1 do
        amount = amount + tonumber(stacks:get(i):getModData().amount);
    end
    -- Remove all money objects from the destination container (player inventory, usually)
    destContainer:RemoveAll("Money");

    -- Then create a new money object and set the amount to the total of the previous ones
    local money = destContainer:AddItem("Base.Money");
    ZConomy.updateMoney(money, amount);
end

Events.OnPreFillWorldObjectContextMenu.Add(ZConomy.initContextMenu);
LuaEventManager.AddEvent("OnTransferInventoryItem");
Events.OnTransferInventoryItem.Add(ZConomy.manageInventory);