local cplayer = require("player")
Player = cplayer.Player
local cprojectile = require("projectile")
Projectile = cprojectile.Projectile
local cenemy = require("enemy")
Enemy = cenemy.Enemy

function love.load()
	love.window.setTitle("BulletHell")
    love.window.setMode(1920, 1080)

    -- Load sprites
    love.graphics.setDefaultFilter("nearest", "nearest")
    background = love.graphics.newImage('sprites/background.png')
	playerSprite = love.graphics.newImage('sprites/chr.png')
	playerShotSprite = love.graphics.newImage('sprites/playerShot.png')
	enemySprite = love.graphics.newImage('sprites/tile2.png')
	enemyShotSprite = love.graphics.newImage('sprites/enemyShot.png')

	-- Initialize player
	local px = love.graphics.getWidth() / 2
	local py = love.graphics.getHeight() / 2
	player = Player.new(px, py, 0, 1, 1, playerSprite, playerSprite:getWidth(), playerSprite:getHeight())

	-- Initialize the projectile table
	projectiles = {}

	-- Initialize the enemy table
	enemies = {}

	stage = {}
	stage.over = false

	-- Add a test enemy
	local testEnemy1 = Enemy.new(love.graphics.getWidth() / 2 - 300, 200, 0, 1, 1, enemySprite, enemySprite:getWidth(), enemySprite:getHeight())
	local testEnemy2 = Enemy.new(love.graphics.getWidth() / 2 + 300, 200, 0, 1, 1, enemySprite, enemySprite:getWidth(), enemySprite:getHeight())
	table.insert(enemies, testEnemy1)
	table.insert(enemies, testEnemy2)
end

function love.update(dt)
	if (not stage.over) then player:update(dt, projectiles) end
	if love.keyboard.isDown("space") then player:shoot(projectiles, playerShotSprite) end

	-- Update projectiles
	for i = #projectiles, 1, -1 do
		local p = projectiles[i]
		p:update(dt)
		if p:shouldDestroy() then
			print("Deleting projectile")
			io.stdout:flush()
        	table.remove(projectiles, i)
    	end
    end

    -- Update enemies
	for i =#enemies, 1, -1 do
		local e = enemies[i]
		e:update(dt, projectiles)
		e:shoot(projectiles, enemyShotSprite)
		if e:shouldDestroy() then
			print("Deleting enemy")
			io.stdout:flush()
			table.remove(enemies, i)
		end
	end

	-- Check if player is alive
	if player:shouldDestroy() then stage.over = true end
end

function love.keypressed(key)
	if key == "c" and love.keyboard.isDown("d") then player:dash(true) end
  	if key == "c" and love.keyboard.isDown("a") then player:dash(false) end
end

function love.draw()
	love.graphics.draw(background, 0, 0)
	if (not stage.over) then 
		player:draw()
		love.graphics.print(("x=%.1f y=%.1f\nvx=%.1f vy=%.1f"):format(player.x, player.y, player.xSpeed, player.ySpeed), 10, 10)
	end

	-- Draw projectiles
	for _, p in ipairs(projectiles) do
		p:draw()
    end

    -- Draw enemies
	for _, e in ipairs(enemies) do
		e:draw()
    end

    -- Draw end text
    if stage.over then love.graphics.print("GAME OVER!", love.graphics.getWidth()/2 -150, love.graphics.getHeight()/2, 0, 5, 5) end
end