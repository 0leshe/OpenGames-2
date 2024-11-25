local isDebug, debugHandler = false
local GUI = require("GUI")
local System = require("System")
local pull = require('Event').pull
local gpu = require("Component").gpu
local fs = require("Filesystem")
local timeWas = os.clock()
local startTime = timeWas
local wasOpenCommand = false
local running = true
local args = {...}
_,args = System.parseArguments(table.unpack(args))
args.GPUBuffers = true
local OE = {
    root = string.gsub(System.getCurrentScript(), 'Main.lua', ''),
    Time = {
        deltaTime = 0,
        timeElapsed = 0
    },
    huge = 1797693134^6, -- int max +-
    version = "0.4",
    applicationRoot = '/',
    maxFPS = math.huge,
    Project = {
        Storage = {},
        Name="EmptyProject",
        IconFile = false, -- file name
        FirstScene = '',
        Localization = {['Russian']={}},
        Scenes = {}
    }
}
local listModulesToLoadRaw, listModulesToLoad = fs.list(OE.root..'Modules/'), {}
for i = 1, #listModulesToLoadRaw do
    if not fs.isDirectory(OE.root..'Modules/'..listModulesToLoadRaw[i]) then
        listModulesToLoad[listModulesToLoadRaw[i]] = {}
    end
end
listModulesToLoad['Render.lua'], listModulesToLoadRaw = {nil, not args.GPUBuffers, false, isDebug}, nil
for i,v in pairs(listModulesToLoad) do
    OE[string.gsub(i,'.lua','')] = assert(loadfile(OE.root..'Modules/' .. i))(OE,table.unpack(v))
end

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
    OE.Script.runEveryWithName('onApplicationExit')
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
        _ScriptsOrder = {}
    }
    OE.unserializeObject(obj)
    OE.Script.shared.addScript(obj,"MAIN_Transform.lua", 'Transform')
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
        OE.unserializeObject(Object)
        if Object._Enabled then
            for i = 1, #Object._ScriptsOrder do
                local script = Object[Object._ScriptsOrder[i]]
                if string.sub(Object._ScriptsOrder[i],1,1) ~= '_' and script._Enabled then
                    OE.Script.Compile(Object,script,Object._ScriptsOrder[i])
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
        OE.Script.Compile(object,object.Transform,'Transform', true)
    end
    return object
end
if isDebug then
    local ser = require('text').serialize
    debugHandler = fs.open(OE.root .. 'lastLog.txt', 'w')
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
        return true
    end
    OE.errlog = function(...)
        local args = {...}
        debugHandler:write(os.date("%X",System.getTime()) .. ' [ERR] ')
        for i = 1, #args do
            if type(args[i]) == 'table' then
                debugHandler:write(ser(args[i]) .. '    ')
            else
                debugHandler:write(tostring(args[i]) .. '    ')
            end
        end
        debugHandler:write('\n')
        return true
    end
else
    OE.log = function() return false, 'debug is disabled' end
end

OE.Script.shared.removeObject = function(Object, Scene)
    if Scene then
        OE.Project.Scenes[Scene][Object._Index] = nil
    else
        OE.Script.runEveryWithName('onObjectRemove',Object)
        OE.CurrentScene[Object._Index] = nil
        Object = nil
    end
end

OE.Script.shared.setIndex = function(me, index)
    local tmp = OE.CurrentScene.Objects[index]
    OE.CurrentScene.Objects[index] = OE.CurrentScene.Objects[me._Index]
    OE.CurrentScene.Objects[me._Index] = tmp
    me._Index = index
end
OE.Script.shared.getScriptOrder = function(object,name)
	for i, v in pairs(object._ScriptsOrder) do
		if v == name then
			return i
		end
	end
	return false
end
local scriptEnable = function(self, toggle)
    if toggle then
        OE.Script.runEveryWithName('onScriptEnable', self._Object)
    else
        OE.Script.runEveryWithName('onScriptDisable',self._Object)
    end
    self._Enabled = toggle
end
local scriptRemove = function(self)
    table.remove(self._Object_.scriptsOrder, self._Object:_getScriptOrder(self._Name))
    self._Object[self._Name] = nil
end
OE.Script.shared.addScript = function(Object, source, name, compileNow)
    table.insert(Object._ScriptsOrder, name)
    Object[name] = {_Object = object, _Name = name, _Index = #Object._ScriptsOrder, _Enabled = true, _SourceFile = source, _Remove = scriptRemove , _SetEnable = scriptEnable}
    if compileNow then
        OE.Script.Compile(Object,Object[name],name)
    end
end
function OE.unserializeObject(object)
    object._getScriptOrder = OE.Script.shared.getScriptOrder
    object._Remove = OE.Script.shared.removeObject
    object._addScript = OE.Script.shared.addScript
    object._setIndex = OE.Script.shared.setIndex
end
function OE.serializeObject(object)
    object._getScriptOrder = nil
    object._Remove = nil
    object._addScript = nil
    object._setIndex = nil
end
function OE.findObject(name, Scene)
    local scene
    if Scene then
        scene = OE.Project.Scenes[Scene]
    else
        scene = OE.CurrentScene
    end
    for i = 1, #scene.Objects do
        if scene.Objects[i]._Name == name then
            return scene.Objects[i]
        end
    end
end
function OE.pointInside(object, x, y)
    local Position, Scale
    if object._Name then
        local Position, Scale = object.Transform.Position, object.Transform.Scale
    else
        Position, Scale = {x=object.x, y=object.y}, {width=object.width,height=object.height}
    end
    return x >= Position.x and x < Position.x + Scale.width and y >= Position.y and y < Position.y + Scale.height
end

return OE
