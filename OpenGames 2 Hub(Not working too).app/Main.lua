local GUI = require('GUI')
local Paths = require('Paths')
local Image = require('Image')
local fs = require('FileSystem')
local System = require('System')
local uni = require('Unicode')
local lc = System.getCurrentScriptLocalization()
local hubPath = string.gsub(System.getCurrentScript(),'Main.lua','')
local UserData = System.getUserSettings()
local ChoosedProject = 1
local Colors = {light={0xEEEEEE, 0x202020, 0x808080}, dark={0x202020,0x202020, 0x909090}} -- bg,bg2,fg

if not UserData.OpenGames then
    UserData.OpenGames = {}
    System.saveUserSettings()
end
if not UserData.OpenGames.Projects then
    UserData.OpenGames.Projects = {}
    System.saveUserSettings()
end
if not UserData.OpenGames.Settings then
    UserData.OpenGames.Settings = {preferdLanguage = '',CurrentTheme = true}
    System.saveUserSettings()
end
local CurrentTheme
if UserData.OpenGames.Settings.CurrentTheme then
    CurrentTheme = 'dark'
else
    CurrentTheme = 'light'
end
lc = fs.readTable(hubPath..'/Localizations/'..UserData.OpenGames.Settings.preferdLanguage..'.lang') or lc

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

local wk,win,menu = System.addWindow(GUI.titledWindow(1,1,100,40,lc.LabelHub,true))
local winMask = win:addChild(GUI.container(1,1,100,40))
win.onResize = function(newWidth, newHeight)
  win.backgroundPanel.width, win.backgroundPanel.height = newWidth, newHeight
  win.titlePanel.width = newWidth
  win.titleLabel.width = newWidth
  if winMask then
     winMask.width = newWidth
    winMask.height = newHeight
  end
end

win.backgroundPanel.colors.background = getColor(1)
win.titlePanel.colors.background = getColor(2)
win.titleLabel.colors.text = getColor(3)

local function readProject(path)
    return fs.readTable(fs.removeSlashes(path..'/.Game.dat'))
end

local infoPanel
local function reloadInfo()
    if infoPanel then
        infoPanel:remove()
    end
    infoPanel = winMask:addChild(GUI.container(55,7,44,29))
    local proj = readProject(UserData.OpenGames.Projects[ChoosedProject])
    infoPanel:addChild(GUI.panel(1,1,44,29,getColor(2)))
    infoPanel:addChild(GUI.text(2,2,getColor(3),lc.infoAbtProject))
    infoPanel:addChild(GUI.text(2,3,getColor(3),lc.Name .. ': '..proj.Name))
    infoPanel:addChild(GUI.text(2,4,getColor(3),lc.Size .. ': '..fs.size(UserData.OpenGames.Projects[ChoosedProject])))
    infoPanel:addChild(GUI.text(2,5,getColor(3),lc.lastModified .. ': '..os.date("%Y.%m.%d %H:%M",fs.lastModified(fs.removeSlashes(UserData.OpenGames.Projects[ChoosedProject])..'/.Game.dat'))))
    local scenesCount = 0
    local cnt = 0
    local storageCount = 0
    local function startStorage(path)
        for i,v in pairs(path) do
            if type(v) == 'table' and not i:match("[^%/]+(%.[^%/]+)%/?$") then
                startStorage(v)
            else
                storageCount = storageCount + 1
            end
        end
    end
    startStorage(proj.Storage)
    for i,v in pairs(proj.Scenes) do
        scenesCount = scenesCount + 1
        local objectsCount = 0
        for e,w in pairs(v.Objects) do
            objectsCount = objectsCount + 1
        end
        startStorage(v.Storage)
        cnt = cnt + objectsCount
    end
    infoPanel:addChild(GUI.text(2,6,getColor(3),lc.ScenesCount .. ': '..tostring(scenesCount)))
    infoPanel:addChild(GUI.text(2,7,getColor(3),lc.FirstScene .. ': '..proj.FirstScene))
    infoPanel:addChild(GUI.text(2,8,getColor(3),lc.ObjectsCount .. ': '..tostring(cnt)))
    infoPanel:addChild(GUI.text(2,9,getColor(3),lc.StorageElementsCount .. ': '..tostring(storageCount)))
