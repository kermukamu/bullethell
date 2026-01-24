local cplayer = require("player")
Player = cplayer.Player
local cprojectile = require("projectile")
Projectile = cprojectile.Projectile
local cenemy = require("enemy")
Enemy = cenemy.Enemy
local cinstructions = require("instructions")
Instructions = cinstructions.Instructions
local ccool3d = require("cool3d")
Cool3d = ccool3d.Cool3d
local cpowerup = require("powerup")
PowerUp = cpowerup.PowerUp

-- Level "class"
local Level = {}
Level.__index = Level

function Level.new(debugmode, host)
	local self = setmetatable({}, Level)
	self.debugmode = debugmode
	self.host = host

	if debugmode then
		print("Initializing level")
		io.stdout:flush()
	end

	self.isOver = false -- Whether game is lost or not

	--Set up tables
	self.enemyTable = {}
	self.enemyProjectileTable = {}
	self.playerProjectileTable = {}
	self.powerUpTable = {}
	self.effectsTable = {}

	-- General timer
	self.timer = 0

	-- Enemy spawning time control
	self.originalSpawnInterval = 10
	self.enemySpawnInterval = self.originalSpawnInterval
	self.enemySpawnCount = 1 -- Actual spawned amount is twice due to mirroring
	self.spawnTimer = 0

	-- Power up
	self.powerUpInterval = 20
	self.powerUpTimer = self.powerUpInterval
	self.powerUpTextCenterX = love.graphics.getWidth()/2
	self.powerUpTextY = love.graphics.getHeight() - 100
	self.powerUpTextScale = 3
	self.powerUpCount = 0 -- non-picked up power ups
	self.powerUpSpawnXMin, self.powerUpSpawnXMax = 150, love.graphics.getWidth() - 150
	self.powerUpSpawnYMin, self.powerUpSpawnYMax = 750, love.graphics.getHeight() - 150
	self.powerUpCountMax = 5
	self.activePowerUp = nil

	-- Countdown for the appearing of ending text
	self.endingTextWait = 2

	-- Scoring table
	self.score = 0
	self.timeScore = 1
	self.projHitScore = 2
	self.enemyHitScore = 15

	-- Initialize player
	if self.debugmode then
		print("Setting up the player for level")
		io.stdout:flush()
	end
	local playerX = love.graphics.getWidth() / 2
	local playerY = love.graphics.getHeight() - 80
	local playerOrientation = 0
	local playerScale = 0.2
	local playerSize = 128
	self.player = Player.new(playerX, playerY, playerOrientation, playerScale, 
		playerScale, playerSize, playerSize, self)
	self.player:centerToPos()

	-- Read enemy instructions
	self.enemyInstructions = self:readFile('instructions/enemy0.str.txt')
	if self.enemyInstructions and self.debugmode then
		print("Enemy instructions successfully read!\n")
		io.stdout:flush()
	end

	-- Play music
	gSounds.music:setLooping(true)
	gSounds.music:setVolume(0.2)
	gSounds.music:play()

	return self
end

function Level:update(dt)
	self.timer = self.timer + dt

	-- Check whether game has ended
	if not self.isOver then 
		self.player:update(dt)
		self.score = self.score + self.timeScore * dt
	end

	-- Check if enemies need to be spawned
	if self.spawnTimer <= 0 then
		self:spawnEnemies()
	end
	self.spawnTimer = self.spawnTimer - dt

	-- Power up spawning
	if self.powerUpTimer <= 0 and self.powerUpCount < self.powerUpCountMax then
		self:spawnPowerUp()
		self.powerUpTimer = self.powerUpInterval
	end
	self.powerUpTimer = self.powerUpTimer - dt

	self:updateTables(dt)

    -- Run collision checks between player projectiles and enemy projectiles
    for _, pp in ipairs(self.playerProjectileTable) do
    	for _, ep in ipairs(self.enemyProjectileTable) do
    		if pp.affectEnemy and pp:collidesWith(ep) then
    			ep.health = 0
    			self.score = self.score + self.projHitScore
    		end
    	end
    end

	-- Check if player is alive
	if self.player:shouldDestroy() then self.isOver = true end

	-- Restart game text appearance timer
	if self.isOver then
		self.endingTextWait = math.max(0, self.endingTextWait - dt)
	end
