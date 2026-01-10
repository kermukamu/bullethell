local cprojectile = require("projectile")
Projectile = cprojectile.Projectile
local ccool3d = require("cool3d")
Cool3d = ccool3d.Cool3d

-- Player "class"
local Player = {}
Player.__index = Player

function Player.new(x, y, r, sx, sy, w, h, level)
	local self = setmetatable({}, Player)
	self.level = level

	-- Position and geometry
	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.w = w or 128
	self.h = h or 128

	-- Movement
	self.xSpeed = 0
	self.ySpeed = 0
	self.drag = 1000
	self.maxMoveSpeed = 200
	self.quickMoveMult = 2

	-- Health and taking damage
	self.health = 100
	self.maxHurtCooldown = 1
	self.hurtCooldown = 0

	-- Shooting
	self.maxShotCooldown = 0.1
	self.shotCooldown = 0
	self.shotDamage = 30

	-- Visuals
	self.cShift = 0
	self.opaque = 1

	-- Setup 3D healthbar visuals
	local healthVisualX2D = 100 -- X of projection, in other words, x if z = 0 
	local healthVisualY2D = love.graphics.getHeight() - 100 -- Same for Y
	local healthVisualScale = 250
	self.healthBarVisual = Cool3d.new(self.level.debugmode, healthVisualX2D, healthVisualY2D, healthVisualScale)
	self.healthBarVisual:readFile("3d/diamond.txt")
	return self
end

function Player:update(dt)
	-- Update cooldowns
    self.shotCooldown = math.max(0, self.shotCooldown - dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)

    -- Check movement and update position
    self:movement()
    self:posUpdate(dt)

    -- Check if shooting key is pressed
    if love.keyboard.isDown("space") then self:shoot() end

    -- Run collision checks between enemy projectiles and self
    if self.hurtCooldown <= 0 then
    	for _, p in ipairs(self.level.enemyProjectileTable) do
			if p.affectPlayer and p:collidesWith(self) then
				p.health = p.health - 1
				self.health = self.health - p.damage
				self.hurtCooldown = self.maxHurtCooldown
				break
			end
    	end
    end

    -- Update hurt visual effect
    if self.hurtCooldown > 0 then self.opaque = 1-(self.hurtCooldown/self.maxHurtCooldown) end

 	-- Update dt in health bar visuals for synchronization
	self.healthBarVisual.dt = dt
end

function Player:draw()
	-- Player coloring
	local r = math.sin(self.cShift)
	local g = 1
	local b = 0
    love.graphics.setColor(r,g,b,self.opaque)
    love.graphics.rectangle( "fill", self.x, self.y, self.w*self.sx, self.h*self.sx)
    love.graphics.setColor(1,1,1,1) -- Set back to fully opaque white

    -- Draw health bar
    for i=1, self.health, 25 do
		self.healthBarVisual:draw()
		self.healthBarVisual.x2d = self.healthBarVisual.x2d + 100
	end

	self.healthBarVisual.x2d = 100
end

function Player:shoot()
	if (self.shotCooldown <= 0) then
		self.shotCooldown = self.maxShotCooldown
		local size = 32
		local scale = 0.6
		local x = self:getXCenter() - (size * scale / 2)
		local y = self.y - 10
		local orientation = 0
		local damage = self.shotDamage
		local affectEnemy = true
		local affectPlayer = false
		local shot = Projectile.new(x, y, orientation, scale, scale, size, size,
				damage, affectEnemy, affectPlayer)
		shot.ySpeed = -6000
		table.insert(self.level.playerProjectileTable, shot)
	end
end

function Player:movement()
	local hor = 0 
	local vert = 0
	local moveSpeed = self.maxMoveSpeed

    -- Handle keyboard input
    if love.keyboard.isDown("d") then hor = 1 end
    if love.keyboard.isDown("a") then hor = -1 end
    if love.keyboard.isDown("s") then vert = 1 end
    if love.keyboard.isDown("w") then vert = -1 end
    if love.keyboard.isDown("lshift") then moveSpeed = self.maxMoveSpeed * self.quickMoveMult end

    -- Movement
    if hor ~= 0 and vert ~= 0 then -- Handle diagonal movement
    	self.xSpeed = hor * 0.707 * moveSpeed
    	self.ySpeed = vert * 0.707 * moveSpeed
    elseif hor ~= 0 then
    	self.xSpeed = hor * moveSpeed
    elseif vert ~= 0 then
    	self.ySpeed = vert * moveSpeed
    end
end

function Player:getXCenter()
	local retX = self.x + (self:scaledW() / 2)
	return retX
end

function Player:getYCenter()
	local retY = self.y + (self:scaledH() / 2)
	return retY
end

function Player:scaledW()
	return self.w * self.sx
end

function Player:scaledH()
	return self.h * self.sy
end

function Player:centerToPos()
	self.x = self.x - (self:scaledW() / 2)
	self.y = self.y - (self:scaledH() / 2)
end

function Player:posUpdate(dt)
	-- Update player position
	local newX = self.x + self.xSpeed * dt
	local newY = self.y + self.ySpeed * dt
	newX = math.max(0, newX)
	newY = math.max(0, newY)
	newX = math.min(love.graphics.getWidth() - self:scaledW(), newX)
	newY = math.min(love.graphics.getHeight() - self:scaledH(), newY)

	self.x = newX
	self.y = newY

	-- Slow down player movement
	local damping = math.exp(-self.drag * dt)
    self.xSpeed = self.xSpeed * damping
    self.ySpeed = self.ySpeed * damping

    -- Stop tiny drift
    if math.abs(self.xSpeed) < 0.01 then self.xSpeed = 0 end
    if math.abs(self.ySpeed) < 0.01 then self.ySpeed = 0 end
end

function Player:shouldDestroy()
	-- 0 HP
	if self.health <= 0 then return true end
	return false
end

return { Player = Player}