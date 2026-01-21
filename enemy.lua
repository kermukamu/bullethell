local cprojectile = require("projectile")
Projectile = cprojectile.Projectile
local cinstructions = require("instructions")
Instructions = cinstructions.Instructions
local csquareparticle = require("squareparticle")
SquareParticle = csquareparticle.SquareParticle

-- Enemy "class"
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, r, sx, sy, w, h, instructions, level)
	local self = setmetatable({}, Enemy)
	self.level = level

	-- Position and dimensions
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.originalSX = sx
	self.originalSY = sy
	self.sx = sx or 1
	self.sy = sy or 1
	self.w = w or 128
	self.h = h or 128

	-- Movement
	self.xSpeed = 0
	self.ySpeed = 0
	self.drag = 0
	self.xSpeedMult = 1
	self.ySpeedMult = 1
	self.maxMoveSpeed = 500

	-- Health and taking damage
	self.health = 100
	self.hurtCooldown = 0
	self.maxHurtCooldown = 0.2
	self.beingAnnihilated = false
	self.annihilationRate = 2

	-- Other
	self.shotDamage = 25
	self.shotSize = 32
	self.timer = 0
	self.opaque = 1
	self.instructions = Instructions.new(instructions, self)
	return self
end

function Enemy:update(dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)
    self.timer = self.timer + dt
    self.sx = self.originalSX + math.sin(self.timer) / 4 + math.log(self.hurtCooldown+1)
    self.sy = self.originalSY + math.sin(self.timer) / 4 + math.log(self.hurtCooldown+1)

    if self.instructions then
    	self.instructions:callInstructions(dt)
    end
    self:posUpdate(dt)

    if self.beingAnnihilated then
    	self.opaque = self.opaque - self.annihilationRate * dt
    	if self.opaque <= 0 then self.health = 0 end
    end

    -- Update hurt visual effect
    if self.hurtCooldown > 0 then self.opaque = 1-(self.hurtCooldown/self.maxHurtCooldown) end

    -- Run collision checks between player projectiles and self
    if self.hurtCooldown <= 0 then
    	for _, p in ipairs(self.level.playerProjectileTable) do
			if p.affectEnemy and p:collidesWith(self) then
				p.health = p.health - 1
				self.health = self.health - p.damage
				self.hurtCooldown = self.maxHurtCooldown
				self.level.score = self.level.score + self.level.enemyHitScore
				self:hurtEffect() self:hurtEffect() self:hurtEffect()
			end
    	end
    end
end

function Enemy:draw()
	local r, g, b = 1, 0, math.sin(self.timer / 2)
    love.graphics.setColor(r, g, b, self.opaque)
    love.graphics.rectangle( "fill", self.x, self.y, self.w * self.sx, self.h * self.sx)
    love.graphics.setColor(1,1,1,1)
end

function Enemy:shoot(angleDeg, speed, scale)
	if not self.level.enemyProjectileTable then return false end
	local x, y = self:getXCenter() - (self.shotSize * scale / 2), self.y + 10
	local orientation = 0
	local affectEnemy, affectPlayer = false, true
	local shot = Projectile.new(x, y, orientation, scale, scale, self.shotSize, self.shotSize, self.shotDamage, 
		affectEnemy, affectPlayer)
	shot.xSpeed = math.sin(math.rad(angleDeg)) * speed --+ self.xSpeedMult * self.xSpeed
	shot.ySpeed = math.cos(math.rad(angleDeg)) * speed --+ self.ySpeedMult * self.ySpeed

	-- Copy annihilation status to the shot
	if self.beingAnnihilated then
		shot.opaque = self.opaque
		shot.beingAnnihilated = true
	end

	table.insert(self.level.enemyProjectileTable, shot)
end

function Enemy:hurtEffect()
	-- Square particle effect
	local size, shrinkSpeed = math.random(5, 20), math.random(8, 12)
	local r, g, b, o = 1, 0, math.sin(self.timer / 2), self.opaque -- Current color of enemy
	local sqrX = self:getXCenter()
	local sqrY = self:getYCenter()
	local mode = "fill"
	local sPrt = SquareParticle.new(sqrX, sqrY, 
		size, shrinkSpeed, r, g, b, o, mode, self.level)
	sPrt.xSpeed = math.random(-50, 50)
	sPrt.ySpeed = math.random(-50, 50)
	sPrt:centerToPos()
	self.level:spawnEffect(sPrt)
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
	self.x = self.x + self.xSpeedMult * self.xSpeed * dt
	self.y = self.y + self.ySpeedMult * self.ySpeed * dt

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
	if self.health <= 0 then
		for i = 1, 20, 1 do	self:hurtEffect() end
		return true 
	end

	-- Off-scene
	local wScene = love.graphics.getWidth()
	local hScene = love.graphics.getHeight()
	if self.x < -500 or self.x > wScene + 500 or self.y < -500 or self.y > hScene + 500 then return true end
	return false
end

return { Enemy = Enemy}