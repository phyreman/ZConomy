require 'ISUI/ISToolTipInv'

function ISToolTipInv:render()
    -- we render the tool tip for inventory item only if there's no context menu showed
    if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then

    local mx = getMouseX() + 24;
    local my = getMouseY() + 24;
    if not self.followMouse then
        mx = self:getX()
        my = self:getY()
        if self.anchorBottomLeft then
            mx = self.anchorBottomLeft.x
            my = self.anchorBottomLeft.y
        end
    end

    self.tooltip:setX(mx+11);
    self.tooltip:setY(my);

    self.tooltip:setWidth(50)
    self.tooltip:setMeasureOnly(true)
    self.item:DoTooltip(self.tooltip);
    self.tooltip:setMeasureOnly(false)

     -- clampy x, y

    local myCore = getCore();
    local maxX = myCore:getScreenWidth();
    local maxY = myCore:getScreenHeight();

    local tw = self.tooltip:getWidth();
    local th = self.tooltip:getHeight();
     
    self.tooltip:setX(math.max(0, math.min(mx + 11, maxX - tw - 1)));
    if not self.followMouse and self.anchorBottomLeft then
        self.tooltip:setY(math.max(0, math.min(my - th, maxY - th - 1)));
    else
        self.tooltip:setY(math.max(0, math.min(my, maxY - th - 1)));
    end

    self:setX(self.tooltip:getX() - 11);
    self:setY(self.tooltip:getY());
    self:setWidth(tw + 11);
    -- START PATCH
    local lh = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight();
    -- helper function
    function len(T)
        local c = 0
        for _ in pairs(T) do c = c + 1 end
        return c
    end

    local itemData = nil;
    if self.item:hasModData() then
        itemData = self.item:getModData();
        if itemData.tooltip ~= nil then
            th = th + (lh * len(itemData.tooltip));
        end
    end
    
    self:setHeight(th + 5);
    -- END PATCH
    
    if self.followMouse then
        self:adjustPositionToAvoidOverlap({ x = mx - 24 * 2, y = my - 24 * 2, width = 24 * 2, height = 24 * 2 })
    end

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    -- START PATCH
    if itemData ~= nil and itemData.tooltip ~= nil then
        -- local x = 5;
        local count = 0;
        local label;
        local ty;
        th = th - (lh * len(itemData.tooltip));
        -- if self.item.weight == self.item:getWeightOfStack() then
        --     local stackAmount = 0;
        --     self.tooltip:DrawText("Stack Amount:", 5, th, 1,1,0.8,1);
        --     self.tooltip:DrawText(stackAmount, (self.width / 2) + 12, th, 1,1,1,1);
        --     th = th + lh;
        --     count = count + 1;
        -- end
        for key,value in pairs(itemData.tooltip) do
            ty = th + (lh * count);
            label = key:gsub('^%l', string.upper) .. ':';
            self.tooltip:DrawText(label, 5, ty, 1,1,0.8,1);
            -- [x = ] pad + 40 + getTextManager():MeasureStringX(UIFont.Small, label)
            self.tooltip:DrawText(value, (self.width / 2) + 12, ty, 1,1,1,1);
            count = count + 1;
        end
    end
    -- END PATCH
    self.item:DoTooltip(self.tooltip);
    end
end
