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
	local controlsText = "WASD to move\nSHIFT for speed\nSPACE to shoot"
	local controlsTextCenterX = love.graphics.getWidth()/2
	local controlsTextY = love.graphics.getHeight()/2 - 300
	local controlsTextScale = 3
	self.stage:printXCenteredText(controlsText, controlsTextCenterX, controlsTextY, controlsTextScale)
	
	-- Initialize start button
	local startButtonText = "Start"
	local buttonExecuteFunction = function() self:setupLevel() end
	local startButtonWidth = 500
	local startButtonHeight = 250
	local startButtonCenterX = love.graphics.getWidth()/2
	local startButtonY = love.graphics.getHeight()/2
	local startButtonScale = 3
	table.insert(self.stage.buttonTable, Button.new(startButtonText, buttonExecuteFunction, 
		startButtonWidth, startButtonHeight, startButtonCenterX, startButtonY, startButtonScale))
end

function Scene:setupLevel()
	if self.debugmode then
		print("Loading a level")
		io.stdout:flush()
	end
	self.stage = Level.new(self.debugmode, self)
end

return { Scene = Scene}