TagsDisplay = class("TagsDisplay", Entity)

function TagsDisplay:initialize(params)
    self.layer = params.layer or 100
    self.upLayer = params.upLayer or 100
    self.x = params.x or 50 -- this will be center now
    self.y = params.y or 50
    self.padding = params.padding or 10
    self.spacing = params.spacing or 2
    self.tagColor = params.tagColor or {1, 1, 1, 1}
    self.bgColor = params.bgColor or {0, 0, 0, 0.5}
    self.radius = params.radius or 100
    self.tags = params.tags or {}
    self.font = params.font or fonts.main
    
    Entity.initialize(self, params)
end

function TagsDisplay:setTags(tags)
    self.tags = tags or {}
end

function TagsDisplay:update(dt)
    self.hovered = false
    if self:isMouseOver() then
        self.hovered = true
    end
	if not cs.menuItems then
		self.delete = true
	end
end

function TagsDisplay:isMouseOver()
    local x, y = mouse.rx, mouse.ry
    local width = self:getWidth()
    local height = self:getHeight()
    local left = self.x - width / 2
    local right = self.x + width / 2
    return x >= left and x <= right and y >= self.y and y <= self.y + height
end

function TagsDisplay:getWidth()
    local maxWidth = 0
    for _, tag in ipairs(self.tags) do
        local w = self.font:getWidth(tag)
        if w > maxWidth then maxWidth = w end
    end
    return maxWidth + self.padding * 2
end

function TagsDisplay:getHeight()
    local totalHeight = 0
    local lineHeight = self.font:getHeight()
    for _ in ipairs(self.tags) do
        totalHeight = totalHeight + lineHeight + self.spacing
    end
    return totalHeight + self.padding * 2
end

function TagsDisplay:draw()
    if (cs.menuItems and cs.selection and not cs.menuItems[cs.selection].isLevel) or #self.tags == 0 then return end
    
    local width = self:getWidth()
    local height = self:getHeight()
    
    local left = self.x - width 
    
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle("fill", left, self.y, width, height)
    love.graphics.setFont(self.font)
    
    local yPos = self.y + self.padding
    for _, tag in ipairs(self.tags) do
        love.graphics.setColor(self.tagColor)
        love.graphics.printf(tag, left + self.padding, yPos, width - self.padding * 2, "center") -- center text
        yPos = yPos + self.font:getHeight() + self.spacing
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return TagsDisplay
