-- Notification "class"
local Notification = {}
Notification.__index = Notification

function Notification.new(text, centerX, centerY, scale, lifeTime, red, green, blue, opaque, host)
	local self = setmetatable({}, Notification)
	self.host = host

	self.text = text
	self.centerX = centerX or 0
	self.centerY = centerY or 0
	self.scale = scale or 3
	self.lifeTime = lifeTime or 1

	self.xSpeed = 0
	self.ySpeed = 0

	-- Color, opaque and mode
	self.red = red or 1
	self.green = green or 1
	self.blue = blue or 1
	self.opaque = opaque or 1

	return self
end

function Notification:update(dt)
	self.lifeTime = self.lifeTime - dt

	self.centerX = self.centerX + self.xSpeed * dt
	self.centerY = self.centerY + self.ySpeed * dt
end

function Notification:draw()
	love.graphics.setColor(self.red, self.green, self.blue, self.opaque) -- White
    local textX = self.centerX - love.graphics.getFont():getWidth(self.text) * self.scale / 2
    local textY = self.centerY - love.graphics.getFont():getHeight(self.text) * self.scale / 2
	local orientation = 0
	love.graphics.print(self.text, textX, textY, orientation, self.scale, self.scale)
	love.graphics.setColor(1,1,1,1)
end

function Notification:shouldDestroy()
	if self.lifeTime <= 0 then return true end
	return false
end

return { Notification = Notification}