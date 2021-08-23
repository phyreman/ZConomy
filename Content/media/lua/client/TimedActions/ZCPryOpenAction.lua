require 'TimedActions/ISBaseTimedAction'

ZCPryOpenAction = ISBaseTimedAction:derive('ZCPryOpenAction');

function ZCPryOpenAction:isValid()
    return self.character ~= nil;
end

function ZCPryOpenAction:update()
end

function ZCPryOpenAction:start()
    --FIX: Make it based on stealth, starting from really loud to kinda quiet
    getSoundManager():PlayWorldSoundWav('pryMachine', self.object:getSquare(), 1, 20, 1, false);
end

function ZCPryOpenAction:stop()
    ISBaseTimedAction.stop(self);
end

function ZCPryOpenAction:perform()
    if ZConomy.plugin ~= nil then
        ZConomy.plugin.OnBruteForce();
        ISBaseTimedAction.perform(self);
        return;
    end

    -- default is snack machine
    local items = {'Crisps','Crisps2','Crisps3'};
    local container = self.object:getContainer();
    if container:getType() == 'vendingpop' then
        items = {'Pop','Pop2','Pop3','PopBottle'};
    end
    -- Add 2/3 to 3/4 since some were destroyed while opening the machine
    local objectData = self.object:getModData();
    for i = 0, math.floor(ZombRandFloat(objectData.remaining * (2/3), objectData.remaining * (3/4))) do
        container:AddItem('Base.'..items[ZombRand(#items)+1]);
    end
    objectData.remaining = 0;
    self.object:transmitModData();
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ZCPryOpenAction:new(character, object)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.character = character;
    o.object = object;
    o.maxTime = 100;
    return o;
end