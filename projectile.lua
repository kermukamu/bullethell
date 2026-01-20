-- Projectile "class"
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, r, sx, sy, w, h, damage, affectEnemy, affectPlayer)
	local self = setmetatable({}, Projectile)

	-- Position and dimensions
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 0.2
	self.sy = sy or 0.2
	self.w = w or 10
	self.h = h or 10

	-- Movement
	self.xSpeed = 0
	self.ySpeed = 0

	-- Effect
	self.damage = damage or 0
	self.affectEnemy = affectEnemy or false
	self.affectPlayer = affectPlayer or false
	self.beingAnnihilated = false
	self.annihilationRate = 2

	-- Other
	self.health = 1
	self.cShift = 0
	self.opaque = 1
	return self
end

function Projectile:update(dt)
    self:posUpdate(dt)
    self.cShift = self.cShift + (dt * 0.5)

    if self.beingAnnihilated then
    	self.opaque = self.opaque - self.annihilationRate * dt
    	if self.opaque <= 0 then self.health = 0 end
    end
end

function Projectile:posUpdate(dt)
	-- Update position
	self.x = self.x + self.xSpeed * dt
	self.y = self.y + self.ySpeed * dt
end

function Projectile:draw()
    if self.affectPlayer then
    	local r, g, b = 1, 0, math.sin(self.cShift)
    	love.graphics.setColor(r, g, b, self.opaque)
    	love.graphics.rectangle( "fill", self.x, self.y, self.w*self.sx, self.h*self.sx)
    	love.graphics.setColor(1,1,1,1)
    end
    if self.affectEnemy then
       	local r, g, b = math.sin(self.cShift), 1, 0
        love.graphics.setColor(r, g, b, self.opaque)
    	love.graphics.rectangle( "fill", self.x, self.y, self.w*self.sx, self.h*self.sx)
    	love.graphics.setColor(1,1,1,1)
    end

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

return { Projectile = Projectile}