end
local projectsCont = winMask:addChild(GUI.container(3,3,47,37))
projectsCont:addChild(GUI.panel(1,1,47,37,getColor(2)))
local projectsLists = projectsCont:addChild(GUI.container(1,1,47,#UserData.OpenGames.Projects*8+4*#UserData.OpenGames.Projects))
local scrollProject = {hidden = true}
local function checkCountForScrollBar()
    if #UserData.OpenGames.Projects > 4 then
        if scrollProject.hidden == false then
            scrollProject:remove()
        end
        scrollProject = projectsCont:addChild(GUI.scrollBar(46,2,1,35,getColor(1),getColor(3),1,#UserData.OpenGames.Projects-3,1,1,1))
        scrollProject.onTouch = function()
            projectsLists.localY = -(scrollProject.value * 9 - 10)
        end
    end
end
local function projectPanel(i)
    local projectPath = UserData.OpenGames.Projects[i]
    local bonus = 1
    if scrollProject.hidden == false then
        bonus = 0
    end
    local BGpanel = GUI.container(3,i*7-7+2*i,40+bonus,7)
    BGpanel:addChild(GUI.panel(1,1,40+bonus,7,getColor(1))) -- Project Panel bg
    BGpanel:addChild(GUI.text(2,2,getColor(3),readProject(projectPath).Name)) -- Project line
    BGpanel:addChild(GUI.text(2,4,getColor(3),projectPath)) -- Project line
    local tmp = BGpanel:addChild(GUI.button(2,6,38+bonus,1,getColor(2),getColor(3),getColor(3),getColor(2),' '))
    BGpanel.index = i
    tmp.onTouch = function() -- Middle Line
        ChoosedProject = BGpanel.index or 1
        reloadInfo()
    end
    return BGpanel
end
local hintCreateNewProject
checkCountForScrollBar()
for i = 1,#UserData.OpenGames.Projects do
    projectsLists:addChild(projectPanel(i))
end

local deleteProject = winMask:addChild(GUI.button(55,3,21,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.deleteProject))
local loadProject = winMask:addChild(GUI.button(55,37,44,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.loadProject))
deleteProject.onTouch = function()
    if projectsLists.children[ChoosedProject] then
        table.remove(projectsLists.children,ChoosedProject)
        fs.remove(UserData.OpenGames.Projects[ChoosedProject])
        table.remove(UserData.OpenGames.Projects,ChoosedProject)
        projectsLists.localY = 1
        scrollProject.value = 1
        for i = 1,#projectsLists.children do
            if projectsLists.children[i].index > ChoosedProject then
                projectsLists.children[i].index = projectsLists.children[i].index - 1
                projectsLists.children[i].localY = projectsLists.children[i].localY - 9
            end
        end
        projectsLists.height = #UserData.OpenGames.Projects*8+4*#UserData.OpenGames.Projects
        System.saveUserSettings()
        if #UserData.OpenGames.Projects == 0 then
            deleteProject.disabled = true
            loadProject.hidden = true
            infoPanel.hidden = true
            hintCreateNewProject.hidden = false
        else
            ChoosedProject = 1
            reloadInfo()
            checkCountForScrollBar()
        end
        if #UserData.OpenGames.Projects <= 4 then
            projectsLists.localY = 1
            scrollProject:remove()
            scrollProject = {hidden = true}
        end
    end
end
local function createWindow(w,h,l)
    local newProjectWin = wk:addChild(GUI.titledWindow(math.ceil(80-w/2),math.ceil(25-h/2),w,h,l,true)) -- 50 and 20 is win.width/2 and win.height/2
    newProjectWin.actionButtons.close.onTouch = function()
        newProjectWin:remove()
    end
    newProjectWin.actionButtons.maximize:remove()
    newProjectWin.actionButtons.minimize:remove()
    newProjectWin.backgroundPanel.colors.background = getColor(1)
    newProjectWin.titlePanel.colors.background = getColor(2)
    newProjectWin.titleLabel.colors.text = getColor(3)
    return newProjectWin
end


local newProject = winMask:addChild(GUI.button(78,3,21,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.newProject))
newProject.onTouch = function()
    local newProjectWin = createWindow(33,15,lc.newProject)
    local pathinput = newProjectWin:addChild(GUI.input(2,3,20,3,getColor(2),getColor(3),0x990000,getColor(3),getColor(2),lc.projectPath,lc.projectPath))
    newProjectWin:addChild(GUI.button(24,3,8,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.Explore)).onTouch = function()
        local filesystemDialog = GUI.addFilesystemDialog(wk, false, 50, math.floor(wk.height * 0.8), lc.Open, lc.Cancel, lc.projectPath, "/")
        filesystemDialog:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_DIRECTORY)
        filesystemDialog.onSubmit = function(path)
            pathinput.text = path
        end
        filesystemDialog:show()
    end
    local projectName = newProjectWin:addChild(GUI.input(2,7,30,3,getColor(2),getColor(3),0x990000,getColor(3),getColor(2),lc.projectName,lc.projectName))
    local done = newProjectWin:addChild(GUI.button(2,12,30,3,getColor(2),getColor(3),getColor(3),getColor(2),lc.createProject))
    done.onTouch = function()
        if fs.exists(pathinput.text) and pathinput.text ~= '' then
            for i = 1,#UserData.OpenGames.Projects do
                if readProject(UserData.OpenGames.Projects[i]).Name == projectName.text and UserData.OpenGames.Projects[i] == fs.removeSlashes(pathinput.text..'/'..projectName.text) then -- My biggest if ever
                    GUI.alert(lc.projectAlrCreated) -- Try to create same project (not cool)
                    return
                end
            end
            if projectName.text ~= '' then
                newProjectWin:remove()
                local newProjectWin = createWindow(10,5,lc.loading)
                newProjectWin.actionButtons.close:remove()
                local crutyolka = newProjectWin:addChild(GUI.progressIndicator(4,2,getColor(2),getColor(2)+0x202020,getColor(3)))
                crutyolka.active = true
                fs.makeDirectory(fs.removeSlashes(pathinput.text..'/'..projectName.text))
                crutyolka:roll()
                wk:draw(true)
                local proj = loadfile("/OpenGames 2/Main.lua")(true).Project
                proj.Name = projectName.text
                crutyolka:roll()
                wk:draw(true)
                fs.writeTable(fs.removeSlashes(pathinput.text..'/'..projectName.text)..'/.Game.dat',proj)
                crutyolka:roll()
                wk:draw(true)
                UserData.OpenGames.Projects[#UserData.OpenGames.Projects+1] = fs.removeSlashes(pathinput.text..'/'..projectName.text)
                System.saveUserSettings()
                crutyolka:roll()
                wk:draw(true)
                projectsLists.height = #UserData.OpenGames.Projects*8+4*#UserData.OpenGames.Projects
                projectsLists:addChild(projectPanel(#UserData.OpenGames.Projects))
                crutyolka:roll()
                wk:draw(true)
                ChoosedProject = #UserData.OpenGames.Projects
                deleteProject.disabled = false
                loadProject.hidden = false
                hintCreateNewProject.hidden = true
                crutyolka:roll()
                wk:draw(true)
                checkCountForScrollBar()
                newProjectWin:remove()
                reloadInfo()
            end
        end
    end
end
hintCreateNewProject = winMask:addChild(GUI.text(100-2-math.ceil(uni.len(lc.hintCreateNewProject)*1.5),38,getColor(3),lc.hintCreateNewProject))
hintCreateNewProject.hidden = true
if #UserData.OpenGames.Projects == 0 then
    hintCreateNewProject.hidden = false
    deleteProject.disabled = true
    loadProject.hidden = true
else
    reloadInfo()
end
-- nice line in the middle of app
local niceLineContainter = winMask:addChild(GUI.container(52,3,1,37))
niceLineContainter:addChild(GUI.panel(1,1,1,37,getColor(2)))
local line1 = niceLineContainter:addChild(GUI.panel(1,1,1,5,getColor(3)))
local timestamp = require('computer').uptime()
niceLineContainter.eventHandler = function()
    if timestamp+0.5 < require('computer').uptime() then
        timestamp = require('computer').uptime()
        line1.localY = line1.localY + 1
        if line1.localY == 37 then
            line1.localY = -5
        end
        wk:draw(true)
    end
end


local itemSettings = menu:addItem(lc.settings)
itemSettings.onTouch = function()
    local settingsWin = createWindow(80,29,lc.settings)
    local paramsanel = settingsWin:addChild(GUI.container(29,3,50,26))
    paramsanel:addChild(GUI.panel(1,1,50,26,getColor(2)))
    local settingsinfo = paramsanel:addChild(GUI.container(2,1,50,26))
    local function createSetting(setting,index)
        local toend = GUI.container(2,index*6-6+index*2,48,26)
        toend:addChild(GUI.panel(1,1,46,7,getColor(1)))
        toend:addChild(GUI.text(3,2,getColor(3),setting.text))
        if setting.type == 'input' then
            toend:addChild(GUI.input(3,4,44,3,getColor(2),getColor(3),0xFF0000,getColor(3),getColor(2),UserData.OpenGames.Settings[setting.paramName],lc.text)).onInputFinished = function(_,self)
                UserData.OpenGames.Settings[setting.paramName] = self.text
            end
        elseif setting.type == 'comboBox' then
            local tmp = toend:addChild(GUI.comboBox(3, 4, 42, 3, getColor(2), getColor(3), getColor(2), getColor(3))) -- Украдено из первого Opengames
            if UserData.OpenGames.Settings[setting.paramName] == nil then
                UserData.OpenGames.Settings[setting.paramName] = false
            end
            if setting.vars then
                for i = 1, #setting.vars do
                    tmp:addItem(setting.vars[i].text).onTouch = function()
                        UserData.OpenGames.Settings[setting.vars[i].param] = setting.vars[i].paramName
                        System.saveUserSettings()
                    end
                end
            else
                if UserData.OpenGames.Settings[setting.paramName] == true then
                    tmp:addItem(lc.truee).onTouch = function()
                        UserData.OpenGames.Settings[setting.paramName] = true
                        System.saveUserSettings()
                    end
                    tmp:addItem(lc.falsee).onTouch = function()
                        UserData.OpenGames.Settings[setting.paramName] = false
                        System.saveUserSettings()
                    end
                else
                    tmp:addItem(lc.falsee).onTouch = function()
                        UserData.OpenGames.Settings[setting.paramName] = false
                        System.saveUserSettings()
                    end
                    tmp:addItem(lc.truee).onTouch = function()
                        UserData.OpenGames.Settings[setting.paramName] = true
                        System.saveUserSettings()
                    end
                end
            end
        end
        return toend
    end
    local function showSetting(settings)
        settingsinfo:removeChildren()
        for i = 1, #settings do
            settingsinfo:addChild(createSetting(settings[i],i))
        end
    end
    local paramsChoosePanel = settingsWin:addChild(GUI.container(2,3,25,26))
    paramsChoosePanel:addChild(GUI.panel(2,1,25,26,getColor(2)))
    paramsChoosePanel:addChild(GUI.button(4,2,20,3,getColor(1),getColor(3),getColor(1),getColor(2),lc.preferences)).onTouch = function()
        local idk = fs.list(hubPath..'/Localizations')
        local toend = {}
        for i = 1, #idk do
            table.insert(toend,1, {param = 'preferdLanguage',paramName = string.gsub(idk[i],'.lang',''),text = string.gsub(idk[i],'.lang','')})
        end
        showSetting({{type='comboBox',paramName='',text=lc.preferdLanguage,vars=toend},{type='comboBox',paramName='CurrentTheme',text=lc.useDarkTheme}})
    end
end
loadProject.onTouch = function()
    win:resize(160,50)
    win.titleLabel.text = lc.LabelEditor
    winMask:remove()
    win.localX = 1
    win.localY = 1
    itemSettings:remove()
    loadfile(hubPath..'/Editor.lua')(UserData.OpenGames.Projects[ChoosedProject], {wk,win,menu})
end