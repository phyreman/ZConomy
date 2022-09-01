ZCMoneyPromptUI = ISPanelJoypad:derive("ZCMoneyPromptUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium);

function ZCMoneyPromptUI:initialise()
	ISPanelJoypad.initialise(self);
	
	local fontHgt = FONT_HGT_SMALL;
	local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12;
	local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12;
	local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100);
	local buttonHgt = math.max(fontHgt + 6, 25);
	local padBottom = 10;
	
	self.yes = ISButton:new((self:getWidth() / 2)  - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Ok"), self, ZCMoneyPromptUI.onClick);
	self.yes.internal = "OK";
	self.yes:initialise();
	self.yes:instantiate();
	self.yes.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.yes);
	
	self.no = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, ZCMoneyPromptUI.onClick);
	self.no.internal = "CANCEL";
	self.no:initialise();
	self.no:instantiate();
	self.no.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.no);
	
	self.fontHgt = FONT_HGT_MEDIUM;
	local inset = 2;
	local height = inset + self.fontHgt * self.numLines + inset;
	local y = 55;

	local label = ISLabel:new((self:getWidth() / 3) - 15, y, height, getText("IGUI_PlayerStats_Amount")..":", 1, 1, 1, 1, UIFont.Small);
	label:initialise();
	self:addChild(label);

	self.entryAmount = ISTextEntryBox:new("", (self:getWidth() / 3), y, (self:getWidth() / 2) - 20, height);
	self.entryAmount.font = UIFont.Medium;
	-- self.entryAmount.tooltip = "";
	self.entryAmount:initialise();
	self.entryAmount:instantiate();
	self.entryAmount:setOnlyNumbers(true);
	self:addChild(self.entryAmount);
end

function ZCMoneyPromptUI:destroy()
	UIManager.setShowPausedMessage(true);
	self:setVisible(false);
	self:removeFromUIManager();
end

function ZCMoneyPromptUI:onClick(button)
	if button.internal == "CANCEL" then
		self:destroy();
		return;
	end
	if self.onclick ~= nil then
		self.onclick(self.player, self.money, tonumber(self.entryAmount:getInternalText()));
		self:destroy();
	end
end

function ZCMoneyPromptUI:titleBarHeight()
	return 16;
end

function ZCMoneyPromptUI:prerender()
	self.backgroundColor.a = 0.8;
	self.entryAmount.backgroundColor.a = 0.8;
	
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	
	local th = self:titleBarHeight();

	self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	self:drawTextCentre(getText("IGUI_EnterCustomAmount"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);
	self:updateButtons();
end

function ZCMoneyPromptUI:updateButtons()
	self.yes:setEnable(true);
	self.yes.tooltip = nil;
	if string.trim(self.entryAmount:getInternalText()) == "" then
		self.yes:setEnable(false);
		self.yes.tooltip = getText("IGUI_TextBox_CantBeEmpty");
	end
end

function ZCMoneyPromptUI:render()
end

function ZCMoneyPromptUI:onMouseMove(dx, dy)
	self.mouseOver = true;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
		self:bringToTop();
	end
end

function ZCMoneyPromptUI:onMouseMoveOutside(dx, dy)
	self.mouseOver = false;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
		self:bringToTop();
	end
end

function ZCMoneyPromptUI:onMouseDown(x, y)
	if not self:getIsVisible() then
		return;
	end
	self.downX = x;
	self.downY = y;
	self.moving = true;
	self:bringToTop();
end

function ZCMoneyPromptUI:onMouseUp(x, y)
	if not self:getIsVisible() then
		return;
	end
	self.moving = false
	if ISMouseDrag.tabPanel then
		ISMouseDrag.tabPanel:onMouseUp(x,y);
	end
	ISMouseDrag.dragView = nil;
end

function ZCMoneyPromptUI:onMouseUpOutside(x, y)
	if not self:getIsVisible() then
		return;
	end
	self.moving = false;
	ISMouseDrag.dragView = nil;
end

function ZCMoneyPromptUI:new(x, y, width, height, player, money, onclick)
	local o = {};
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	if y == 0 then
		o.y = o:getMouseY() - (height / 2);
		o:setY(o.y);
	end
	if x == 0 then
		o.x = o:getMouseX() - (width / 2);
		o:setX(o.x);
	end
	o.name = nil;
	o.backgroundColor = {r=0, g=0, b=0, a=0.5};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.width = width;
	local txtWidth = getTextManager():MeasureStringX(UIFont.Small, text) + 10;
	if width < txtWidth then
		o.width = txtWidth;
	end
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;
	o.onclick = onclick;
	o.player = player;
	o.money = money;
	o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
	o.numLines = 1;
	o.maxLines = 1;
	o.multipleLine = false;
	return o;
end
