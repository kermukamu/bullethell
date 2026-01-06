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

-- Level "class"
local Level = {}
Level.__index = Level

function Level.new(debugmode, host)
	local self = setmetatable({}, Level)
	self.debugmode = debugmode
	self.sT = host.sT
	self.host = host

	if debugmode then
		print("Initializing level")
		io.stdout:flush()
	end

	self.isOver = false
	self.timer = 0
	self.enemyTable = {}
	self.projectileTable = {}

	-- Load level sprites
	if self.debugmode then
		print("Initializing sprites for level")
		io.stdout:flush()
	end
	self.sT.eSpr = love.graphics.newImage('sprites/tile2.png')
	self.sT.eShotSpr = love.graphics.newImage('sprites/enemyShot.png')

	-- Create a cool 3D background
	self.bg = Cool3d.new(debugmode)
	self.bg:readFile("3d/diamond.txt")

	-- Initialize player
	if self.debugmode then
		print("Setting up the player for level")
		io.stdout:flush()
	end
	local px = love.graphics.getWidth() / 2
	local py = love.graphics.getHeight() - 80
	self.player = Player.new(px, py, 0, 0.5, 0.5, self.sT.pSpr:getWidth(), self.sT.pSpr:getHeight(), self)
	self.player:centerToPos()

	-- Add test enemies
	if self.debugmode then
		print("Setting up test enemies for level")
		io.stdout:flush()
	end
	self.enemyInstructions = self:readFile('instructions/enemy1.str.txt')
	if self.enemyInstructions and self.debugmode then
		print("Enemy instructions successfully read!\n")
		io.stdout:flush()
	end
	table.insert(self.enemyTable, Enemy.new(love.graphics.getWidth() / 2 - 100, 50, 0, 0.8, 0.8, self.sT.eSpr, self.sT.eSpr:getWidth(), self.sT.eSpr:getHeight(), self.enemyInstructions, self))
	table.insert(self.enemyTable, Enemy.new(love.graphics.getWidth() / 2 + 100, 50, 0, 0.8, 0.8, self.sT.eSpr, self.sT.eSpr:getWidth(), self.sT.eSpr:getHeight(), self.enemyInstructions, self))
	self.enemyTable[1]:centerToPos()
	self.enemyTable[2]:centerToPos()
	self.enemyTable[2].instructions.mag = -1
	return self
end

function Level:update(dt)
	self.timer = self.timer + 1 * dt
	if (not self.isOver) then self.player:update(dt) end
	if love.keyboard.isDown("space") then self.player:shoot() end

	self.bg.dt = dt -- Update to synchronize background animation

	-- Update projectiles
	for i = #self.projectileTable, 1, -1 do
		local p = self.projectileTable[i]
		p:update(dt)
		if p:shouldDestroy() then
        	table.remove(self.projectileTable, i)
    	end
    end

    -- Update enemies
	for i =#self.enemyTable, 1, -1 do
		local e = self.enemyTable[i]
		e:update(dt)
		e:shoot(false)
		if e:shouldDestroy() then
			print("Deleting enemy")
			io.stdout:flush()
			table.remove(self.enemyTable, i)
		end
	end

	-- Check if player is alivea 
	if self.player:shouldDestroy() then self.isOver = true end
end

function Level:draw()
	if (not self.isOver) then 
		self.player:draw()
		love.graphics.print(("x=%.1f y=%.1f\nvx=%.1f vy=%.1f"):format(self.player.x, self.player.y, self.player.xSpeed, self.player.ySpeed), 10, 10)
	end

	-- Draw background
	self.bg:draw()

	-- Draw projectiles
	for _, p in ipairs(self.projectileTable) do
		p:draw()
    end

    -- Draw enemies
	for _, e in ipairs(self.enemyTable) do
		e:draw()
    end

    -- Draw end text
    if self.isOver then love.graphics.print("GAME OVER!", love.graphics.getWidth()/2 -150, love.graphics.getHeight()/2, 0, 5, 5) end
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
	if key == "c" and love.keyboard.isDown("d") then self.player:dash(true) end
  	if key == "c" and love.keyboard.isDown("a") then self.player:dash(false) end
end

return { Level = Level}