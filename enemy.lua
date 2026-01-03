local cprojectile = require("projectile")
Projectile = cprojectile.Projectile

-- Enemy "class"
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, r, sx, sy, spr, sprW, sprH)
	local self = setmetatable({}, Enemy)
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.sprite = spr
	self.w = sprW or 128
	self.h = sprH or 128
	self.health = 100
	self.shotDamage = 10
	self.shotCooldown = 0
	self.hurtCooldown = 0
	self.maxShotCooldown = 1
	self.maxHurtCooldown = 0.1
	self.xSpeed = 0
	self.ySpeed = 0
	self.drag = 30
	self.maxMoveSpeed = 500

	return self
end

function Enemy:update(dt, projectileTable)
    self.shotCooldown = math.max(0, self.shotCooldown - dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)
    self:posUpdate(dt)

    -- Run collision checks
    if self.hurtCooldown <= 0 then
    	for _, p in ipairs(projectileTable) do
			if p.affectEnemy and p:collidesWith(self) then
				p.health = p.health - 1
				self.health = self.health - p.damage
				self.hurtCooldown = maxHurtCooldown
			end
    	end
    end

    self._debugTimer = (self._debugTimer or 0) + dt
    if self._debugTimer >= 0.5 then
        self._debugTimer = 0
        --self:printStatus()
    end
end 

function Enemy:draw()
	if self.hurtCooldown > 0 then love.graphics.setColor(1,1,1,0.3) end
    love.graphics.draw(self.sprite, self.x, self.y, self.r, self.sx, self.sy)
    love.graphics.setColor(1,1,1,1)
end

function Enemy:shoot(projectileTable, sprite)
	if (self.shotCooldown <= 0) then
		self.shotCooldown = self.maxShotCooldown
		local spriteW = sprite:getWidth()
		local shot = Projectile.new(self:getXCenter() - (spriteW / 2), self.y + 10, 0, 1, 1, sprite, spriteW, sprite:getHeight(), self.shotDamage, false, true)
		shot.ySpeed = 600
		table.insert(projectileTable, shot)
	end
end

function Enemy:getXCenter()
	local retX = self.x + (self.w / 2)
	return retX
end

function Enemy:getYCenter()
	local retY = self.y + (self.h / 2) 
	return retY
end

function Enemy:posUpdate(dt)
	-- Update Enemy position
	self.x = self.x + self.xSpeed * dt
	self.y = self.y + self.ySpeed * dt

	-- Slow down Enemy movement
	local damping = math.exp(-self.drag * dt)
    self.xSpeed = self.xSpeed * damping
    self.ySpeed = self.ySpeed * damping

    -- Stop tiny drift
    if math.abs(self.xSpeed) < 0.01 then self.xSpeed = 0 end
    if math.abs(self.ySpeed) < 0.01 then self.ySpeed = 0 end
end

function Enemy:shouldDestroy()
	-- 0 HP
	if self.health <= 0 then return true end

	-- Off-scene
	local wScene = love.graphics.getWidth()
	local hScene = love.graphics.getHeight()
	if self.x < -500 or self.x > wScene + 500 or self.y < -500 or self.y > hScene + 500 then return true end
	return false
end

return { Enemy = Enemy}