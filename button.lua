-- Button "class"
local Button = {}
Button.__index = Button

function Button.new(text, func, w, h, centX, centY, textScale)
	local self = setmetatable({}, Button)
	self.w = w
	self.h = h
	self.centX = centX
	self.centY = centY
	self.tScale = textScale or 1
	self.func = func or function() print("Button does nothing") io.stdout:flush() end
	self.text = text

	return self
end

function Button:draw()
	local tWidth = love.graphics.getFont():getWidth(self.text) * self.tScale
	local tHeight = love.graphics.getFont():getHeight() * self.tScale
	local recXY = self:asCenter(self.centX, self.centY, self.w, self.h)
	local textXY = self:asCenter(self.centX, self.centY, tWidth, tHeight)
	local orientation = 0

	love.graphics.rectangle("line", recXY[1], recXY[2], self.w, self.h)
	love.graphics.print(self.text, textXY[1], textXY[2], orientation, self.tScale, self.tScale)
end

function Button:containsPoint(x, y)
	local recXY = self:asCenter(self.centX, self.centY, self.w, self.h)
	local bx = recXY[1]
	local by = recXY[2]

    return
        x >= bx and
        x <= bx + self.w and
        y >= by and
        y <= by + self.h
end

-- Get equivalent coordinates so the original coordinates are the center
function Button:asCenter(cx, cy, w, h)
	local x = cx- (w / 2)
	local y = cy - (h / 2)
	return {x, y}
end

return { Button = Button}