end

function Level:draw()
	for _, ef in ipairs(self.effectsTable) do
		ef:draw()
    end

    for _, pUp in ipairs(self.powerUpTable) do
		pUp:draw()
		if pUp.hasBeenPicked then
			self:printXCenteredText("Power up: " .. pUp.name, 
				self.powerUpTextCenterX, self.powerUpTextY, self.powerUpTextScale)
		end
    end

	-- Draw things
	for _, p in ipairs(self.enemyProjectileTable) do
		p:draw()
    end
    for _, p in ipairs(self.playerProjectileTable) do
		p:draw()
    end
	for _, e in ipairs(self.enemyTable) do
		e:draw()
    end

    if (not self.isOver) then
		self.player:draw()

		if debugmode then
			love.graphics.print(("x=%.1f y=%.1f\nvx=%.1f vy=%.1f"):format(self.player.x, 
				self.player.y, self.player.xSpeed, self.player.ySpeed), 10, 10)
		end

		-- Draw score
		local scoreX = love.graphics.getWidth()/2
		local scoreY = 40
		local scoreScale = 3
		self:printXCenteredText(("Score: %.0f"):format(self.score), scoreX, scoreY, scoreScale)
	end

    -- Ending
    if self.isOver then
    	-- Draw game over text
    	local gameOverText = "GAME OVER!"
    	local gameOverTextCenterX = love.graphics.getWidth()/2
    	local gameOverTextY = love.graphics.getHeight()/2 - 100
    	local gameOverTextScale = 5
    	self:printXCenteredText(gameOverText, gameOverTextCenterX, gameOverTextY, gameOverTextScale)

    	-- Print final score
    	local finalScoreText = ("Score: %.0f"):format(self.score)
    	local finalScoreTextCenterX = love.graphics.getWidth()/2
    	local finalScoreTextY = love.graphics.getHeight()/2
    	local finalScoreTextScale = 4
		self:printXCenteredText(finalScoreText, finalScoreTextCenterX, finalScoreTextY, finalScoreTextScale)

		-- After a small moment, print instructions to return to menu
    	if self.endingTextWait <= 0 then
    		local returnMenuText = "Press ENTER to return to main menu"
    		local returnMenuTextCenterX = love.graphics.getWidth()/2
    		local returnMenuTextY = love.graphics.getHeight()/2 + 100
    		local returnMenuTextScale = 5
    		self:printXCenteredText(returnMenuText, returnMenuTextCenterX, returnMenuTextY, returnMenuTextScale)
    	end
	end
end

function Level:spawnEnemies()
	for i=1, self.enemySpawnCount, 1 do
		-- Spawn off screen
		local spawnX1 = -50
		local spawnX2 = love.graphics.getWidth() + 50

		-- Set random y value for spawn location
		local spawnY1 = math.random(-100, love.graphics.getHeight() / 2)
		local spawnY2 = math.random(-100, love.graphics.getHeight() / 2)

		-- Geometry
		local enemyOrientation = 0
		local enemyScale = 0.8
		local enemySize = 64

		-- Inititialize enemies
		local enemyLeft = Enemy.new(spawnX1, spawnY1, enemyOrientation, 
			enemyScale, enemyScale, enemySize, enemySize, self.enemyInstructions, self)
		local enemyRight = Enemy.new(spawnX2, spawnY2, enemyOrientation, 
			enemyScale, enemyScale, enemySize, enemySize, self.enemyInstructions, self)

		-- Treat current position as supposed center and align accordingly
		enemyLeft:centerToPos()
		enemyRight:centerToPos()

		-- Mirror directions in instructions
		enemyLeft.instructions.mag = 1
		enemyRight.instructions.mag = -1

		-- Set xSpeed multiplier as a random constant between 0.8 and 1.5
		local xSpeedMultMin = 0.8
		local xSpeedMultMax = 1.5
		enemyLeft.xSpeedMult = xSpeedMultMin + math.random() * (xSpeedMultMax - xSpeedMultMin)
		enemyRight.xSpeedMult = xSpeedMultMin + math.random() * (xSpeedMultMax - xSpeedMultMin)

		-- Set ySpeed multiplier as a random constant between -1 and 1
		local ySpeedMultMin = -1
		local ySpeedMultMax = 1
		enemyLeft.ySpeedMult = ySpeedMultMin + math.random() * (ySpeedMultMax - ySpeedMultMin)
		enemyRight.ySpeedMult = ySpeedMultMin + math.random() * (ySpeedMultMax - ySpeedMultMin)

		table.insert(self.enemyTable, enemyLeft)
		table.insert(self.enemyTable, enemyRight)
	end

	-- Reduce interval after every spawning
	self.enemySpawnInterval = self.enemySpawnInterval - 1

	-- If interval is 5, increase spawn count instead, reset interval to original
	if self.enemySpawnInterval <= 5 then
		self.enemySpawnCount = self.enemySpawnCount + 1
		self.enemySpawnInterval = self.originalSpawnInterval
	end

	self.spawnTimer = self.enemySpawnInterval
