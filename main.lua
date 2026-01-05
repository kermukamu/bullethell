local cscene = require("scene")
Scene = cscene.Scene

function love.load()
	love.window.setTitle("BulletHell")
    love.window.setMode(1920, 1080)
    love.graphics.setBackgroundColor(0, 0, 0, 0)
    love.graphics.setDefaultFilter("nearest", "nearest")
    local debugmode = true

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
