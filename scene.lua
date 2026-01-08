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

	 -- Load sprites to a sprite table
    if debugmode then
		print("Loading sprites")
		io.stdout:flush()
	end

    self.sT = {}
	self.sT.pSpr = love.graphics.newImage('sprites/chr.png')
	self.sT.pShotSpr = love.graphics.newImage('sprites/playerShot.png')

	return self
end

function Scene:setupMainMenu()
	if self.debugmode then
		print("Initializing main menu")
		io.stdout:flush()
	end
	self.stage = Menu.new(self.debugmode, self)
	table.insert(self.stage.buttonTable, Button.new("Start", function() self:setupLevel() end, 500, 250, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 3))
end

function Scene:printXCenteredText(text, x, y, scale)
	local tX = x - love.graphics.getFont():getWidth(text)*scale/2
	love.graphics.print(text, tX, y, 0, scale, scale)
end

function Scene:setupLevel()
	if self.debugmode then
		print("Loading a level")
		io.stdout:flush()
	end
	self.stage = Level.new(self.debugmode, self)
end

return { Scene = Scene}