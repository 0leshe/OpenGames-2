<<<<<<< Updated upstream
local GUI = require("GUI")
local System = require("System")
local fs = require("FileSystem")
local wasInited
local UserData = System.getUserSettings()
local allocatedBuffer = require("component").gpu.allocateBuffer()
require("component").gpu.setActiveBuffer(allocatedBuffer)
local timeWas = os.clock()
local startTime = os.clock()
local OE = {
    deltaTime = 0,
    timeElapsed = 0,
    frames = 0,
=======
local isDebug, debugHandler = true
local GUI = require("GUI")
local System = require("System")
local pull = require('Event').pull
local gpu = require("Component").gpu
local fs = require("Filesystem")
local uptime = require("Computer").uptime
local timeWas = os.time()
local startTime = timeWas
local wasOpenCommand = false
local running = true
local args = {...}
_,args = System.parseArguments(table.unpack(args))
--args.GPUBuffers = isDebug
local OE = {
    loglevel = 0,
    nilfunction = function() end,
    root = string.gsub(System.getCurrentScript(), 'Main.lua', ''),
    Time = {
        sceneElapsed = 0,
        sceneLoaded = 0,
        scale = 1,
        nextFixedUpdateCall = 0,
        nextFrame = 0,
        time = uptime(),
        deltaTime = 0,
        timeElapsed = 0
    },
    huge = math.maxinteger,
    version = "0.4",
    applicationRoot = '/',
    maxFPS = 22,
>>>>>>> Stashed changes
    Project = {
        Storage = {},
        Name="EmptyProject",
        IconFile = false, -- file name
        FirstScene = 'Empty',
        Window = {Width = 50, Height = 20, Color = 0xAAAAAA, Title = "Empty"},
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
<<<<<<< Updated upstream
OE.Project.Scenes['Empty'].Localization[UserData.localizationLanguage] = {}
OE.Debug = {
    Log = function(str)
        OE.Debug.LogString = OE.Debug.LogString .. "\n" .. str
    end,
    LogString = ""
}
OE.huge = 2147483647 --int max, i guess
local function loadModule(ModuleName)
    OE[ModuleName] = loadfile(string.gsub(System.getCurrentScript(),"/Main.lua","/"..ModuleName..".lua"))(OE)
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
=======

local listModulesToLoadRaw, listModulesToLoad = fs.list(OE.root..'Modules/'), {}
for i = 1, #listModulesToLoadRaw do
    if not fs.isDirectory(OE.root..'Modules/'..listModulesToLoadRaw[i]) then
        listModulesToLoad[listModulesToLoadRaw[i]] = {}
    end
end
listModulesToLoad['Render.lua'], listModulesToLoadRaw = {'perObject', not args.GPUBuffers, true, isDebug}, nil
for i,v in pairs(listModulesToLoad) do
    OE[string.gsub(i,'.lua','')] = loadfile(OE.root..'Modules/' .. i)(OE,table.unpack(v))
end

function OE.deepcopy(orig)
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
local function removeObject(Object)
    OE.Render.removeFromRender(Object)
    for i = 1, #OE.Script.ExecutableForFrame do
        if OE.Script.ExecutableForFrame[i].objectThatCalls.ID == Object.ID then
            table.remove(OE.Script.ExecutableForFrame,i)
        end
    end
    table.remove(OE.CurrentScene,Object.ID)
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
        OE.Render.Window:remove()
    else
        wasInited = true
    end
    _, OE.Render.Window, OE.Render.Menu = System.addWindow(Workspace or GUI.titledWindow(
        1,
        1,
        OE.Project.Window.Width,
        OE.Project.Window.Height,
        OE.Project.Window.Title,
        true
        )
    )
    OE.Render.Window.backgroundPanel.colors.background = OE.Project.Window.Color
    OE.Render.Window.titleLabel.text = OE.Project.Window.Title
    if not Workspace then
        OE.Render.Window.backgroundPanel.color = OE.Project.Window.Color
    end
    OE.Render.Workspace = OE.Render.Window:addChild(GUI.container(1,2,OE.Render.Window.width,OE.Render.Window.height-1))
    OE.Render.Window.OE = OE
    OE.Render.Window.actionButtons.close.onTouch = function()
        OE.exit()
    end
    OE.Render.Window.actionButtons.minimize.onTouch = function()
        require("component").gpu.setActiveBuffer(0)
        OE.Render.Window:minimize()
    end
    local fps = OE.Render.Window:addChild(GUI.text(1,2,0xFFFFFF,''))
    local was = os.clock()
    OE.Render.Window.eventHandler = function(_,We,...) -- Для всяких скриптов которые в потоке, и подобного стафа
        We.OE.lastEvent = {...}
        if We.OE.lastEvent[1] == 'touch' or We.OE.lastEvent[1] == 'drop' or We.OE.lastEvent[1] == 'scroll' then
            We.OE.Render.Window:focus()
            require("component").gpu.setActiveBuffer(allocatedBuffer)
        end
        We.OE.tick()
        if was < os.clock() then
            fps.text = tostring(OE.frames)
            OE.frames = 0
            was = os.clock() + 1
=======
function OE.initWindow(Workspace)
    local time = OE.Time
    while running do
        OE.lastEvent = {pull(0)}
        time.time = uptime()
        time.timeElapsed = time.time - startTime
        time.sceneElapsed = time.time - time.sceneLoaded
        if time.nextFixedUpdateCall <= time.time then
            OE.Script.runEveryWithName('FixedUpdate')
            time.nextFixedUpdateCall = time.time + 1.5
        end
        for i, v in pairs(OE.Script.toInvoke) do
            if i >= time.time then
                for i = 1, #v do
                    v[i]()
                end
                OE.Script.toInvoke[i] = nil
            end
        end
        if time.time > time.nextFrame then
            time.deltaTime = (time.time - timeWas) * time.scale
            time.deltaTime = math.max(time.deltaTime,time.deltaTime + (1/OE.maxFPS -time.deltaTime))
            timeWas = uptime()
            OE.Script.runEveryWithName('Update')
            OE.Render.processAll()
            time.nextFrame = time.time + 1/OE.maxFPS
        end
        if OE.lastEvent[1] ~= '' then
            OE.Input.onEvent()
        end
        if OE.Input.getButton(OE.Input.keyCodes.ALT_LEFT) and OE.Input.getButton(OE.Input.keyCodes.FOUR) or OE.Input.getButton(OE.Input.keyCodes.CONTROL_LEFT) and OE.Input.getButton(OE.Input.keyCodes.W) then
            OE.exit()
>>>>>>> Stashed changes
        end
    end
    OE = nil
end
function OE.exit()
<<<<<<< Updated upstream
    OE.Render.Window:remove()
    require("component").gpu.setActiveBuffer(0)
end
function OE.tick()
    OE.timeElapsed = os.clock() - startTime
    OE.frames = OE.frames + 1
    for i,v in  pairs(OE.Script.ExecutableForFrame) do
        if tonumber(i) > 0 then
            if v.objectThatCalls.Enabled then
                System.call(v.Script.Update,v.objectThatCalls,OE)
            end
=======
    OE.Script.runEveryWithName('onApplicationExit')
    if isDebug then
        debugHandler:write('Engine stop.') 
        debugHandler:close() 
    end
    if not args.GPUBuffers then
        OE.Render.returnBuffer()
    end
    OE.Render.dissolve()
    running = false
end
local function addScript(object, source, name,compile)
    object[name] = {_Enabled = true,
    _SourceFile = source,
    _SetEnable = function(self, toggle)
        if toggle then
            OE.Script.runEveryWithName('onObjectEnable')
>>>>>>> Stashed changes
        else
            System.call(v.Script.Update,v.objectThatCalls,OE)
        end
<<<<<<< Updated upstream
    end
    System.getWorkspace():draw(true)
    OE.deltaTime = os.clock() - timeWas
    timeWas = os.clock()
    require("component").gpu.bitblt()
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
=======
        self._Enabled = toggle
    end}
    if compile then
        return OE.Script.Compile(object,object[name],name)
    end
    return object[name]
end
function OE.nilObject()
    local obj = {
        _ID = math.random(0,OE.huge),
        _Enabled = true,
        _Index = 1,
        _Volcab = {},
        _ScriptsOrder = {}
    }
    OE.unserializeObject(obj)
    OE.Script.shared.addScript(obj,"MAIN_Transform.lua", 'Transform')
    return obj
>>>>>>> Stashed changes
end
function OE.createEmptyScene()
    return {Object={},RenderObjects={}}
end
function OE.loadScene(SceneName, dontLaunchScripts)
    if OE.CurrentScene then
        OE.Render.clearRender()
        OE.Script.ExecutableForFrame = {}
    end
    OE.CurrentScene = OE.deepcopy(OE.Project.Scenes[SceneName]) -- В проектах экземпляр сцены, после её загрузки она меняется по скрипту не зависимо от экземпляра
    for i = 1, #OE.CurrentScene.Objects do
        OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID] = OE.deepcopy(OE.Project.Scenes[SceneName].Objects[i])
        OE.Render.addToRender(
            OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID],
            OE.CurrentScene.Objects[i].RenderType
        )
        if not dontLaunchScripts then
            OE.Script.Reload()
        end
    end
<<<<<<< Updated upstream
=======
    OE.Script.runEveryWithName('Start')
    OE.Time.sceneElapsed, OE.Time.sceneLoaded = 0, uptime()
    OE.Render.recalcAllLayers()
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
local args = {...}
if not args[1] then
    OE.initWindow()
    OE.loadScene("Empty")
end
return OE
=======
if isDebug then
    local ser = require('text').serialize
    debugHandler = fs.open(OE.root .. 'lastLog.txt', 'w')
    debugHandler:write(os.date("%X",System.getTime()) .. ' [DBG] Engine start.\n') 
    OE.log = function(...)
        local args = {...}
        debugHandler:write(os.date("%X",System.getTime()) .. ' [DBG] ')
        for i = 1, #args do
            if type(args[i]) == 'table' then
                debugHandler:write(ser(args[i],true,nil,5) .. '    ')
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
                debugHandler:write(ser(args[i],true,nil,5) .. '    ')
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
    local x ,y= x +1, y+1
    local Position, Scale
    if object and object._Name then
        local Position, Scale = object.Transform.Position, object.Transform.Scale
    else
        local inside = {}
        local objects = OE.CurrentScene.Objects
        for i = 1, #objects do
            local Position, Scale = objects[i].Transform.Position, objects[i].Transform.Scale
            inside[#inside+1] = x >= Position.x and x < Position.x + Scale.w and y >= Position.y and y < Position.y + Scale.h and objects[i] or nil
        end
        return inside
    end
    return x >= Position.x and x < Position.x + Scale.w and y >= Position.y and y < Position.y + Scale.h
end

return OE
>>>>>>> Stashed changes
