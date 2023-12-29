local GUI = require("GUI")
local System = require("System")
local fs = require("FileSystem")
local Event = require("Event")
local text = require("Text")
local Screen = require("Screen")
local gpu = require("Component").gpu
local wasInited
local UserData = System.getUserSettings()
local timeWas = os.clock()
local startTime = os.clock()
local wasOpenCommand = false
local commandWindow
local args = {...}
local allocatedBuffer
local OE = {
    Time = {
        deltaTime = 0,
        timeElapsed = 0
    },
    version = "0.2b",
    maxFPS = 60,
    frames = 0,
    Project = {
        Storage = {},
        Name="EmptyProject",
        IconFile = false, -- file name
        FirstScene = 'Empty',
        Window = {Color = 0x303030},
        Localization = {['Russian']={}},
        Scenes = {
            ["Empty"] = {
                Storage = {},
                Localization = {},
                FilesPaths = {},
                Name = "Empty",
                Objects = {},
                RenderObjects = {}
            }
        }
    }
}
OE.Project.Scenes['Empty'].Localization[UserData.localizationLanguage] = {}
OE.huge = 2147483647 --int max, i guess
local function loadModule(ModuleName)
    OE[ModuleName] = assert(loadfile(string.gsub(System.getCurrentScript(),"/Main.lua","/"..ModuleName..".lua")))(OE)
end
loadModule("Render")
loadModule("Script")
loadModule("Component")
loadModule("Localization")
loadModule("Input")
loadModule("Storage")
loadModule("Sound")
loadModule("LocalNetwork")
function OE.deepcopy(orig) -- For 'load scene'
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
    Object:removeFromRender()
    for i = 1, #OE.Script.ExecutableForFrame do
        if OE.Script.ExecutableForFrame[i].objectThatCalls.ID == Object.ID then
            table.remove(OE.Script.ExecutableForFrame,i)
        end
    end
    OE.CurrentScene[Object.ID] = nil
end
local function setRenderMode(Object,Mode)
    local modes = OE.Render.renderTypes
    if OE.CurrentScene.RenderObjects[Object.ID] then
        Object:removeFromRender()
    end
    if Mode == modes.BUTTON then
        Object.onTouch = function() GUI.alert("Meaw-meaw") end
        Object.ButtonType = OE.Render.ButtonTypes.Default
    elseif Mode == modes.INPUT then
        Object.onInputFinished = function() GUI.alert("Meaw-meaw") end
    elseif Mode == modes.SWITCH then
        Object.onStateChanged = function() GUI.alert("Meaw-meaw") end
        Object.State = false
    elseif Mode == modes.SLIDER then
        Object.onValueChanged = function() return true end
        Object.maxValue = 100
        Object.Value = 0
        Object.minValue = 0
    elseif Mode == modes.PROGRESSINDICATOR then
        Object.Active = false
        Object.Roll = function() return 'Add to render first' end
    elseif Mode == modes.PROGRESSBAR then
        Object.Value = 0
    elseif Mode == modes.COMBOBOX then
        Object.Items = {}
        function Object.addItem(name,onTouch,disabled)
            table.insert(Object.Items,1,{name=name,onTouch=onTouch,disabled=disabled})
        end
        function Object.removeItem(nameidk)
            for i = 1, #Object.Items do
                if Object.Items[i].name == nameidk then
                    table.remove(Object.Items,i)
                    return true
                end
            end
            return false
        end
    end
    Object.renderMode = Mode
