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

	-- Initialize start button
	local startButtonText = "Start"
	local buttonExecuteFunction = function() self:setupLevel() end
	local startButtonWidth = 500
	local startButtonHeight = 250
	local startButtonCenterX = love.graphics.getWidth()/2
	local startButtonY = love.graphics.getHeight()/2 + 100
	local startButtonScale = 3
	table.insert(self.stage.buttonTable, Button.new(startButtonText, buttonExecuteFunction, 
		startButtonWidth, startButtonHeight, startButtonCenterX, startButtonY, startButtonScale))

	-- Controls text
	local controlsText = {}
	controlsText.text = "   WASD to move\n   SPACE to shoot\n   SHIFT for speed\nE to use a power up"
	controlsText.centerX = love.graphics.getWidth()/2
	controlsText.y = love.graphics.getHeight()/2 - 250
	controlsText.scale = 3
	table.insert(self.stage.centeredTextTable, controlsText)	
end

function Scene:setupLevel()
	if self.debugmode then
		print("Loading a level")
		io.stdout:flush()
	end
	self.stage = Level.new(self.debugmode, self)
end

return { Scene = Scene}