-- SquareParticle "class"
local SquareParticle = {}
SquareParticle.__index = SquareParticle

function SquareParticle.new(x, y, size, shrinkSpeed, red, green, blue, opaque, mode, level)
	local self = setmetatable({}, SquareParticle)
	self.level = level

	--Position and geometry
	self.x = x or 0
	self.y = y or 0
	self.size = size or 16
	self.shrinkSpeed = shrinkSpeed or 1 -- Shrinking speed

	-- Effect movement
	self.xSpeed = 0
	self.ySpeed = 0

	-- Color, opaque and mode
	self.red = red or 1
	self.green = green or 1
	self.blue = blue or 1
	self.opaque = opaque or 1
	self.mode = mode or "line"

	self.lifeTimer = 1
	return self
end

function SquareParticle:update(dt)
	self.size = math.max(self.size - self.shrinkSpeed * dt, 0)
	self.x = self.x + self.xSpeed * dt
	self.y = self.y + self.ySpeed * dt
end

function SquareParticle:draw()
    love.graphics.setColor(self.red, self.green, self.blue, self.opaque)
    love.graphics.rectangle(self.mode, self.x, self.y, self.size, self.size, self.radius)
    love.graphics.setColor(1,1,1,1)
end

function SquareParticle:centerToPos()
	self.x = self.x - (self.size / 2)
	self.y = self.y - (self.size / 2)
end

function SquareParticle:shouldDestroy()
	-- Becomes too small
	if self.size <= 0 then return true end

	-- Off-scene
	local wScene = love.graphics.getWidth()
	local hScene = love.graphics.getHeight()
	if self.x < -500 or self.x > wScene + 500 or self.y < -500 or self.y > hScene + 500 then return true end
	return false
end

return { SquareParticle = SquareParticle}