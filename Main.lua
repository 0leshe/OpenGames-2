local isDebug, debugHandler = true
local GUI = require("GUI")
local System = require("System")
local pull = require('Event').pull
local gpu = require("Component").gpu
local timeWas = os.clock()
local startTime = timeWas
local wasOpenCommand = false
local running = true
local args = {...}
_,args = System.parseArguments(table.unpack(args))
args.GPUBuffers = true
local OE = {
    root = string.gsub(System.getCurrentScript(),"Main.lua",""),
    Time = {
        deltaTime = 0,
        timeElapsed = 0
    },
    version = "0.4",
    maxFPS = 201,
    Project = {
        Storage = {},
        Name="EmptyProject",
        IconFile = false, -- file name
        FirstScene = '',
        Localization = {['Russian']={}},
        Scenes = {}
    }
}
OE.huge = 2147483647 --int max, i guess
local function loadModule(ModuleName,...)
    local wk,response = GUI.workspace(),false
    OE[ModuleName] = assert(loadfile(OE.root .. ModuleName..".lua"))(OE,...)
    if not OE[ModuleName] then
		local container = GUI.addBackgroundContainer(wk, true, true)
        container.layout:addChild(GUI.button(1, 2, 20, 3, 0x989898, 0x030303, 0x030303, 0x989898, 'Continue')).onTouch = function()
            container:remove()
            response = true
        end
        container.layout:addChild(GUI.button(2, 2, 20, 3, 0x989898, 0x030303, 0x030303, 0x989898, 'Exit')).onTouch = function()
            response = true
            OE = nil
            exit()
            wk:remove()
        end
        container.layout:addChild(GUI.text(1, 1, 0xF0F0F0, 'Module with name '.. ModuleName .. ' was loaded incorrectly. Still wanna continue?'))
        wk:start(1)
        while not response do
            pull(0)
        end
    end
    wk:stop()
    wk = nil
end
loadModule("Render", nil, not args.GPUBuffers, false, isDebug)
loadModule("Script")
loadModule("Localization")
loadModule("Input")
loadModule("Storage")
--loadModule("Sound") не работает на данный момент
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
    OE.Script.runEveryWithName('onObjectRemove',Object)
    OE.CurrentScene[Object._ID] = nil
    Object = nil
end
function OE.initWindow(Workspace)
    while running do
        OE.lastEvent = {pull(0)}
        if OE.lastEvent[1] ~= '' then
            OE.Input.onEvent()
        end
        OE.tick()
        if OE.Input.getButton(OE.Input.keyCodes.ALT_LEFT) and OE.Input.getButton(OE.Input.keyCodes.FOUR) then
            OE.exit()
        end
    end
end
function OE.exit()
    OE.Render.clearRender()
    if isDebug then
        debugHandler:write('Engine stop.') 
        debugHandler:close() 
    end
    running = false
    OE = nil
end
function OE.tick()
    local clocks,time = os.clock(),OE.Time
    time.timeElapsed = clocks - startTime
    OE.Script.runEveryWithName('Update')
    time.deltaTime = clocks - timeWas
    local timeCheckpoint = clocks + math.max(0, 1/OE.maxFPS - time.deltaTime)
    while os.clock() < timeCheckpoint do end
    time.deltaTime = math.max(time.deltaTime,time.deltaTime + (1/OE.maxFPS -time.deltaTime))
    timeWas = os.clock()
    OE.Render.Matrix.process()
end
local function addScript(object, source, name,compile)
    object[name] = {_Enabled = true,
    _SourceFile = source, _SetEnable = function(self, toggle)
        if toggle then
            OE.Script.runEveryWithName('onObjectEnable')
        else
            OE.Script.runEveryWithName('onObjectDisable')
        end
        self._Enabled = toggle
    end}
    if compile then
        OE.Script.Compile(object,object[name],name)
    end
end
function OE.nilObject()
    local obj = {
        _ID = math.random(0,OE.huge),
        _Enabled = true,
        _Index = 1,
        _Remove = removeObject,
        _setIndex = function(me, index)
            local tmp = OE.CurrentScene.Objects[index]
            OE.CurrentScene.Objects[index] = OE.CurrentScene.Objects[me._Index]
            OE.CurrentScene.Objects[me._Index] = tmp
            me._Index = index
        end,
        _addScript = addScript
    }
    obj:_addScript('MAIN_Transform.lua','Transform')
    return obj
end
function OE.createScene(Name)
    OE.Project.Scenes[Name] = {Name = Name, Objects={}}
    return OE.Project.Scenes[Name]
end
function OE.loadScene(SceneName)
    if OE.CurrentScene then
        OE.Render.clearRender()
    end
    OE.CurrentScene = OE.deepcopy(OE.Project.Scenes[SceneName]) -- В проектах экземпляр сцены, после её загрузки она меняется по скриптам не зависимо от экземпляра
    local currentScene = OE.CurrentScene
    for i = 1, #currentScene.Objects do
        local Object = currentScene.Objects[i]
        if Object._Enabled then
            OE.Script.Compile(Object,Object.Transform,'Transform')
            for i, v in pairs(Object) do
                if string.sub(i,1,1) ~= '_' and v._Enabled and i ~= 'Transform'then
                    OE.Script.Compile(Object,v,i)
                end
            end
        end
    end
    OE.Script.runEveryWithName('Start')
end
function OE.createObject(ObjectName, SceneName)
    local object = OE.nilObject()
    object._Name = ObjectName
    if SceneName then
        object._Index = #OE.Project.Scenes[SceneName].Objects+1
        OE.Project.Scenes[SceneName].Objects[#OE.Project.Scenes[SceneName].Objects + 1] = object
    else
        object._Index = #OE.CurrentScene.Objects+1
        OE.CurrentScene.Objects[#OE.CurrentScene.Objects + 1] = object
        OE.Script.Compile(object,object.Transform,'Transform')
    end
    return object
end

if isDebug then
    local ser = require('text').serialize
    debugHandler = require('Filesystem').open(OE.root .. 'lastLog.txt', 'w')
    debugHandler:write(os.date("%X",System.getTime()) .. ' [DBG] Engine start.\n') 
    OE.log = function(...)
        local args = {...}
        debugHandler:write(os.date("%X",System.getTime()) .. ' [DBG] ')
        for i = 1, #args do
            if type(args[i]) == 'table' then
                debugHandler:write(ser(args[i]) .. '    ')
            else
                debugHandler:write(tostring(args[i]) .. '    ')
            end
        end
        debugHandler:write('\n')
    end
else
    OE.log = function() return false, 'debug is false' end
end

return OE
