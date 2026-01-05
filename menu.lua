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
	print("No action on key press")
	io.stdout:flush()
end

return { Menu = Menu}