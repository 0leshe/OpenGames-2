local GUI = require('GUI')
local System = require('System')
local lc = System.getCurrentScriptLocalization()
local ApplicationPath = string.gsub(System.getCurrentScript(),'Main.lua','')
local fs = require('filesystem')
local UserData = System.getUserSettings()
local dataFiles = fs.list(ApplicationPath..'/InstallData/')

local Colors = {0x202020,0x202020, 0x909090}

local function getColor(num)
    if num == 2 then
            return Colors[1] + Colors[2]
    else
        return Colors[num]
    end
end

local wk,win,menu = System.addWindow(GUI.titledWindow(1,1,60,10,lc.installer,true))
win.backgroundPanel.colors.background = getColor(1)
win.titlePanel.colors.background = getColor(2)
win.titleLabel.colors.text = getColor(3)
win:addChild(GUI.panel(1,5,60,1,getColor(2)))
local niceLineContainter = win:addChild(GUI.container(1,5,60,1))
local line1 = niceLineContainter:addChild(GUI.panel(1,1,5,1,getColor(3)))
local timestamp = require('computer').uptime()
niceLineContainter.eventHandler = function()
    if timestamp+0.5 < require('computer').uptime() then
        timestamp = require('computer').uptime()
        line1.localX = line1.localX + 1
        if line1.localX == 65 then
            line1.localX = -5
        end
        wk:draw(true)
    end
end

local workspace = win:addChild(GUI.container(2,1,60,10))
workspace:addChild(GUI.text(2,3,getColor(3),lc.welcome))
workspace:addChild(GUI.button(38,7,20,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.continue)).onTouch = function()
    workspace:removeChildren()
    workspace:addChild(GUI.text(2,3,getColor(3),lc.choosePath))
    local input = workspace:addChild(GUI.input(2,7,25,3,getColor(2),getColor(3),0xFF0000,getColor(3),getColor(2),lc.path,lc.path))
    workspace:addChild(GUI.button(29,7,7,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.explore)).onTouch = function()
        local filesystemDialog = GUI.addFilesystemDialog(wk, false, 50, math.floor(wk.height * 0.8), lc.Open, lc.Cancel, lc.path, "/")
        filesystemDialog:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_DIRECTORY)
        filesystemDialog.onSubmit = function(path)
            input.text = path
        end
        filesystemDialog:show()
    end
    workspace:addChild(GUI.button(38,7,20,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.continue)).onTouch = function()
        if fs.exists(input.text) then
            fs.makeDirectory(input.text..'/OpenGames 2 Engine')
            for i = 1,#dataFiles do
                if not require("Compressor").unpack(ApplicationPath..'/InstallData/'..dataFiles[i],input.text.."/OpenGames 2 Engine/") then
                    GUI.alert("Failed to unpack "..dataFiles[i].." file.")
                end
            end
            UserData.OpenGames2EnignePath = fs.removeSlashes(input.text..'/OpenGames 2 Engine')
            System.saveUserSettings()
            workspace:removeChildren()
            workspace:addChild(GUI.text(2,3,getColor(3),lc.done))
            workspace:addChild(GUI.button(38,7,20,3,getColor(2),getColor(3),getColor(2),getColor(3),lc.exit)).onTouch = function()
                win:remove()
            end
        end
    end
end