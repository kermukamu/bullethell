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

	-- Draw controls text
	self.host:printXCenteredText("WASD to move\nSHIFT for speed\nSPACE to shoot", love.graphics.getWidth()/2, love.graphics.getHeight()/2 - 300, 3)
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
	self.buttonTable[1].func() -- If any key is pressed. A placeholder solution until more complicated menu exists
end

return { Menu = Menu}