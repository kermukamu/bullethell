-- Projectile "class"
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, r, sx, sy, spr, sprW, sprH, damage, affectEnemy, affectPlayer)
	local self = setmetatable({}, Projectile)
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 0.2
	self.sy = sy or 0.2
	self.sprite = spr
	self.w = sprW or 10
	self.h = sprH or 10
	self.health = 1
	self.damage = damage or 0
	self.xSpeed = 0
	self.ySpeed = 0
	self.affectEnemy = affectEnemy or false
	self.affectPlayer = affectPlayer or false
	return self
end

function Projectile:update(dt)
    self:posUpdate(dt)

    self._debugTimer = (self._debugTimer or 0) + dt
    if self._debugTimer >= 0.5 then
        self._debugTimer = 0
        --self:printStatus()
    end
end

function Projectile:posUpdate(dt)
	-- Update position
	self.x = self.x + self.xSpeed * dt
	self.y = self.y + self.ySpeed * dt
end

function Projectile:draw()
    love.graphics.draw(self.sprite, self.x, self.y, self.r, self.sx, self.sy)
end

function Projectile:collidesWith(object)
	return self.x < object.x + object:scaledW() and
		object.x < self.x + self:scaledW() and
		self.y < object.y + object:scaledH() and
		object.y < self.y + self:scaledH()
end

function Projectile:shouldDestroy()
	-- 0 HP
	if self.health <= 0 then return true end

	-- Off-scene
	local wScene = love.graphics.getWidth()
	local hScene = love.graphics.getHeight()
	if self.x < -100 or self.x > wScene + 100 or self.y < -100 or self.y > hScene + 100 then return true end
	return false
end

function Projectile:getXCenter()
	local retX = self.x + (self.w / 2)
	return retX
end
 
function Projectile:getYCenter()
	local retY = self.y + (self.h / 2) 
	return retY
end

function Projectile:scaledW()
	return self.w * self.sx
end

function Projectile:scaledH()
	return self.h * self.sy
end

function Projectile:normDirectionTo(x, y)
	local a = x - self:getXCenter()
	local b = y - self:getYCenter()
	local c = math.sqrt(a^2 + b^2)
	return {a / c, b / c}
end

return { Projectile = Projectile}