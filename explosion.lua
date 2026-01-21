-- Explosion "class"
local Explosion = {}
Explosion.__index = Explosion

function Explosion.new(x, y, maxRadius, expansionSpeed, red, green, blue, opaque, mode, level)
	local self = setmetatable({}, Explosion)
	self.level = level

	--Position and geometry
	self.x = x or 0
	self.y = y or 0
	self.maxRadius = maxRadius or 100
	self.expansionSpeed = expansionSpeed or 10 -- radial expansion speed
	self.radius = 1

	-- Effect movement
	self.xSpeed = 0
	self.ySpeed = 0

	-- Color, opaque and mode
	self.red = red or 1
	self.green = green or 1
	self.blue = blue or 1
	self.opaque = opaque or 1
	self.mode = mode

	return self
end

function Explosion:update(dt)
	self.radius = self.radius + self.expansionSpeed * dt
	self.x = self.x + self.xSpeed * dt
	self.y = self.y + self.ySpeed * dt
end

function Explosion:draw()
    love.graphics.setColor(self.red, self.green, self.blue, self.opaque)
    love.graphics.circle(self.mode, self.x, self.y, self.radius)
    love.graphics.setColor(1,1,1,1)
end

function Explosion:shouldDestroy()
	-- Exceeds max radius
	if self.radius >= self.maxRadius then return true end

	-- Off-scene
	local wScene = love.graphics.getWidth()
	local hScene = love.graphics.getHeight()
	if self.x < -500 or self.x > wScene + 500 or self.y < -500 or self.y > hScene + 500 then return true end
	return false
end

return { Explosion = Explosion}