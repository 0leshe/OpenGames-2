local GUI = require("GUI")
local System = require("System")
local fs = require("FileSystem")
local wasInited
local UserData = System.getUserSettings()
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
    OE.Render.Window.eventHandler = function(_,We,...) -- Для всяких скриптов которые в потоке, и подобного стафа
        We.OE.lastEvent = {...}
        We.OE.tick()
        if We.OE.lastEvent[1] == 'touch' or We.OE.lastEvent[1] == 'drop' or We.OE.lastEvent[1] == 'scroll' then
            We.OE.Render.Window:focus()
        end
    end
end
function OE.exit()
    OE.Render.Window:remove()
end
function OE.tick()
    for i,v in  pairs(OE.Script.ExecutableForFrame) do
        if v.objectThatCalls.Enabled == true then
            System.call(v.Script.Update,v.objectThatCalls,OE)
        end
    end
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
local args = {...}
if not args[1] then
    OE.initWindow()
    OE.loadScene("Empty")
end
return OE