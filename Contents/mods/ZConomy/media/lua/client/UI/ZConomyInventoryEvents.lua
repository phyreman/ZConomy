ZConomy.manageInventory = function(item, srcContainer, destContainer, character)
	-- This happens after the item has been moved from src into dest
	-- if destContainer has more than 1 money object, combine them into 1
	if srcContainer == nil or destContainer == nil or character == nil or destContainer:contains("Money") == false then
		return
	end
	local stacks = destContainer:FindAll("Money");
	if stacks:size() < 2 then return end

	local amount = 0;
	local money;
	-- Then add the value of each other object to the original
	for i = 0, stacks:size() - 1 do
		money = stacks:get(i);
		-- If the money item doesn't have modData, roll an amount and add as if it did
		if money:hasModData() then
			amount = amount + money:getModData().amount;
		else
			-- Only add a small amount (default cash register loot amount of $1-5.99) since we don't know the origin
			amount = amount + tonumber(ZombRand(1, 6) .. "." .. ZombRand(0, 100));
		end
	end
	-- Remove all money objects from the destination container (player inventory, usually)
	destContainer:RemoveAll("Money");

	-- Then create a new money object and set the amount to the total of the previous ones
	ZConomy.updateMoney(destContainer:AddItem("Base.Money"), amount);
end

-- ZConomy.addContainer = function(square)
-- 	local object = square:getIsoObject();
-- 	local objTexture = object:getTextureName();
-- 	local index = objTexture:find("_", -3, true);
-- 	local objTextureID = tonumber(objTexture:sub(index+1));
-- 	local objTextureName = objTexture:sub(0, index-1);
-- 	-- location_business_bank_01_[64-67] = ATMs
-- 	--NOTE location_business_bank_01_[68,69] = Bank Safe

-- 	if (objTexture ~= nil and
-- 			(objTextureName == "location_business_bank_01" and
-- 				(objTextureID > 63 and objTextureID < 68)
-- 			)
-- 		) then
-- 		local container = object:getContainer();
-- 		if container then
-- 			return;
-- 		end
-- 		container = ItemContainer.new("atm", square, object);
-- 		container:setExplored(true);
-- 		object:setContainer(container);
-- 		object:sendObjectChange("containers");
-- 	end
-- end

Events.OnTransferInventoryItem.Add(ZConomy.manageInventory);
-- Events.LoadGridsquare.Add(ZConomy.addContainer);
