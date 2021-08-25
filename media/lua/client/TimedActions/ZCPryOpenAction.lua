require 'TimedActions/ISBaseTimedAction'

ZCPryOpenAction = ISBaseTimedAction:derive('ZCPryOpenAction');

function ZCPryOpenAction:isValid()
    return self.character ~= nil and self.object ~= nil;
end

function ZCPryOpenAction:update()
end

function ZCPryOpenAction:start()
    local player = self.character;
    player:faceThisObject(self.object);
    getSoundManager():PlayWorldSoundWav('ZC_PryMachine', player:getCurrentSquare(), 0, 15, 1, true);
    addSound(player, player:getX(), player:getY(), player:getZ(), 50, 15);
end

function ZCPryOpenAction:stop()
    ISBaseTimedAction.stop(self);
end

function ZCPryOpenAction:perform()
    local player = self.character;
    local container = self.object:getContainer();
    local loot = ZConomy.config.Loot;

    -- Make a final bang to signal dinner time
    addSound(player, player:getX(), player:getY(), player:getZ(), 50, 30);

    -- Now get the food and run
    if container ~= nil then
        -- default is snack machine
        local items = {'Crisps','Crisps2','Crisps3'};
        if container:getType() == 'vendingpop' then
            -- change the items to drinks if it's a soda machine
            items = {'Pop','Pop2','Pop3','PopBottle'};
        end
        -- Add 2/3 to 3/4 since some were destroyed while opening the machine
        local objectData = self.object:getModData();
        for i = 0, math.floor(ZombRandFloat(objectData.ZC_Remaining * (2/3), objectData.ZC_Remaining * (3/4))) do
            container:AddItem('Base.'..items[ZombRand(#items)+1]);
        end
        objectData.ZC_Remaining = 0;
        self.object:transmitModData();
    else
        -- Not a vending machine
        local objTexture = self.object:getTextureName();
        local index = objTexture:find("_", -3, true);
        local objTextureID = tonumber(objTexture:sub(index+1));
        local objTextureName = objTexture:sub(0, index-1);
        local objectData = self.object:getModData();
        local money = (self.character:getInventory():FindAndReturn("Base.Money") or self.character:getInventory():AddItem("Base.Money"));
        local moneyData = money:getModData();
        local amount = tonumber(moneyData.amount);
        if objTextureName == "location_shop_accessories_01" and
           ((objTextureID < 5) or
            ((objTextureID > 19) and ((objTextureID < 24)))) then
            -- cash registers
            amount = amount + tonumber(ZombRand(loot.RegisterMinBills,loot.RegisterMaxBills+1) .. '.' .. ZombRand(loot.RegisterMinChange,loot.RegisterMaxChange+1));
        elseif objTextureName == "street_decoration_01" then
            -- payphones
            amount = amount + tonumber(ZombRand(loot.PayphoneMinBills,loot.PayphoneMaxBills+1) .. '.' .. ZombRand(loot.PayphoneMinChange,loot.PayphoneMaxChange+1));
        elseif objTextureName == "recreational_01" then
            -- arcade machines
            amount = amount + objectData.ZC_Remaining;
        end
        moneyData.amount = string.format("%.2f", amount);
        moneyData.tooltip = {};
        moneyData.tooltip.amount = moneyData.amount;

        objectData.ZC_Remaining = 0;
        self.object:transmitModData();
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ZCPryOpenAction:new(character, object)
    local o = ISBaseTimedAction.new(self, character);
    setmetatable(o, self);
    self.__index = self;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.character = character;
    o.object = object;
    o.maxTime = 120;
    return o;
end