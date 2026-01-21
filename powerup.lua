local cexplosion = require("explosion")
Explosion = cexplosion.Explosion

-- power up "class"
local PowerUp = {}
PowerUp.__index = PowerUp

function PowerUp.new(x, y, r, sx, sy, w, h, name, level)
	local self = setmetatable({}, PowerUp)
	self.level = level

	-- Position and dimensions
	self.x = x or 0
	self.y = y or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.w = w or 128
	self.h = h or 128

	-- Visuals
	self.opaque = 1

	-- Other
	self.hasBeenPicked = false
	self.hasBeenUsed = false
	self.name = name
	self.timer = 0
	return self
end

function PowerUp:update(dt)
	self.timer = self.timer + dt

	if not self.hasBeenPicked then 
		self.opaque = math.sin(self.timer * (self.timer * self.timer / 5)) + 0.5 - (self.timer / 10)

		-- Check collision with player
		if self.level.activePowerUp == nil and self:collidesWith(self.level.player) then
			for i=1, 20, 1 do self:pickupEffect() end

			-- Health powerup gets used immediately unlike others
			if self.name == "Health" then 
				self.level.player.health = math.min(self.level.player.health + 25, 
					self.level.player.maxHealth)
				self.hasBeenUsed = true
				return
			end

			self.hasBeenPicked = true
			self.level.activePowerUp = self
		end
	end
end

function PowerUp:draw()
	if not self.hasBeenPicked then
		local r, g, b, o = 1, 1, 1, self.opaque -- White
    	love.graphics.setColor(r, g, b, o)
    	love.graphics.rectangle("fill", self.x, self.y, self.w*self.sx, self.h*self.sy)
    	love.graphics.setColor(1,1,1,1) -- Set back to fully opaque white
    end
end

function PowerUp:execute()
	if self.name == "Total annihilation" then
		self:annihilateAll()
	end
	self.hasBeenUsed = true
end


function PowerUp:explosionEffect()
	local radius, speed = 4000, 2500
	local r, g, b, o = 1, 1, 1, 1 -- White
	local mode = "line"
	local explosion = Explosion.new(self.level.player.x, self.level.player.y, 
		radius, speed, r, g, b, o, mode, self.level)
	self.level:spawnEffect(explosion)
end

function PowerUp:pickupEffect()
	-- Square particle effect
	local size, shrinkSpeed = math.random(5, 20), math.random(25, 50)
	local r, g, b, o = 1, 1, 1, 1 -- White
	local sqrX = self:getXCenter()
	local sqrY = self:getYCenter()
	local mode = "line"
	local sPrt = SquareParticle.new(sqrX, sqrY, 
		size, shrinkSpeed, r, g, b, o, mode, self.level)
	sPrt.xSpeed = math.random(-100, 100)
	sPrt.ySpeed = math.random(-100, 100)
	sPrt:centerToPos()
	self.level:spawnEffect(sPrt)
end

function PowerUp:disappearEffect()
	-- Square particle effect
	local size, shrinkSpeed = math.random(5, 20), math.random(25, 50)
	local r, g, b, o = 1, 1, 1, (math.random(0, 100) / 100) -- White with random opaque
	local sqrX = self:getXCenter()
	local sqrY = self:getYCenter()
	local mode = "fill"
	local sPrt = SquareParticle.new(sqrX, sqrY, 
		size, shrinkSpeed, r, g, b, o, mode, self.level)
	sPrt.xSpeed = math.random(-500, 500)
	sPrt.ySpeed = math.random(-500, 500)
	sPrt:centerToPos()
	self.level:spawnEffect(sPrt)
end

function PowerUp:annihilateAll()
	self:explosionEffect()

    for _, ep in ipairs(self.level.enemyProjectileTable) do
    	ep.beingAnnihilated = true
	end

	for _, e in ipairs(self.level.enemyTable) do
    	e.beingAnnihilated = true
	end
end

function PowerUp:collidesWith(object)
	return self.x < object.x + object:scaledW() and
		object.x < self.x + self:scaledW() and
		self.y < object.y + object:scaledH() and
		object.y < self.y + self:scaledH()
end

function PowerUp:getXCenter()
	local retX = self.x + (self:scaledW() / 2)
	return retX
end

function PowerUp:getYCenter()
	local retY = self.y + (self:scaledH() / 2)
	return retY
end

function PowerUp:scaledW()
	return self.w * self.sx
end

function PowerUp:scaledH()
	return self.h * self.sy
end

function PowerUp:centerToPos()
	self.x = self.x - (self:scaledW() / 2)
	self.y = self.y - (self:scaledH() / 2)
end

function PowerUp:shouldDestroy()
	local hasExpired = (not self.hasBeenPicked) and self.timer >= 15 
	if self.hasBeenUsed then return true end
	if hasExpired then
		for i=1, 50, 1 do self:disappearEffect() end
		return true
	end
	return false
end

return { PowerUp = PowerUp}