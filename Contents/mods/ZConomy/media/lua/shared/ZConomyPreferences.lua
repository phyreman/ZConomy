ZConomy = {};
ZConomy.config = {};
ZConomy.debug = getCore():getDebug();
ZConomy._keys = {};

local defaultSettings = {};
defaultSettings.Snacks = {
    ["Snack1"] = "Base.Crisps",
    ["Snack2"] = "Base.Crisps2",
    ["Snack3"] = "Base.Crisps3"
};
defaultSettings.Drinks = {
    ["Drink1"] = "Base.Pop",
    ["Drink2"] = "Base.Pop2",
    ["Drink3"] = "Base.Pop3",
    ["Drink4"] = "Base.PopBottle"
};
-- Prices ending with a zero must be in quotes (i.e. $1.50 = "1.50")
defaultSettings.Prices = {
    ["Pop"] = "1.50",
    ["Snack"] = "1.25",
    ["Arcade"] = "0.75"
};
-- Real machines hold around 300 items when full; default is 10-90% fill range
defaultSettings.Options = {
    ["SnackStockMin"] = 30,
    ["SnackStockMax"] = 270,
    ["DrinkStockMin"] = 30,
    ["DrinkStockMax"] = 270,
    ["ArcadeBoredomRate"] = "0.5",
    ["ArcadeUnhappyRate"] = "0.5",
    ["ArcadeStressRate"] = "0.5",
    ["ScaleMoneyWeight"] = true
};
defaultSettings.Loot = {
    -- Wallet Loot
    ["WalletMinBills"] = 1,
    ["WalletMaxBills"] = 9,
    ["WalletMinChange"] = 0,
    ["WalletMaxChange"] = 99,
    ["WalletChance"] = 2, -- Chance based on PZ-style loot rolls. (PZ default is 1, ZConomy default is 2)
    -- Purse Loot
    ["PurseMinBills"] = 1,
    ["PurseMaxBills"] = 9,
    ["PurseMinChange"] = 0,
    ["PurseMaxChange"] = 99,
    ["PurseChance"] = 2, -- Percent chance to spawn a purse on a dead female zombie (only whole numbers; default is 2)
    -- Register Loot
    ["RegisterMinBills"] = 1,
    ["RegisterMaxBills"] = 5,
    ["RegisterMinChange"] = 0,
    ["RegisterMaxChange"] = 99,
    -- Payphone Loot
    ["PayphoneMinBills"] = 0,
    ["PayphoneMaxBills"] = 5,
    ["PayphoneMinChange"] = 0,
    ["PayphoneMaxChange"] = 99,
    -- Arcade Loot
    ["ArcadeMinBills"] = 10,
    ["ArcadeMaxBills"] = 25,
    ["ArcadeMinChange"] = 0,
    ["ArcadeMaxChange"] = 99,
    -- Money Stash Loot (under floorboards)
    ["StashMinBills"] = 25,
    ["StashMaxBills"] = 50,
    ["StashMinChange"] = 50,
    ["StashMaxChange"] = 99
    -- ATM Loot
    -- ["AutoTellerMachineMinBills"] = 100,
    -- ["AutoTellerMachineMaxBills"] = 2000,
    -- ["AutoTellerMachineMinChange"] = 0,
    -- ["AutoTellerMachineMaxChange"] = 0
};
ZConomy.log = function(d)
    print("[[ZConomy]]: "..d);
end

ZConomy.addDrinks = function(drinks)
    if type(drinks) == "table" then
        for i = 1,table.length(drinks) do
            ZConomy.config.Drinks["Drink" .. table.length(ZConomy.config.Drinks)+1] = drinks[i];
        end
    else
        ZConomy.config.Drinks["Drink" .. table.length(ZConomy.config.Drinks)+1] = drinks;
    end
end

ZConomy.addSnacks = function(snacks)
    if type(snacks) == "table" then
        for i = 1,table.length(snacks) do
            ZConomy.config.Snacks["Snack" .. table.length(ZConomy.config.Snacks)+1] = snacks[i];
        end
    else
        ZConomy.config.Snacks["Snack" .. table.length(ZConomy.config.Snacks)+1] = snacks;
    end
end

ZConomy.addToMoney = function(money, amount)
    local moneyData = money:getModData();
    -- Simply set the amount if
    if moneyData.amount == nil then
        moneyData.amount = 0;
    end
    -- Convert amount to a number if it isn't one already
    if type(amount) ~= "number" then
        amount = tonumber(amount);
    end
    moneyData.amount = round(tonumber(moneyData.amount) + amount);
    if moneyData.tooltip == nil then
        moneyData.tooltip = {};
    end
    moneyData.tooltip.amount = moneyData.amount;
    -- Scale the weight of a money stack depending on the amount of money held
    if ZConomy.config.Options["ScaleMoneyWeight"] == "true" then
        money:setActualWeight(math.max(0.01, (moneyData.amount / 0.01) * 0.0005));
        money:setCustomWeight(true);
    end
end

ZConomy.updateMoney = function(money, amount)
    local moneyData = money:getModData();
    -- Convert amount to a number if it isn't one already
    if type(amount) ~= "number" then
        amount = tonumber(amount);
    end
    moneyData.amount = round(amount);
    if moneyData.tooltip == nil then
        moneyData.tooltip = {};
    end
    moneyData.tooltip.amount = moneyData.amount;
    if ZConomy.config.Options["ScaleMoneyWeight"] == "true" then
        money:setActualWeight(math.max(0.01, (moneyData.amount / 0.01) * 0.0005));
        money:setCustomWeight(true);
    end
end

-- Helper function to get the length of a table
if table.length == nil then
    table.length = function(T)
        local c = 0
        for _ in pairs(T) do c = c + 1 end
        return c
    end
end

if not fileExists(getMyDocumentFolder().."/Lua/ZConomy.ini") then
    ZConomy.config = defaultSettings;
    for label,table in pairs(ZConomy.config) do
        for key,value in pairs(table) do
            ZConomy._keys[string.lower(key)] = key;
        end
    end
    IniIO.writeIni("ZConomy.ini", ZConomy.config);
else
    ZConomy.config = IniIO.readIni("ZConomy.ini");
    local newVersion = false;
    for label,table in pairs(defaultSettings) do
        for key,value in pairs(table) do
            -- If the whole category is gone, add it all in
            if not ZConomy.config[label] then
                ZConomy.config[label] = {};
            end
            -- If the key is missing, add it to the category
            if ZConomy.config[label][key] == nil then
                ZConomy.config[label][key] = value;
                newVersion = true;
            end
            ZConomy._keys[string.lower(key)] = key;
        end
    end
    if newVersion then
        IniIO.writeIni("ZConomy.ini", ZConomy.config);
    end
    newVersion = nil;
end

defaultSettings = nil;

-- *** Register Events ***
LuaEventManager.AddEvent("OnTransferInventoryItem");
LuaEventManager.AddEvent("OnZConomySettingsLoaded");

triggerEvent("OnZConomySettingsLoaded");
