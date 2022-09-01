ZConomy.initInventoryContextMenu = function(_player, context, items)
	if #items ~= 1 then return end

	local item = items[1];
	if type(item) == "table" then
		-- Jump over the dummy item that is contained in the item-table.
		item = item.items[1];
	end

	if instanceof(item, "InventoryItem") and (item:getType() == "Money") then
		local player = getSpecificPlayer(_player);
		local subMenu = context:getNew(context);
		subMenu:addOption(getText("ContextMenu_Split_Stack", 10, 90), player, ZConomy.splitMoneyStack, item, 0.1);
		subMenu:addOption(getText("ContextMenu_Split_Stack", 25, 75), player, ZConomy.splitMoneyStack, item, 0.25);
		subMenu:addOption(getText("ContextMenu_Split_Stack", 50, 50), player, ZConomy.splitMoneyStack, item, 0.5);
		subMenu:addOption(getText("ContextMenu_Split_Stack", 75, 25), player, ZConomy.splitMoneyStack, item, 0.75);
		subMenu:addOption(getText("ContextMenu_Split_Stack", 90, 10), player, ZConomy.splitMoneyStack, item, 0.9);
		subMenu:addOption(getText("ContextMenu_Split_Stack_Custom"), player, ZConomy.initMoneyPrompt, item);
		context:addSubMenu(context:addOption(getText("ContextMenu_SplitStack"), nil, nil), subMenu);
	end
end

ZConomy.initWorldContextMenu = function(_player, context, worldobjects)
	local player = getSpecificPlayer(_player);
	local object = worldobjects[1];
	local objType = nil;
	if object:getContainer() then
		objType = object:getContainer():getType():gsub("vending", "");
	end
	local objTexture = object:getTextureName();
	local index = objTexture:find("_", -3, true);
	local objTextureID = tonumber(objTexture:sub(index+1));
	local objTextureName = objTexture:sub(0, index-1);
	local config = ZConomy.config;
	-- location_shop_accessories_01_[0-4] = white registers
	-- location_shop_accessories_01_[20-23] = black registers
	-- location_shop_accessories_01_[16,17] = snack machine
	-- location_shop_accessories_01_[18,19] = soda machine
	--NOTE Machine 26 is just the top half and 27 is the bottom half, we only want the bottom half to trigger a menu
	-- recreational_01_[16-25,27] = arcade machines
	-- street_decoration_01_[38,39] = payphones
	-- location_business_bank_01_[64-67] = ATMs
	--NOTE location_business_bank_01_[68,69] = Bank Safe

	local isVendingMachine = false;
	local isArcadeMachine = false;
	-- local isCashRegister = false;
	local isPayphone = false;
	-- local isSafe = false;
	-- local isATM = false;

	if (objType == "pop" or objType == "snack") then
		isVendingMachine = true;
	end

	if (objTexture ~= nil) then
		-- if objTextureName == "location_shop_accessories_01" then
		-- 	if (objTextureID < 5) or (objTextureID > 19 and objTextureID < 24) then
		-- 		isCashRegister = true;
		-- 	end
		-- elseif objTextureName == "location_business_bank_01" then
			-- if objTextureID > 63 and objTextureID < 68 then
			-- 	isATM = true;
			-- end
			-- if objTextureID > 68 and objTextureID < 70 then
			-- 	isSafe = true;
			-- end
		if objTextureName == "street_decoration_01" then
			if objTextureID > 37 and objTextureID < 40 then
				isPayphone = true;
			end
		elseif objTextureName == "recreational_01" then
			if objTextureID > 15 and objTextureID < 28 and objTextureID ~= 26 then
				isArcadeMachine = true;
			end
		end
	end

	if not (isVendingMachine or isArcadeMachine or isPayphone--[[ or isCashRegister or isSafe or isATM--]]) then
		if ZConomy.debug then
			print("--------------------");
			print("Unwatched Texture: " .. objTexture);
			if objType then
				print("Type: " .. objType);
			end
			print("--------------------");
		end
		-- Skip invalid objects
		return;
	end

	local objectData = object:getModData();
	-- Create data table if it doesn't exist for a valid object
	if objectData.ZConomy == nil then
		objectData.ZConomy = {};
	end

	-- Dig around for spare change from payphones or arcade machines
	if isPayphone or isArcadeMachine or isVendingMachine then
		if objectData.ZConomy.looted == nil then
			objectData.ZConomy.looted = false;
			object:transmitModData();
		end
		if objectData.ZConomy.looted == false then
			context:addOption(getText("ContextMenu_CheckForChange"), object, ZConomy.checkForChange, player);
		end
	end

	if isVendingMachine and objectData.ZConomy.stock == nil then
		local type = "Snack";
		if objType == "pop" then
			type = "Drink";
		end
		objectData.ZConomy.stock = ZombRand(config.Options[type.."StockMin"], config.Options[type.."StockMax"]+1);
		object:transmitModData();
	end

	--NOTE Cash Registers don't have the loot set ahead of time since it can only be looted via a crowbar
	if objectData.ZConomy.loot == nil then
		local loot;
		if isArcadeMachine then
			loot = tonumber(ZombRand(config.Loot.ArcadeMinBills, config.Loot.ArcadeMaxBills+1) .. "." .. ZombRand(config.Loot.ArcadeMinChange, config.Loot.ArcadeMaxChange+1));
		elseif isPayphone then
			loot = tonumber(ZombRand(config.Loot.PayphoneMinBills, config.Loot.PayphoneMaxBills+1) .. "." .. ZombRand(config.Loot.PayphoneMinChange, config.Loot.PayphoneMaxChange+1));
		elseif isVendingMachine then
			loot = (300 - objectData.ZConomy.stock) * tonumber(config.Prices[objType:gsub("^%l", string.upper)]);
		end
		if loot ~= nil then
			ZConomy.updateLoot(object, loot);
			object:transmitModData();
		end
	end

	local inventory = player:getInventory();

	-- Everything can be busted open with a crowbar, so it's the last check before the power check
	if inventory:containsTypeRecurse("Crowbar") then
		-- break door open; make noise, spawn some items
		local flags = {};
		-- flags.isCashRegister = isCashRegister;
		flags.isPayphone = isPayphone;
		flags.isArcadeMachine = isArcadeMachine;
		flags.isVendingMachine = isVendingMachine;
		context:addOption(getText("ContextMenu_BreakOpen"), object, ZConomy.openMachine, player, inventory:getFirstTypeRecurse("Crowbar"), flags);
	end

	-- All of the following actions should require power, so we can return from here if there is none
	if not ((SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier) or object:getSquare():haveElectricity()) then
		player:setHaloNote(getText("IGUI_RadioRequiresPowerNearby"));
		return;
	end

	-- Only allow purchase if the player has money, it's a vending machine, and it has power
	if not inventory:containsTypeRecurse("Base.Money") then return end

	local money = inventory:getFirstTypeRecurse("Base.Money");
	local moneyData = money:getModData();
	if isVendingMachine then
		local realType = ZConomy._keys[objType];
		-- check if there's enough money to purchase the item
		if config.Prices[realType] <= tonumber(moneyData.amount) then
			context:addOption(getText("ContextMenu_Buy"..realType), player, ZConomy.purchase, object, money);
		end
	-- OR allow the player to spend money at the arcades to entertain themselves
	elseif isArcadeMachine then
		-- check if there's enough money to play
		if config.Prices.Arcade <= tonumber(moneyData.amount) then
			context:addOption(getText("ContextMenu_PlayArcadeGame"), player, ZConomy.playArcadeGame, object, money);
		end
	end
