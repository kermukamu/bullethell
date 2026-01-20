local cbutton = require("button")
Button = cbutton.Button

-- Menu "class"
local Menu = {}
Menu.__index = Menu

function Menu.new(debugmode, host)
	local self = setmetatable({}, Menu)
	self.debugmode = debugmode
	self.host = host

	self.buttonTable = {}
	self.centeredTextTable = {}
	return self
end

function Menu:update(dt)
end

function Menu:draw()
	for _, b in ipairs(self.buttonTable) do
		b:draw()
	end

	for _, t in ipairs(self.centeredTextTable) do
		self:printXCenteredText(t.text, t.centerX, t.y, t.scale)
	end
end

function Menu:printXCenteredText(text, centerX, textY, scale)
	local textX = centerX - love.graphics.getFont():getWidth(text)*scale/2
	local orientation = 0
	love.graphics.print(text, textX, textY, orientation, scale, scale)
end

function Menu:mousepressed(mx, my, button)
	if button == 1 then
		for _, b in ipairs(self.buttonTable) do
			if b:containsPoint(mx, my) then
				b.func()
			end
		end
	end
end

function Menu:keypressed(key)
	if self.buttonTable[1] then
		-- If any key is pressed, activate first button. A placeholder solution
		self.buttonTable[1].func()
	end
end

return { Menu = Menu}