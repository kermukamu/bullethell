-- Explosion "class"
local Explosion = {}
Explosion.__index = Explosion

function Explosion.new(x, y, maxRadius, speed, red, green, blue, opaque, level)
	local self = setmetatable({}, Explosion)
	self.level = level
	self.x = x or 0
	self.y = y or 0
	self.maxRadius = maxRadius or 100
	self.speed = speed or 10

	-- Color and opaque
	self.red = red or 1
	self.green = green or 1
	self.blue = blue or 1
	self.opaque = opaque or 1

	self.radius = 1
	return self
end

function Explosion:update(dt)
	self.radius = self.radius + self.speed*dt
end

function Explosion:draw()
    love.graphics.setColor(self.red, self.green, self.blue, self.opaque)
    love.graphics.circle("line", self.x, self.y, self.radius)
    love.graphics.setColor(1,1,1,1)
end

function Explosion:shouldDestroy()
	if self.radius >= self.maxRadius then return true end
	return false
end

return { Explosion = Explosion}