end

ZConomy.initMoneyPrompt = function(player, money)
	local ui = ZCMoneyPromptUI:new(0, 0, 300, 125, player, money, ZConomy.splitMoneyStackCustom);
	ui:initialise();
	ui:addToUIManager();
end

ZConomy.splitMoneyStack = function(player, money, delta)
	local moneyData = money:getModData();
	local amount = round(moneyData.amount * delta, 2);
	local newMoney = money:getContainer():AddItem("Base.Money");
	ZConomy.updateMoney(newMoney, amount);
	ZConomy.addToMoney(money, -amount);
end

ZConomy.splitMoneyStackCustom = function(player, money, amount)
	local newMoney = money:getContainer():AddItem("Base.Money");
	ZConomy.updateMoney(newMoney, amount);
	ZConomy.addToMoney(money, -amount);
end

ZConomy.openMachine = function(object, player, crowbar, flags)
	luautils.walkAdj(player, object:getSquare(), false);
	player:faceThisObject(object);
	if luautils.haveToBeTransfered(player, crowbar, true) then
		ISTimedActionQueue.add(ISInventoryTransferAction:new(player, crowbar, crowbar:getContainer(), player:getInventory()));
	end
	ISTimedActionQueue.add(ZCPryOpenAction:new(player, object, flags));
end

ZConomy.playArcadeGame = function(player, object, money)
	luautils.walkAdj(player, object:getSquare(), false);
	player:faceThisObject(object);
	ISTimedActionQueue.add(ZCPlayArcadeAction:new(player, object, money));
end

ZConomy.checkForChange = function(object, player)
	luautils.walkAdj(player, object:getSquare(), false);
	player:faceThisObject(object);

	-- Combine money stacks
	local inventory = player:getInventory();
	local money = inventory:FindAndReturn("Base.Money") or inventory:AddItem("Base.Money");
	local change = {0,0,0,0,0,0,0,0,0.25,0.25,0.25,0.25,0.25,0.25,0.5,0.5,0.5,0.75,0.75,1};
	ZConomy.addToMoney(money, change[ZombRand(1,#change+1)]);

	object:getModData().ZConomy.looted = true;
	object:transmitModData();
end

ZConomy.purchase = function(player, object, money)
	luautils.walkAdj(player, object:getSquare(), false);
	player:faceThisObject(object);

	local objType = object:getContainer():getType():gsub("vending", "");
	-- Charge money
	local itemPrice = tonumber(ZConomy.config.Prices[objType:gsub("^%l", string.upper)]);
	ZConomy.addToMoney(money, -itemPrice);

	-- Vend single random item
	local prefix = "Snack";
	if objType == "pop" then
		prefix = "Drink";
	end
	local items = ZConomy.config[prefix.."s"]
	object:getContainer():AddItem(items[prefix..tostring(ZombRand(1, table.length(items)+1))]);
	--TODO: Add item vend (ka-thunk) sound; only for player
	local objectData = object:getModData();
	objectData.ZConomy.stock = objectData.ZConomy.stock - 1;
	objectData.ZConomy.loot = round(objectData.ZConomy.loot + itemPrice, 2);
	object:transmitModData();
end

Events.OnPreFillInventoryObjectContextMenu.Add(ZConomy.initInventoryContextMenu);
Events.OnPreFillWorldObjectContextMenu.Add(ZConomy.initWorldContextMenu);
