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
	return self
end

function Menu:update(dt)
end

function Menu:draw()
	for _, b in ipairs(self.buttonTable) do
		b:draw()
	end
end

function Menu:printXCenteredText(text, x, y, scale)
	local tX = x - love.graphics.getFont():getWidth(text)*scale/2
	love.graphics.print(text, tX, y, 0, scale, scale)
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
		self.buttonTable[1].func() -- If any key is pressed, activate first button. A placeholder solution until more complicated menu exists
	end
end

return { Menu = Menu}