require "TimedActions/ISBaseTimedAction";

ZCPlayArcadeAction = ISBaseTimedAction:derive("ZCPlayArcadeAction");

function ZCPlayArcadeAction:isValid()
    return self.character ~= nil and self.object ~= nil;
end

function ZCPlayArcadeAction:update()
    self.tick = self.tick + 1;
    if self.tick >= self.timer then
        self.tick = 0;
        -- Change mood
        self.bodyDamage:setBoredomLevel(math.max(0, self.bodyDamage:getBoredomLevel() - tonumber(ZConomy.config.Options.ArcadeBoredomRate)));
        self.bodyDamage:setUnhappynessLevel(math.max(0, self.bodyDamage:getUnhappynessLevel() - tonumber(ZConomy.config.Options.ArcadeUnhappyRate)));
        self.stats:setStress(math.max(0, self.stats:getStress() - tonumber(ZConomy.config.Options.ArcadeStressRate)));
        addSound(self.character, self.x, self.y, self.z, 10, 10);
    end
end

function ZCPlayArcadeAction:start()
    local arcadePrice = tonumber(ZConomy.config.Prices.Arcade);

    -- Charge money
    ZConomy.addToMoney(self.money, -arcadePrice);

    -- Update to new format
    local objectData = self.object:getModData();
    -- Add the money to the machine's total
    objectData.ZConomy.loot = objectData.ZConomy.loot + arcadePrice;
    self.object:transmitModData();
    
    --TODO: Add arcade noises, perhaps even different types
    -- getSoundManager():PlayWorldSoundWav("ZC_ArcadeMachine", self.character:getCurrentSquare(), 1, 20, 1, false);
    getSoundManager():PlayWorldSoundWav("ArcadeMachineAmbiance", self.object:getCurrentSquare(), 1, 20, 1, false);
    addSound(self.character, self.x, self.y, self.z, 10, 10);
end

function ZCPlayArcadeAction:stop()
    ISBaseTimedAction.stop(self);
end

function ZCPlayArcadeAction:perform()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ZCPlayArcadeAction:new(character, object, money)
    local o = ISBaseTimedAction.new(self, character);
    setmetatable(o, self);
    self.__index = self;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.character = character;
    o.bodyDamage = character:getBodyDamage();
    o.object = object;
    o.money = money;
    o.maxTime = 300 + (ZombRand(1,6) * 30);
    o.timer = 30;
    o.tick = 0;
    o.x = character:getX();
    o.y = character:getY();
    o.z = character:getZ();
    return o;
end
