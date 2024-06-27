local isDebug = false
local GUI = require("GUI")
local System = require("System")
local text = require("Text")
local gpu = require("Component").gpu
local UserData = System.getUserSettings()
local timeWas = os.clock()
local startTime = timeWas
local wasOpenCommand = false
local commandWindow
local args = {...}
_,args = System.parseArguments(table.unpack(args))
args.GPUBuffers = true
local OE = {
    Time = {
        deltaTime = 0,
        timeElapsed = 0
    },
    version = "0.3",
    maxFPS = 60,
    Project = {
        Storage = {},
        Name="EmptyProject",
        IconFile = false, -- file name
        FirstScene = 'Empty',
        Window = {Color = 0x303030},
        Localization = {['Russian']={}},
        Scenes = {}
    }
}
OE.huge = 2147483647 --int max, i guess
local function loadModule(ModuleName,...)
    OE[ModuleName] = assert(loadfile(string.gsub(System.getCurrentScript(),"Main.lua",ModuleName..".lua")))(OE,...)
end
loadModule("Render", nil, not args.GPUBuffers, false, isDebug)
loadModule("Script")
loadModule("Localization")
loadModule("Input")
loadModule("Storage")
loadModule("Sound")
loadModule("Network")
function OE.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[OE.deepcopy(orig_key)] = OE.deepcopy(orig_value)
        end
        setmetatable(copy, OE.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
local function removeObject(Object)
    OE.CurrentScene[Object._ID].Render:removeGraphicObject()
    OE.CurrentScene[Object._ID] = nil
end
function OE.initWindow(Workspace)
    OE.Render.Window = GUI.workspace()
    OE.Render.Workspace = OE.Render.Window:addChild(GUI.container(1,1,160,50))
    OE.Render.Window.OE = OE
    local was = os.clock()
    if isDebug then
        commandWindow = OE.Render.Window:addChild(GUI.titledWindow(70,5,80,25,"OE2 command window",true))
        commandWindow.hidden = true
        commandWindow.actionButtons:remove()
        commandWindow.backgroundPanel.colors.background, commandWindow.titleLabel.colors.text, commandWindow.titlePanel.colors.background = 0x303030, 0x404040, 0x202020
        local commandWindowLines = commandWindow:addChild(GUI.textBox(1,3,78,19,0x303030, 0x909090, {},1,2,0))
        commandWindow.print = function(...)
            local args = {...}
            local color = not args[1] and 0xBB0000 or 0x909090
            local recursive
            local maxRecusive = 10
            local function serialize(tbl,Index)
                recursive = recursive + 1
                if recursive <= maxRecusive then
                    if Index then
                        table.insert(commandWindowLines.lines,{text=string.rep("   ",recursive).."InTable: " .. Index,color=color})
                        commandWindowLines:scrollDown()
                    end
                    for i,v in pairs(tbl) do
                        i = '["' ..i .. '"]'
                        if type(v) == "table" then
                            if v == tbl then
                                table.insert(commandWindowLines.lines,{text=string.rep("   ",recursive+1) .. "Recursion on main table",color=0xAAAA00})
                                commandWindowLines:scrollDown()
                            else
                                serialize(v,i)
                                recursive = recursive - 1
                            end
                        else
                            for _, w in pairs(text.wrap(i .." = " .. tostring(v),78)) do
                                table.insert(commandWindowLines.lines,{text=string.rep("   ",recursive+1) .. w,color=color})
                                commandWindowLines:scrollDown()
                            end
                        end
                    end
                else
                    table.insert(lines,{text=string.rep('   ',recursive+1) .. 'Max recursion lock',color=0xAAAA00})
                end
            end
            for i = 2, #args do
                if type(args[i]) == "table" then
                    recursive = -1
                    serialize(args[i],"_RETURN_" .. tostring(i-1))
                else
                    for _, v in pairs(text.wrap(tostring(args[i]),78)) do
                        table.insert(commandWindowLines.lines,{text=v,color=color})
                        commandWindowLines:scrollDown()
                    end
                end
            end
        end
        commandWindow:addChild(GUI.input(1,23,80,3,0x505050, 0x202020,0x202020, 0x505050, 0x202020, "local args = {...} return args[1].", "> Command")).onInputFinished = function(_,we)
            commandWindow.print(pcall(function() return load(we.text)(OE) end))
        end
    end
    OE.Render.Window.eventHandler = function(_,We,...) -- For scripts that in thread, and stuff like that
        We.OE.lastEvent = {...}
        We.OE.tick()
        if OE.Input.getButtonUp(OE.Input.keyCode.floatLine) then
            if not wasOpenCommand then
                wasOpenCommand = true
                commandWindow.hidden = false
            else
                wasOpenCommand = false
                commandWindow.hidden = true
            end
        elseif OE.Input.getButton(OE.Input.keyCode.altLeft) and OE.Input.getButton(OE.Input.keyCode.four) then
            OE.exit()
        end
    end
end
OE.Debug = {
    Log = function(str, isErr)
        commandWindow.print(not isErr, str)
    end
}
function OE.exit()
    OE.Render.Abort()
    OE = nil
end
function OE.tick()
    local clocks,time = os.clock(),OE.Time
    time.timeElapsed = clocks - startTime
    OE.Scripts.runEveryWithName('Update')
    time.delta = clocks - timeWas
    local timeCheckpoint = clocks + math.max(0, 1/OE.maxFPS - time.deltaTime)
  while os.clock() < timeCheckpoint do end
    time.deltaTime = math.max(time.deltaTime,time.deltaTime + (1/OE.maxFPS -time.deltaTime))
    timeWas = os.clock()
    if isDebug then
        commandWindow:draw()
    end
    OE.Render:proccess()
end
local function addScript(object, source, name,compile)
    object[name] = {_Enabled = true,
    _SourceFile = source}
    if compile then
        OE.Script.Compile(Object,OE.Storage.getFile(object._SourceFile))
        setmetatable(object[name],result)
        if object[name].Start then object[name].Start() end
    end
end
function OE.nilObject()
    local obj = {
        _ID = math.random(0,OE.huge),
        _Enabled = true,
        _Index = 1,
        _Remove = removeObject,
        setIndex = function(me, index)
            table.insert(OE.CurrentScene.Objects,index,me)
            table.remove(OE.CurrentScene.Objects,me._Index)
            me._Index = index
        end
        addScript = addScript
    }
    obj:addScript('MAIN_Transform.lua','Transform')
    return obj
end
function OE.createScene(Name)
    local toend = {Object={},Localization={}}
    toend.Localization[UserData.localizationLanguage] = {}
    OE.Scenes[Name] = toend
    return toend
end
function OE.loadScene(SceneName)
    local currentScene = OE.CurrentScene
    if currentScene then
        OE.Render.clearRender()
    end
    currentScene = OE.deepcopy(OE.Project.Scenes[SceneName]) -- В проектах экземпляр сцены, после её загрузки она меняется по скриптам не зависимо от экземпляра
    for i = 1, #currentScene.Objects do
        local Object = currentScene.Objects[i]
        if Object._Enabled then
            for i, v in pairs(Object) do
                if v._Enabled and string.sub(i,1,1) ~= '_' then
                    local result = OE.Script.Compile(Object,OE.Storage.getFile(v._SourceFile))
                    setmetatable(v,result)
                    if v.Start then v.Start() end
                end
            end
        end
    end
end
function OE.createObject()
    local object = OE.nilObject()
    object._Index = #OE.CurrentScene.Objects
    OE.CurrentScene.Objects[#OE.CurrentScene.Objects + 1] = object
    return object
end
return OE
