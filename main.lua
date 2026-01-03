local clevel = require("level")
Level = clevel.Level

function love.load()
	love.window.setTitle("BulletHell")
    love.window.setMode(1920, 1080)
    love.graphics.setDefaultFilter("nearest", "nearest")
    local debugmode = true

    -- Load sprites to a sprite table
    if debugmode then
		print("Loading sprites")
		io.stdout:flush()
	end

    local sT = {}
    sT.bg = love.graphics.newImage('sprites/background.png')
	sT.pSpr = love.graphics.newImage('sprites/chr.png')
	sT.pShotSpr = love.graphics.newImage('sprites/playerShot.png')

	-- Open a level
	if debugmode then
		print("Loading a level")
		io.stdout:flush()
	end
	level = Level.new(sT, debugmode)

end

function love.update(dt)
	level:update(dt)
end

function love.keypressed(key)
	if key == "c" and love.keyboard.isDown("d") then level.player:dash(true) end
  	if key == "c" and love.keyboard.isDown("a") then level.player:dash(false) end
end

function love.draw()
	level:draw()
end
