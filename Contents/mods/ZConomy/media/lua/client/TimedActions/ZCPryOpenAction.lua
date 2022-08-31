require "TimedActions/ISBaseTimedAction"

ZCPryOpenAction = ISBaseTimedAction:derive("ZCPryOpenAction");

function ZCPryOpenAction:isValid()
    return self.character ~= nil and self.object ~= nil;
end

function ZCPryOpenAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ZCPryOpenAction:start()
    local player = self.character;
    local obj = self.object;
    player:getSquare():playSound("PryOpenMachine");
    addSound(player, self.x, self.y, self.z, 50, 15);
end

function ZCPryOpenAction:stop()
    ISBaseTimedAction.stop(self);
end

function ZCPryOpenAction:perform()
    local container = self.object:getContainer();
    local loot = ZConomy.config.Loot;

    -- Make a final bang to signal dinner time
    addSound(self.character, self.x, self.y, self.z, 50, 30);

    -- Now get the food and run
    if self.flags.isVendingMachine then
        -- default is snack machine
        local prefix = "Snack";
        if container:getType() == "vendingpop" then
            -- change the items to drinks if it's a soda machine
            prefix = "Drink";
        end
        local items = ZConomy.config[prefix.."s"]
        -- Add 2/3 to 3/4 since some were destroyed while opening the machine
        local objectData = self.object:getModData();
        for i = 0, math.floor(ZombRandFloat(objectData.ZConomy.stock * (2/3), objectData.ZConomy.stock * (3/4))) do
            container:AddItem(items[prefix..tostring(ZombRand(1,#items+1))]);
        end
        objectData.ZConomy.stock = 0;
        ZConomy.addToMoney(container:AddItem("Base.Money"), objectData.ZConomy.loot);
        objectData.ZConomy.loot = 0;
        self.object:transmitModData();
    else
        -- Not a vending machine
        local objTexture = self.object:getTextureName();
        local index = objTexture:find("_", -3, true);
        local objTextureID = tonumber(objTexture:sub(index+1));
        local objTextureName = objTexture:sub(0, index-1);
        local objectData = self.object:getModData();
        local money = (self.character:getInventory():FindAndReturn("Base.Money") or self.character:getInventory():AddItem("Base.Money"));
        local amount = 0;
        if self.flags.isPayphone then
            amount = tonumber(ZombRand(loot.PayphoneMinBills, loot.PayphoneMaxBills+1) .. "." .. ZombRand(loot.PayphoneMinChange, loot.PayphoneMaxChange+1));
        elseif self.flags.isArcadeMachine then
            amount = objectData.ZConomy.loot;
        end
        ZConomy.addToMoney(money, amount);

        objectData.ZConomy.loot = 0;
        self.object:transmitModData();
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ZCPryOpenAction:new(character, object, flags)
    local o = ISBaseTimedAction.new(self, character);
    setmetatable(o, self);
    self.__index = self;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.character = character;
    o.object = object;
    o.flags = flags;
    o.x = character:getX();
    o.y = character:getY();
    o.z = character:getZ();
    o.maxTime = 120;
    return o;
end
