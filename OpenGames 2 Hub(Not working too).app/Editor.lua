local args = {...}
print(pcall(function()
local fs = require('Filesystem')
local GUI = require('GUI')
local System = require('System')
local OE = loadfile("/OpenGames 2/Main.lua")(true)
local lc = System.getCurrentScriptLocalization()
local editorPath = string.gsub(System.getCurrentScript(),'Main.lua','')
local UserData = System.getUserSettings()
local Colors = {light={0xEEEEEE, 0x202020, 0x808080}, dark={0x202020,0x202020, 0x909090}}
local CurrentTheme
if not UserData.OpenGames.Editor then
    UserData.OpenGames.Editor = {}
    System.saveUserSettings()
end
if UserData.OpenGames.Settings.CurrentTheme then
    CurrentTheme = 'dark'
else
    CurrentTheme = 'light'
end
local function getColor(num)
    if num == 2 then
        if CurrentTheme == 'light' then
            return  Colors[CurrentTheme][1] - Colors[CurrentTheme][2]
        else
            return Colors[CurrentTheme][1] + Colors[CurrentTheme][2]
        end
    else
        return Colors[CurrentTheme][num]
    end
end
lc = fs.readTable(fs.removeSlashes(editorPath..'/Localizations/'..UserData.OpenGames.Settings.preferdLanguage..'.lang')) or lc
OE.Project = fs.readTable(fs.removeSlashes(args[1]..'/.Game.dat'))
local wk, win, menu = table.unpack(args[2])
local contextWindowMenus = menu:addContextMenuItem(lc.createWindows)
win.onResize = function(newWidth, newHeight)
  win.backgroundPanel.width, win.backgroundPanel.height = newWidth, newHeight
  win.titlePanel.width = newWidth
  win.titleLabel.width = newWidth
end

win.backgroundPanel.colors.background = getColor(1)
win.titlePanel.colors.background = getColor(2)
win.titleLabel.colors.text = getColor(3)
contextWindowMenus:addItem(lc.Inspector).onTouch = function()
    local tmpwin = win:addChild(GUI.titledWindow(1,1,UserData.OpenGames.Editor.InsectorWidth or 30,UserData.OpenGames.Editor.InsectorHeight or 50,lc.Inpector,true))
    tmpwin.actionButtons.maximize:remove()
    tmpwin.actionButtons.minimize:remove()
    tmpwin.backgroundPanel.colors.background = getColor(1)
    tmpwin.titlePanel.colors.background = getColor(2)
    tmpwin.titleLabel.colors.text = getColor(3)
    tmpwin:addChild(GUI.button(tmpwin.width-1,tmpwin.height-1,1,1,getColor(2),0,getColor(3),0,' ')).onTouch = function()
        local tmpwin2 = tmpwin:addChild(GUI.titledWindow(1,1,40,20,lc.changeWindowSize,true))
        tmpwin2.backgroundPanel.colors.background = getColor(1)
        tmpwin2.titlePanel.colors.background = getColor(2)
        tmpwin2.titleLabel.colors.text = getColor(3)
        tmpwin2:addChild(GUI.input(2,3,20,3,getColor(2),getColor(3),getColor(3),getColor(2),tostring(tmpwin.width),lc.Width)).onInputFinished = function(_,self)
            if self.text ~= '' then
                if pcall(function() local tmp = tonumber(self.text) end) then
                    UserData.OpenGames.Editor.InsectorWidth = tonumber(self.text)
                    System.saveUserSettings()
                end
            end
        end
        tmpwin2:addChild(GUI.input(2,8,20,3,getColor(2),getColor(3),getColor(3),getColor(2),tostring(tmpwin.height),lc.Height)).onInputFinished = function(_,self)
            if self.text ~= '' then
                if pcall(function() local tmp = tonumber(self.text) end) then
                    UserData.OpenGames.Editor.InsectorHeight = tonumber(self.text)
                    System.saveUserSettings()
                end
            end
        end
    end
end
end))