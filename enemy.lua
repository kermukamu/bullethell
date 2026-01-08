local cprojectile = require("projectile")
Projectile = cprojectile.Projectile
local cinstructions = require("instructions")
Instructions = cinstructions.Instructions

-- Enemy "class"
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, r, sx, sy, w, h, instructions, level)
	local self = setmetatable({}, Enemy)
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.w = w or 128
	self.h = h or 128
	self.health = 100
	self.shotDamage = 25
	self.hurtCooldown = 0
	self.maxHurtCooldown = 0.2
	self.xSpeed = 0
	self.ySpeed = 0
	self.drag = 0
	self.maxMoveSpeed = 500
	self.instructions = Instructions.new(instructions, self)
	self.level = level
	self.cShift = 0
	self.opaque = 1
	return self
end

function Enemy:update(dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)
    if self.instructions then
    	self.instructions:callInstructions(dt)
    end
    self:posUpdate(dt)

    -- Update hurt visual effect
    if self.hurtCooldown > 0 then self.opaque = 1-(self.hurtCooldown/self.maxHurtCooldown) end

    -- Run collision checks between player projectiles and self
    if self.hurtCooldown <= 0 then
    	for _, p in ipairs(self.level.playerProjectileTable) do
			if p.affectEnemy and p:collidesWith(self) then
				p.health = p.health - 1
				self.health = self.health - p.damage
				self.hurtCooldown = self.maxHurtCooldown
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
    love.graphics.setColor(1,0,math.sin(self.cShift),self.opaque)
    love.graphics.rectangle( "fill", self.x, self.y, self.w*self.sx, self.h*self.sx)
    love.graphics.setColor(1,1,1,1)
end

function Enemy:shoot(angleDeg, speed, scale)
	if not self.level.enemyProjectileTable then return false end
	local size = 32
	local shot = Projectile.new(self:getXCenter() - (size * scale / 2), self.y + 10, 0, scale, scale, size, size, self.shotDamage, false, true)
	shot.xSpeed = math.sin(math.rad(angleDeg)) * speed + self.xSpeed
	shot.ySpeed = math.cos(math.rad(angleDeg)) * speed + self.ySpeed
	table.insert(self.level.enemyProjectileTable, shot)
end

function Enemy:getXCenter()
	local retX = self.x + (self:scaledW() / 2)
	return retX
end
 
function Enemy:getYCenter()
	local retY = self.y + (self:scaledH() / 2) 
	return retY
end

function Enemy:centerToPos()
	self.x = self.x - (self:scaledW() / 2)
	self.y = self.y - (self:scaledH() / 2)
end

function Enemy:scaledW()
	return self.w * self.sx
end

function Enemy:scaledH()
	return self.h * self.sy
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