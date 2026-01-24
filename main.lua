local cscene = require("scene")
Scene = cscene.Scene

function love.load()
    local debugmode = true

    -- Load assets to global variables
    gSounds = {}
    gSounds.playerShoot1 = love.audio.newSource("sounds/shoot6.mp3", "static")
    gSounds.playerShoot2 = love.audio.newSource("sounds/shoot7.mp3", "static")
    gSounds.enemyHit = {}
    gSounds.music = love.audio.newSource("sounds/shepherd.mp3", "stream")
    for i=1,3,1 do
    	table.insert(gSounds.enemyHit, love.audio.newSource("sounds/shoot".. tostring(i) .. ".mp3", "static"))
    end

	-- Set up window
	local screenWidth = 1920
	local screenHeight = 1080
	love.window.setTitle("BulletHell")
    love.window.setMode(screenWidth, screenHeight)
    love.graphics.setBackgroundColor(0, 0, 0, 0) -- Black
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Start scene
	scene = Scene.new(debugmode)
	scene:setupMainMenu()
end

function love.update(dt)
	scene.stage:update(dt)
end

function love.keypressed(key)
	scene.stage:keypressed(key)
end

function love.mousepressed(mx, my, button)
	scene.stage:mousepressed(mx, my, button)
end

function love.draw()
	scene.stage:draw()
end