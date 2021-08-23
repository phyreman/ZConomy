require 'ISUI/ISToolTipInv'

if ISToolTipInv.loaded ~= nil then
    print('INFO: Custom tooltips already loaded, skipping...');
    return
else
    ISToolTipInv.loaded = 1
end

function ISToolTipInv:render()
    -- we render the tool tip for inventory item only if there's no context menu showed
    if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
        -- tool tips are glitched in that they do not set their properties set before DoTooltip is called
        -- therefore we cannot ensure that they are placed correctly

        local mx = getMouseX() + 24;
        local my = getMouseY() + 24;
        if not self.followMouse then
            mx = self:getX()
            my = self:getY()
        end

        -- if not self.toolTipDone then
            self.tooltip:setX(mx+11);
            self.tooltip:setY(my);
            self.tooltip:setWidth(50)
            self.item:DoTooltip(self.tooltip);
           -- self.toolTipDone = true;
           -- return;
        -- end

        -- clampy x, y

        local myCore = getCore();
        local maxX = myCore:getScreenWidth();
        local maxY = myCore:getScreenHeight();

        local tw = self.tooltip:getWidth();
        local th = self.tooltip:getHeight();

        local lh = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight();

        self.tooltip:setX(math.max(0, math.min(mx + 11, maxX - tw - 1)));
        self.tooltip:setY(math.max(0, math.min(my, maxY - th - 1)));

        self:setX(self.tooltip:getX() - 11);
        self:setY(self.tooltip:getY());
        self:setWidth(tw + 11);

        local itemData = nil;
        if self.item:hasModData() then
            itemData = self.item:getModData();
            if itemData.tooltip ~= nil then
                -- Adjust height of tooltip box
                th = th + (lh * table.length(itemData.tooltip));
            end
        end

        self:setHeight(th);

        self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
        self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

        if itemData ~= nil and itemData.tooltip ~= nil then
            -- local x = 5;
            local count = 1;
            local label;
            local ty;
            for key in pairs(itemData.tooltip) do
                ty = 25 + (lh * count);
                label = key:gsub('^%l', string.upper) .. ':';
                self.tooltip:DrawText(label, 5, ty, 1,1,0.8,1);
                -- [x = ] pad + 40 + getTextManager():MeasureStringX(UIFont.Small, label)
                self.tooltip:DrawText(itemData.tooltip[key], (self.width / 2) + 12, ty, 1,1,1,1);
                count = count + 1;
            end
        end

        self.item:DoTooltip(self.tooltip);
    end
end