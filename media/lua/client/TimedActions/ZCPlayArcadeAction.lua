require 'TimedActions/ISBaseTimedAction'

ZCPlayArcadeAction = ISBaseTimedAction:derive('ZCPlayArcadeAction');

function ZCPlayArcadeAction:isValid()
    return self.character ~= nil and self.object ~= nil;
end

function ZCPlayArcadeAction:update()
    self.tick = self.tick + 1;
    if self.tick >= self.timer then
        self.tick = 0;
        local bodyDamage = self.character:getBodyDamage();
        -- Change mood
        bodyDamage:setBoredomLevel(bodyDamage:getBoredomLevel() - ZConomy.config.Options["ArcadeBoredomRate"]);
        bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() - ZConomy.config.Options["ArcadeUnhappyRate"]);
        addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 10, 10);
    end
end

function ZCPlayArcadeAction:start()
    self.character:faceThisObject(self.object);
    -- Charge money
    ZConomy.addToMoney(self.money, -tonumber(ZConomy.config.Prices["Arcade"]));

    -- Add the money to the machine's total
    local objectData = self.object:getModData();
    objectData.ZC_Remaining = objectData.ZC_Remaining + tonumber(ZConomy.config.Prices["Arcade"]);
    self.object:transmitModData();
    
    --TODO: Add arcade noises, perhaps even different types
    -- getSoundManager():PlayWorldSoundWav('ZC_ArcadeMachine', self.character:getCurrentSquare(), 1, 20, 1, false);
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 10, 10);
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
    o.object = object;
    o.money = money;
    o.maxTime = 300 + (ZombRand(1,6) * 30);
    o.timer = 30;
    o.tick = 0;
    return o;
end