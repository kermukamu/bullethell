local clevel = require("level")
Level = clevel.Level
local cmenu = require("menu")
Menu = cmenu.Menu
local cbutton = require("button")
Button = cbutton.Button

-- Scene "class"
local Scene = {}
Scene.__index = Scene

function Scene.new(debugmode)
	local self = setmetatable({}, Scene)
	self.debugmode = debugmode

	self.stage = {}

	return self
end

function Scene:setupMainMenu()
	if self.debugmode then
		print("Initializing main menu")
		io.stdout:flush()
	end
	self.stage = Menu.new(self.debugmode, self)
	
	-- Draw controls text
	self.stage:printXCenteredText("WASD to move\nSHIFT for speed\nSPACE to shoot", love.graphics.getWidth()/2, love.graphics.getHeight()/2 - 300, 3)
	
	-- Initialize start button	
	table.insert(self.stage.buttonTable, Button.new("Start", function() self:setupLevel() end, 500, 250, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 3))
end

function Scene:setupLevel()
	if self.debugmode then
		print("Loading a level")
		io.stdout:flush()
	end
	self.stage = Level.new(self.debugmode, self)
end

return { Scene = Scene}