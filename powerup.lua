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
	self.r = r or 0
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
	return self
end

function PowerUp:update(dt)
	self.r = self.r + dt

	if not self.hasBeenPicked and self:collidesWith(self.level.player) 
		and self.level.activePowerUp == nil then

		-- Health powerup gets used immediately
		if self.name == "Health" then 
			self.level.player.health = math.min(self.level.player.health + 25, 
				self.level.player.maxHealth)
			self.hasBeenUsed = true
			return
		end
		
		self.hasBeenPicked = true
		self.level.activePowerUp = self
		self.sx = 0.2
		self.sy = 0.2
	end
end

function PowerUp:draw()
	if not self.hasBeenPicked then
		local r, g, b = 1, 1, 1
    	love.graphics.setColor(r, g, b, self.opaque)
    	love.graphics.rectangle("line", self.x, self.y, self.w*self.sx, self.h*self.sy)
    	love.graphics.setColor(1,1,1,1) -- Set back to fully opaque white
    end
end

function PowerUp:execute()
	if self.name == "Total annihilation" then
		self:annihilateAll()

		-- Create explosion effect
		local radius, speed = 2000, 2500
		local r, g, b, o = 1, 1, 0, 1 -- yellow
		local explosion = Explosion.new(self.level.player.x, self.level.player.y, 
			radius, speed, r, g, b, o, self.level)
		self.level:spawnEffect(explosion)
	end
	self.hasBeenUsed = true
end

function PowerUp:annihilateAll()
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
	if self.hasBeenUsed then return true end
	return false
end

return { PowerUp = PowerUp}