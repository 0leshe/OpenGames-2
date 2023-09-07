local GUI = require("GUI")
local System = require("System")
local fs = require("FileSystem")
local wasInited
local OE = {
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
                Localization = {['Russian']={}},
                FilesPaths = {},
                Name = "Empty",
                Objects = {},
                RenderObjects = {}
            }
        }
    }
}
OE.Debug = {
    Log = function(str)
        OE.Debug.LogString = OE.Debug.LogString .. "\n" .. str
    end,
    LogString = ""
}
OE.huge = 2147483647 --int max
local function loadModule(ModuleName)
    OE[ModuleName] = loadfile(string.gsub(System.getCurrentScript(),"/Main.lua","/"..ModuleName..".lua"))(OE)
end
loadModule("Render")
loadModule("Script")
loadModule("Component")
loadModule("Localization")
loadModule("Input")
loadModule("Storage")
local function deepcopy(orig) -- For 'load scene'
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
local function removeObject(Object)
    OE.Render.removeFromRender(Object)
    for i = 1, #OE.Script.ExecutableForFrame do
        if OE.Script.ExecutableForFrame.objectThatCalls.ID == Object.ID then
            table.remove(OE.Script.ExecutableForFrame,i)
        end
    end
    table.remove(OE.CurrentScene,Object.ID)
end
local function setRenderMode(Object,Mode)
    local modes = OE.Render.renderTypes
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
    OE.Render.Window.eventHandler = function(_,We,...) -- Для всяких скриптов которые в потоке, и подобного стафа
        We.OE.lastEvent = {...}
        We.OE.tick()
        if We.OE.lastEvent[1] == 'touch' or We.OE.lastEvent[1] == 'drop' or We.OE.lastEvent[1] == 'scroll' or We.OE.lastEvent[1] == 'drag' then
            We.OE.Render.Window:focus()
        end
    end
end
function OE.exit()
    OE.Render.Workspace:remove()
end
function OE.tick()
    for i = 1, #OE.Script.ExecutableForFrame do
        System.call(OE.Script.ExecutableForFrame[i].Script.Update,OE.Script.ExecutableForFrame[i].objectThatCalls,OE)
    end
end
function OE.emptyObject()
    return {Transform = {Position = {x = 0, y = 0}, Scale = {Width = 0, Height = 0}},
    ID = math.random(0,OE.huge),
    addToRender = OE.Render.addToRender,
    getComponent = OE.Component.getComponent,
    getComponentID = OE.Component.getComponentID,
    downRenderOrder = OE.Render.downRenderOrder,
    upRenderOrder = OE.Render.upRenderOrder,
    toTopRenderOrder = OE.Render.toTopRenderOrder,
    setRenderMode = setRenderMode,
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
    OE.CurrentScene = deepcopy(OE.Project.Scenes[SceneName]) -- В проектах экземпляр сцены, после её загрузки она меняется по скрипту не зависимо от экземпляра
    for i = 1, #OE.CurrentScene.Objects do
        OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID] = deepcopy(OE.Project.Scenes[SceneName].Objects[i])
        OE.Render.addToRender(
            OE.CurrentScene.Objects[OE.CurrentScene.Objects[i].ID],
            OE.CurrentScene.Objects[i].RenderType
        )
        if not dontLaunchScripts then
            OE.Script.Reload()
        end
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
OE.initWindow()
OE.loadScene("Empty")
return OE