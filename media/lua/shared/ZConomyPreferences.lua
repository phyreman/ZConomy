ZConomy = {};
ZConomy.config = {};
ZConomy._keys = {};

local defaultSettings = {};
defaultSettings.Prices = {
    ["Pop"] = "1.50",
    ["Snack"] = 1.25,
    ["Arcade"] = 0.75,
};
defaultSettings.Options = {
    ["StockMin"] = 20,
    ["StockMax"] = 31,
};
defaultSettings.Loot = {
    ["WalletMinBills"] = 1,
    ["WalletMaxBills"] = 9,
    ["WalletMinChange"] = 0,
    ["WalletMaxChange"] = 99,
    ["PurseMinBills"] = 1,
    ["PurseMaxBills"] = 9,
    ["PurseMinChange"] = 0,
    ["PurseMaxChange"] = 99,
    ["RegisterMinBills"] = 25,
    ["RegisterMaxBills"] = 50,
    ["RegisterMinChange"] = 0,
    ["RegisterMaxChange"] = 99,
    ["PayphoneMinBills"] = 0,
    ["PayphoneMaxBills"] = 25,
    ["PayphoneMinChange"] = 0,
    ["PayphoneMaxChange"] = 99,
    ["ArcadeMinBills"] = 25,
    ["ArcadeMaxBills"] = 50,
    ["ArcadeMinChange"] = 0,
    ["ArcadeMaxChange"] = 99,
    ["StashMinBills"] = 20,
    ["StashMaxBills"] = 50,
    ["StashMinChange"] = 50,
    ["StashMaxChange"] = 99,
};
ZConomy.log = function(d)
    print("[[ZConomy]]: "..d);
end

-- Helper function
function len(T)
    local c = 0
    for _ in pairs(T) do c = c + 1 end
    return c
end
table.length = len;

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

ZConomy.hook = function(plugin)
    local id = plugin.id;
    -- plugin must be a table with plugin.id being the name of the hooked mod
    if assert(id ~= nil, "[[ZConomy]] - ERROR: Unknown mod attempted to request override permissions. ID key is missing or empty.") then
        if assert(isModActive(id), "[[ZConomy]] - ERROR: '"..id.."' is not enabled.") then
            ZConomy.plugin = plugin;
            ZConomy.log(id .. " has successfully been given override access.");
        end
    end
end

-- *** Register Events ***
LuaEventManager.AddEvent("OnTransferInventoryItem");
LuaEventManager.AddEvent("OnZConomyPluginRequest");

Events.OnZConomyPluginRequest.Add(ZConomy.hook);