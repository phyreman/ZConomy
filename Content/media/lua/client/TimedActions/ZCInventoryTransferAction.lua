require "TimedActions/ISInventoryTransferAction"

function ISInventoryTransferAction:perform()
    self.item:setJobDelta(0.0);

    if self.destContainer:isInCharacterInventory(self.character) then

    end
    if self.srcContainer:isInCharacterInventory(self.character) then

    end
    if self.srcContainer:getType() ~= "TradeUI" and isClient() and not self.destContainer:isInCharacterInventory(self.character) and self.destContainer:getType()~="floor" then
        self.destContainer:addItemOnServer(self.item);
    end
    if self.srcContainer:getType() ~= "TradeUI" and isClient() and not self.srcContainer:isInCharacterInventory(self.character) and self.srcContainer:getType()~="floor" then
        self.srcContainer:removeItemOnServer(self.item);
    end

    if self.destContainer:getType() ~= "TradeUI" then
        self.srcContainer:DoRemoveItem(self.item);
    end
    -- clear it from the queue.
    self.srcContainer:setDrawDirty(true);
    self.srcContainer:setHasBeenLooted(true);
    self.destContainer:setDrawDirty(true);

    -- deal with containers that are floor
    if self.destContainer:getType()=="floor" then
        self.destContainer:DoAddItemBlind(self.item);
        self.character:getCurrentSquare():AddWorldInventoryItem(self.item, self.character:getX() - math.floor(self.character:getX()), self.character:getY() - math.floor(self.character:getY()), self.character:getZ() - math.floor(self.character:getZ()));
        self:removeItemOnCharacter();
    elseif self.srcContainer:getType()=="floor" and self.item:getWorldItem() ~= nil then
        self.item:getWorldItem():getSquare():transmitRemoveItemFromSquare(self.item:getWorldItem());
        self.item:getWorldItem():getSquare():getWorldObjects():remove(self.item:getWorldItem());
        self.item:getWorldItem():getSquare():getObjects():remove(self.item:getWorldItem());
        self.item:setWorldItem(nil);
        self.destContainer:DoAddItem(self.item);
    else
        if self.srcContainer:getType() ~= "TradeUI" then
            self.destContainer:DoAddItem(self.item);
        end
        if self.character:getInventory() ~= self.destContainer then
            self:removeItemOnCharacter();
        end
    end

    -- Hack for giving cooking XP.
    if instanceof(self.item, "Food") then
        self.item:setChef(self.character:getFullName())
    end

    triggerEvent("OnTransferInventoryItem", self.srcContainer, self.destContainer, self.character);

    -- do the overlay sprite
    if not isClient() then
        if self.srcContainer:getParent() and self.srcContainer:getParent():getOverlaySprite() then
            ItemPicker.updateOverlaySprite(self.srcContainer:getParent())
        end
        if self.destContainer:getParent() then
            ItemPicker.updateOverlaySprite(self.destContainer:getParent())
        end
    end

--    needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end