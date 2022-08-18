ISInventoryTransferAction.ZCPerform = ISInventoryTransferAction.perform;
function ISInventoryTransferAction:perform()
    self:ZCPerform();
    triggerEvent("OnTransferInventoryItem", self.item, self.srcContainer, self.destContainer, self.character);
end
