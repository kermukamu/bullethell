local cscene = require("scene")
Scene = cscene.Scene

function love.load()
    local debugmode = true

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