end

function Level:updateTables(dt)
	-- Update enemy projectiles
	for i = #self.enemyProjectileTable, 1, -1 do
		local p = self.enemyProjectileTable[i]
		p:update(dt)
		if p:shouldDestroy() then
        	table.remove(self.enemyProjectileTable, i)
    	end
    end

    -- Update player projectiles
    for i = #self.playerProjectileTable, 1, -1 do
		local p = self.playerProjectileTable[i]
		p:update(dt)
		if p:shouldDestroy() then
        	table.remove(self.playerProjectileTable, i)
    	end
    end

	-- Update enemies
	for i =#self.enemyTable, 1, -1 do
		local e = self.enemyTable[i]
		e:update(dt)
		if e:shouldDestroy() then
			print("Deleting enemy")
			io.stdout:flush()
			table.remove(self.enemyTable, i)
		end
	end

	-- Update power ups
	for i =#self.powerUpTable, 1, -1 do
		local pUp = self.powerUpTable[i]
		pUp:update(dt)
		if pUp:shouldDestroy() then
			table.remove(self.powerUpTable, i)
			self.powerUpCount = self.powerUpCount - 1
		end
	end

	-- Update effects
	for i =#self.effectsTable, 1, -1 do
		local ef = self.effectsTable[i]
		ef:update(dt)
		if ef:shouldDestroy() then
			table.remove(self.effectsTable, i)
		end
	end
end

function Level:spawnPowerUp()
	-- Select power up type
	local powerUpType = ""
	local randomNum = math.random(1, 2)
	if randomNum == 1 then
		powerUpType = "Total annihilation"
	elseif randomNum == 2 then
		powerUpType = "Health"
	end

	local spawnX = math.random(self.powerUpSpawnXMin, self.powerUpSpawnXMax)
	local spawnY = math.random(self.powerUpSpawnYMin, self.powerUpSpawnYMax)
	local powerUpOrientation = 0
	local powerUpScale = 1
	local powerUpSize = 32
	table.insert(self.powerUpTable, PowerUp.new(spawnX, spawnY, powerUpOrientation, 
		powerUpScale, powerUpScale, powerUpSize, powerUpSize, powerUpType, self))
	self.powerUpCount = self.powerUpCount + 1
end

function Level:spawnEffect(effect)
	table.insert(self.effectsTable, effect)
end

function Level:readFile(filename)
	local tab = {}
	local contents, err = love.filesystem.read(filename)
	if not contents then error("Table not read\n") end
	for line in contents:gmatch("[^\r\n]+") do
		table.insert(tab, line)
	end
	return tab
end

function Level:mousepressed(mx, my, button)
	print("No action on mouse click")
	io.stdout:flush()
end

function Level:keypressed(key)
	if self.isOver then
  		if key == "return" then 
  			self.host:setupMainMenu()
  		end
  	else
  		if key == "e" and self.activePowerUp ~= nil then
  			self.activePowerUp:execute()
  			self.activePowerUp = nil
  		end
  	end
end

function Level:printXCenteredText(text, centerX, textY, scale)
	local textX = centerX - love.graphics.getFont():getWidth(text) * scale/2
	local orientation = 0
	love.graphics.print(text, textX, textY, orientation, scale, scale)
end

return { Level = Level}