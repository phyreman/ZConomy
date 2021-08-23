ZConomy = {};
ZConomy.config = {};
ZConomy.plugin = nil;

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

ZConomy.hook = function(plugin, callback)
    -- plugin must be a table with plugin.name being the name of the hooked mod
    if assert(plugin.id ~= nil, "[[ZConomy]]: ERROR: Unknown mod attempted to request override permissions. ID key is missing or empty.") then
        -- if assert(isModActive(plugin.id), "**[ZConomy]: '"..plugin.id.."' doesn't appear to be active.") then
        --    --TODO: Populate with overridden methods
        --     local plug = {
        --         ["id"] = plugin.id,
        --         ["OnAddMoney"] = plugin.OnAddMoney,
        --         ["OnBruteForce"] = plugin.OnBruteForce,
        --         ["OnLoot"] = plugin.OnLoot,
        --         ["OnPurchase"] = plugin.OnPurchase
        --     };
        --     ZConomy.plugin = plug;
        --     ZConomy.log(plug.id .. " has successfully been given override access.");
        --     callback(plug);
        -- end
    end
end

-- OnAddMoney(String:roomName, String:containerType, ItemContainer:container)
-- OnPurchase(Player:player, WorldObject:clickedObject)
-- function cb(plug)
--     -- "plug" is an object with: {mod id, accessor functions}
-- end
-- triggerEvent("OnZCPluginRequest", plug, cb);

if not fileExists(getMyDocumentFolder().."/Lua/ZConomy.ini") then
    local config = {
        ["Pop"] = 1.5,
        ["Snack"] = 1.25,
        ["Petrol"] = 0
    };
    local options = {
        ["StockMin"] = 20,
        ["StockMax"] = 31
    };
    ZConomy.config["Prices"] = config;
    ZConomy.config["Options"] = options;
    IniIO.writeIni("ZConomy.ini", ZConomy.config);
else
    ZConomy.config = IniIO.readIni("ZConomy.ini");
end

-- *** Register Events ***
AddEvent("OnTransferInventoryItem");
AddEvent("OnZCPluginRequest");

Events.OnZCPluginRequest.Add(ZConomy.hook);