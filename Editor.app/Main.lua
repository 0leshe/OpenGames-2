local GUI = require('GUI')
local Paths = require('Paths')
local Image = require('Image')
local fs = require('FileSystem')
local System = require('System')
local lc = System.getCurrentScriptLocalization()
local OE = loadfile("/OpenGames 2/Main.lua")()

local _,win,menu = System.addWindow(GUI.titledWindow(1,1,160,50,lc.Label))

local file = menu:addContextMenu(lc.File)
file:addItem(lc.Open).onTouch = function()
    print('Working on it...')
end
file:addItem(lc.Save).onTouch = function()
    print('Working on it...')
end
file:addItem(lc.Export).onTouch = function()
    print('Working on it...')
end
file:addSeparator()
file:addItem(lc.New).onTouch = function()
    OE = loadfile("/OpenGames 2/Main.lua")()
end
local windows = menu:addContextMenu(lc.Windows)
local windowsOpen = windows:addContextMenu(lc.Open)
windowsOpen:addItem(lc.GameView)
windowsOpen:addItem(lc.Inspector)
windowsOpen:addTtem(lc.ProjectFiles)
windowsOpen:addItem(lc.SceneObjects)