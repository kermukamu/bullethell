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

	self.x = x or 0
	self.y = y or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.w = w or 128
	self.h = h or 128
	self.health = 100
	self.dashCooldown = 0
	self.shotCooldown = 0
	self.hurtCooldown = 0
	self.xSpeed = 0
	self.ySpeed = 0
	self.dashSpeed = 0
	self.drag = 1000
	self.maxMoveSpeed = 200
	self.maxDashSpeed = 50000
	self.dashDistance = 150
	self.maxShotCooldown = 0.1
	self.maxHurtCooldown = 1
	self.shotDamage = 30
	self.cShift = 0
	self.opaque = 1

	self.healthBarVisual = Cool3d.new(self.level.debugmode, 100, love.graphics.getHeight() - 100, 250)
	self.healthBarVisual:readFile("3d/diamond.txt")
	return self
end

function Player:update(dt)
    self.dashCooldown = math.max(0, self.dashCooldown - dt)
    self.shotCooldown = math.max(0, self.shotCooldown - dt)
    self.hurtCooldown = math.max(0, self.hurtCooldown - dt)
    self:movement()
    self:posUpdate(dt)

    -- Check if shooting key is pressed
    if love.keyboard.isDown("space") then self:shoot() end

    -- Update hurt visual effect
    if self.hurtCooldown > 0 then self.opaque = 1-(self.hurtCooldown/self.maxHurtCooldown) end

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

	self.healthBarVisual.dt = dt -- Update to synchronize health bar animation with time

    self._debugTimer = (self._debugTimer or 0) + dt
    if self._debugTimer >= 0.5 then
        self._debugTimer = 0
    end
end

function Player:draw()
    love.graphics.setColor(math.sin(self.cShift),1,0,self.opaque)
    love.graphics.rectangle( "fill", self.x, self.y, self.w*self.sx, self.h*self.sx)
    love.graphics.setColor(1,1,1,1)

    for i=1, self.health, 25 do
		self.healthBarVisual:draw()
		self.healthBarVisual.x2d = self.healthBarVisual.x2d + 100
	end

	self.healthBarVisual.x2d = 100
end

function Player:dash(direction)
	if (self.dashCooldown <= 0) then
		self.dashCooldown = 0.5
    	if direction then
      		self.dashSpeed = self.maxDashSpeed
      		print("Dashing right")
    	else
      		self.dashSpeed = -self.maxDashSpeed
      		print("Dashing left")
    	end
    	io.stdout:flush()
	end
end

function Player:shoot()
	if (self.shotCooldown <= 0) then
		self.shotCooldown = self.maxShotCooldown
		local scale = 0.6
		local size = 32
		local shot = Projectile.new(self:getXCenter() - (size * scale / 2), self.y - 10, 0, scale, scale, size, size, self.shotDamage, true, false)
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
    if love.keyboard.isDown("lshift") then moveSpeed = self.maxMoveSpeed * 2 end

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
	local newX = self.x + (self.xSpeed + self.dashSpeed) * dt
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