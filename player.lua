local cprojectile = require("projectile")
Projectile = cprojectile.Projectile

-- Player "class"
local Player = {}
Player.__index = Player

function Player.new(x, y, r, sx, sy, sprW, sprH, level)
	local self = setmetatable({}, Player)
	self.level = level

	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.sprite = level.sT.pSpr
	self.w = sprW or 128
	self.h = sprH or 128
	self.health = 100
	self.dashCooldown = 0
	self.shotCooldown = 0
	self.hurtCooldown = 0
	self.xSpeed = 0
	self.ySpeed = 0
	self.dashSpeed = 0
	self.drag = 1000
	self.maxMoveSpeed = 500
	self.maxDashSpeed = 4000
	self.dashDistance = 150
	self.maxShotCooldown = 0.1
	self.maxHurtCooldown = 1
	self.shotDamage = 30

	return self
end

function Player:update(dt)
    self.dashCooldown = math.max(0, self.dashCooldown - dt)
    self.shotCooldown = math.max(0, self.shotCooldown - dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)
    self:movement()
    self:posUpdate(dt)

    -- Run collision checks between projectiles and player
    if self.hurtCooldown <= 0 then
    	for _, p in ipairs(self.level.projectileTable) do
			if p.affectPlayer and p:collidesWith(self) then
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

function Player:draw()
	if self.hurtCooldown > 0 then love.graphics.setColor(1,1,1,1-(self.hurtCooldown/self.maxHurtCooldown)) end
    love.graphics.draw(self.sprite, self.x, self.y, self.r, self.sx, self.sy)
    love.graphics.setColor(1,1,1,1)
end

function Player:dash(direction)
	if (self.dashCooldown <= 0) then
		self.dashCooldown = 0.5
    	if direction then
      		--self.dashSpeed = self.maxDashSpeed
      		self.x = self.x + self.dashDistance
      		print("Dashing right")
    	else
      		--self.dashSpeed = -self.maxDashSpeed
      		self.x = self.x - self.dashDistance
      		print("Dashing left")
    	end
    	io.stdout:flush()
	end
end

function Player:shoot()
	if (self.shotCooldown <= 0) then
		self.shotCooldown = self.maxShotCooldown
		local sprite = self.level.sT.pShotSpr
		local spriteW = sprite:getWidth()
		local spriteH = sprite:getHeight()
		local scale = 0.6
		local shot = Projectile.new(self:getXCenter() - (spriteW * scale / 2), self.y - 10, 0, scale, scale, self.level.sT.pShotSpr, spriteW, spriteH, self.shotDamage, true, false)
		shot.ySpeed = -6000
		table.insert(self.level.projectileTable, shot)
	end
end

function Player:movement()
	local hor = 0 
	local vert = 0

    -- Handle keyboard input
    if love.keyboard.isDown("d") then hor = 1 end
    if love.keyboard.isDown("a") then hor = -1 end
    if love.keyboard.isDown("s") then vert = 1 end
    if love.keyboard.isDown("w") then vert = -1 end

    -- Movement
    if hor ~= 0 and vert ~= 0 then -- Handle diagonal movement
    	self.xSpeed = hor * 0.707 * self.maxMoveSpeed
    	self.ySpeed = vert * 0.707 * self.maxMoveSpeed
    elseif hor ~= 0 then
    	self.xSpeed = hor * self.maxMoveSpeed
    elseif vert ~= 0 then
    	self.ySpeed = vert * self.maxMoveSpeed
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

function Player:printStatus()
	print("---- PLAYER STATUS ----")
	print("Position:", self.x, self.y)
	print("Rotation:", self.r)
	print("Scale:", self.sx, self.sy)
	print("Size:", self.w, self.h)
	print("Health:", self.health)
	print("X Speed:", self.xSpeed)
	print("Y Speed:", self.ySpeed)
	print("Dash Cooldown:", self.dashCooldown)

	print("------------------------")
	io.stdout:flush()
end

function Player:posUpdate(dt)
	-- Update player position
	self.x = self.x + (self.xSpeed + self.dashSpeed) * dt
	self.y = self.y + self.ySpeed * dt

	-- Slow down player movement
	local damping = math.exp(-self.drag * dt)
    self.xSpeed = self.xSpeed * damping
    self.ySpeed = self.ySpeed * damping
    self.dashSpeed = self.dashSpeed * damping

    -- Stop tiny drift
    if math.abs(self.xSpeed) < 0.01 then self.xSpeed = 0 end
    if math.abs(self.ySpeed) < 0.01 then self.ySpeed = 0 end
    if math.abs(self.dashSpeed) < 0.01 then self.dashSpeed = 0 end
end

function Player:shouldDestroy()
	-- 0 HP
	if self.health <= 0 then return true end
	return false
end

return { Player = Player}