end
function OE.initWindow(Workspace)
    if wasInited then
        OE.Render.Window = nil
    else
        wasInited = true
    end
    OE.Render.Window = GUI.workspace()
    OE.Render.Window:addChild(GUI.panel(1,1,160,50,OE.Project.Window.Color))
    OE.Render.Workspace = OE.Render.Window:addChild(GUI.container(1,1,160,50))
    OE.Render.Window.OE = OE
    local fps = OE.Render.Window:addChild(GUI.text(1,1,0xFFFFFF,''))
    local was = os.clock()
    commandWindow = OE.Render.Window:addChild(GUI.titledWindow(70,5,80,25,"OE2 command window",true))
    commandWindow.hidden = true
    commandWindow.actionButtons:remove()
    commandWindow.backgroundPanel.colors.background = 0x303030
    commandWindow.titleLabel.colors.text = 0x404040
    commandWindow.titlePanel.colors.background = 0x202020
    local commandWindowLines = commandWindow:addChild(GUI.textBox(1,3,78,19,0x303030, 0x909090, {},1,2,0))
    commandWindow.print = function(...)
        local args = {...}
        local color = 0x909090
        if args[1] == false then
            color = 0xBB0000
        end
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
            end
        end
        for i = 2, #args do
            if type(args[i]) == "table" then
                recursive = -1
                serialize(args[i],"_RETURN" .. tostring(i-1))
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
    OE.Render.Window.eventHandler = function(_,We,...) -- For scripts that in thread, and stuff like that
        We.OE.lastEvent = {...}
        We.OE.tick()
        if was < os.clock() then
            fps.text = tostring(OE.frames)
            OE.prevFPS = OE.frames
            OE.frames = 0
            was = os.clock() + 1
        end
        if OE.Input.getButtonUp(OE.keyCode.floatLine) then
            if not wasOpenCommand then
                wasOpenCommand = true
                commandWindow.hidden = false
            else
                wasOpenCommand = false
                commandWindow.hidden = true
            end
        elseif OE.Input.getButton(OE.keyCode.altLeft) and OE.Input.getButton(OE.keyCode.four) then
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
    if not args.GPUBuffers then 
        gpu.freeBuffer(allocatedBuffer)
        gpu.setActiveBuffer(0) 
    end
    OE.Render.Window:stop()
    OE = nil
end
function OE.tick()
    local clocks = os.clock()
    OE.Time.timeElapsed = clocks - startTime
    OE.frames = OE.frames + 1
    for i,v in  pairs(OE.Script.ExecutableForFrame) do
        if tonumber(i) >= 0 then
            if v.objectThatCalls.Enabled then
                assert(v.Script.Update)()
            end
        end
    end
    if not args.GPUBuffers then gpu.bitblt() end
    OE.Time.deltaTime = clocks - timeWas
    timeCheckpoint = clocks
	while os.clock() < timeCheckpoint + math.max(0, 1/OE.maxFPS - OE.Time.deltaTime) do end
    OE.Time.deltaTime = math.max(OE.Time.deltaTime,OE.Time.deltaTime + (1/OE.maxFPS -OE.Time.deltaTime))
    timeWas = os.clock()
    OE.Render.Window:draw()
end
function OE.emptyObject()
    return {Transform = {Position = {x = 0, y = 0}, Scale = {Width = 0, Height = 0}},
    ID = math.random(0,OE.huge),
    addToRender = OE.Render.addToRender,
    removeFromRender = OE.Render.removeFromRender,
    getComponent = OE.Component.getComponent,
    getComponentID = OE.Component.getComponentID,
    downRenderOrder = OE.Render.downRenderOrder,
    upRenderOrder = OE.Render.upRenderOrder,
    toTopRenderOrder = OE.Render.toTopRenderOrder,
    setRenderMode = setRenderMode,
    Enabled = true,
    Components = {},
    remove = removeObject,
    addComponent = OE.Component.createComponent}
end
function OE.createEmptyScene()
    return {Object={},RenderObjects={}}
end
function OE.loadScene(SceneName, dontLaunchScripts)
    if OE.CurrentScene then
        OE.Render.clearRender()
        OE.Script.ExecutableForFrame = {}
    end
    OE.CurrentScene = OE.deepcopy(OE.Project.Scenes[SceneName]) -- В проектах экземпляр сцены, после её загрузки она меняется по скриптам не зависимо от экземпляра
    for i = 1, #OE.CurrentScene.Objects do
        OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID] = OE.deepcopy(OE.Project.Scenes[SceneName].Objects[i])
        OE.Render.addToRender(
            OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID],
            OE.CurrentScene.Objects[i].RenderType
        )
    end
    if not dontLaunchScripts then
        OE.Script.Reload()
    end
end
function OE.reloadScene()
    OE.loadScene(OE.CurrentScene.Name)
end
function OE.getProjectName()
    return OE.Project.Name
end
function OE.createObject()
    local object = OE.emptyObject()
    OE.CurrentScene.Objects[object.ID] = object
    return object
end
_,args = System.parseArguments(table.unpack(args))
args.GPUBuffers = true
if not args.withoutWindow then
    OE.initWindow()
    OE.loadScene("Empty")
end
if not args.GPUBuffers then
    allocatedBuffer = gpu.allocateBuffer() -- If you have issues on this, please, update OC to 1.7.6+ version, or launch game/editor with '--GPUBuffers=ture' arg
    gpu.setActiveBuffer(allocatedBuffer)
end
return OE