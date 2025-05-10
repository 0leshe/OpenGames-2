<<<<<<< Updated upstream
local OE = {}
local function loadModule()
  OE = loadfile("/OpenGames 2/Main.lua")()
=======
local scriptPath = string.gsub(require('System').getCurrentScript(),'/Test.app','')
local args = {...}
_, args = require('System').parseArguments(table.unpack(args))
local OE, why = assert(loadfile(scriptPath))()
if not OE then return end
OE.createScene('Dev')
local sky = OE.createObject('Skybox','Dev')
local obj = OE.createObject('obj','Dev')
local obj1 = OE.createObject('obj1','Dev')
local obj2 = OE.createObject('obj2','Dev')
OE.Storage.Import('Test.pic','/Icons/HDD.pic')
OE.Storage.loadFile('Test.lua',[[
function onTouch(x,y,button)
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
>>>>>>> Stashed changes
end
loadModule()
local function start()
end
<<<<<<< Updated upstream
OE.Storage.createFile(OE.CurrentScene.Storage,'Test.pic',require("Image").load('/Icons/HDD.pic'))
OE.Project.Window.Color = 0x202020
OE.Project.Window.Width = 160
OE.Project.Window.Height = 50
OE.Project.Window.Title = "Test Window"
=======
local objects = {}
function KeyDown(key)
    if key == OE.Input.keyCodes.SPACE then
        Object.Render.setColor(math.random(0,0xFFFFFF))
    elseif key == OE.Input.keyCodes.CONTROL_LEFT then
        table.insert(objects,OE.createObject(tostring(math.random(0,100))))
        objects[#objects]:_addScript('MAIN_Text.lua',"Render",true)
        objects[#objects].Render.setText(tostring(math.random(0,100)))
        objects[#objects].Transform.Position.x = math.random(1,140)
        objects[#objects].Transform.Scale.w = unicode.len(objects[#objects].Render.text)
        objects[#objects].Transform.Position.y = math.random(1,50)
    elseif key == OE.Input.keyCodes.SHIFT_LEFT and #objects > 0 then
        objects[#objects]:_Remove()
        objects[#objects] = nil
    end
end
function Update()
    Object.Render.setColor(math.random(0,0xFFFFFF))
    Object.Render.setText(tostring(math.random(0,0xFFFFFF)))
    Transform.Scale.w = unicode.len(Object.Render.text)
    for i = 1, #objects do
        objects[i].Render.color = math.random(0,0xFFFFFF)
        objects[i].Render.setText(tostring(math.random(0,0xFFFFFF)))
        objects[i].Transform.Scale.w = unicode.len(objects[#objects].Render.text)
        objects[i].Transform.Position.y = math.random(1,50)
        objects[i].Transform.Position.x = math.random(1,140)
    end
end
function Start()
    Transform.Position.y = 25
    Transform.Position.x = 78
end
]])
OE.Storage.loadFile('Test2.lua',[[
function onTouch(x,y,button)
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
end
function onDrag(x,y,button)
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
end
function KeyDown(key)
    if key == OE.Input.keyCodes.SPACE then
     --   Object.Render.setColor(math.random(0,0xFFFFFF))
    end
end
]])
OE.Storage.loadFile('Test3.lua',[[
function onTouch(x,y,button)
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
end
function onDrag(x,y,button)
    if button == 2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
end
]])

sky:_addScript('MAIN_Panel.lua',"Render")
sky.Render.color = 0x989898
sky.Transform.Scale = {}
sky.Transform.Scale.w = 160
sky.Transform.Scale.h = 50

obj:_addScript('MAIN_Text.lua',"Render")
obj:_addScript('Test.lua',"TestScript")
obj.Render.text = '1234'
obj.Transform.Scale = {w=4}

obj2:_addScript('MAIN_Panel.lua',"Panel")
obj2:_addScript('MAIN_Text.lua',"Text")
obj2:_addScript('MAIN_Button.lua', 'Button')
obj2:_addScript('Test3.lua',"TestScript")
obj2.Button.textScript = 'Text'
obj2.Button.panelScript = 'Panel'
obj2.Transform.Scale = {h = 3,w = 20}
obj2.Transform.Position = {x = 20,y = 10}
obj2.Text.text = "КНОПКА! ☺"
obj2.Text.color = 0x0
obj2.Text.horizontal = 2
obj2.Text.vertical = 2
obj2.Button.onClick = function()
    OE.CurrentScene.Objects[4].Text.setText("math.random: " .. tostring(math.random(0,100)))
    OE.CurrentScene.Objects[4].Transform.Scale.w = unicode.len(OE.CurrentScene.Objects[4].Text.text) + 4
end
obj1:_addScript('Test2.lua','TestScript')
obj1:_addScript('MAIN_Sprite.lua','Render')
obj1.Render.sourceImage = 'Test.pic'
obj1.Render.transperent = true
--[[obj1.Render.color = 0x989898
obj1.Transform.Scale = {}
obj1.Transform.Scale.w = 160
obj1.Transform.Scale.h = 50]]

OE.log('Project init completed')
OE.loadScene('Dev')
OE.log('Scene loaded')
>>>>>>> Stashed changes
OE.initWindow()
local obj = OE.createObject()
obj:setRenderMode(OE.Render.renderTypes.PROGRESSINDICATOR)
obj.Active = true
local a1 = obj:addComponent(OE.Component.componentTypes.MATERIAL)
local b = obj:addComponent(OE.Component.componentTypes.TEXT)
OE.LocalNetwork.host('129.123.2.2',10,function ()
  obj.Components[b].Text.Text = OE.LocalNetwork.CurrentConnection.lastMessage[3]
end)
obj.Components[b].Text.Text = 'tet'
obj.onValueChanged = OE.Script.getMethod('button')[1]
obj.Components[a1].Color.First = 0x007755
obj.Components[a1].Color.Second = 0xFFFFFF
obj.Components[a1].Color.Third = 0x00FFFF
obj.Components[a1].Color.Fourth = 0x007755
--obj.Components[obj:addComponent(OE.Component.componentTypes.SCRIPT)].file = "Test.lua"
--obj.Components[obj:addComponent(OE.Component.componentTypes.TEXT)].Text = "test"
--obj.Components[obj:addComponent(OE.Component.componentTypes.SPRITE)].file = 'Test.pic'
obj.Transform.Scale.Width = 27
obj.Transform.Scale.Height = 3
obj.Transform.Position.x = 10
obj.Transform.Position.y = 3
local obj1 = OE.createObject()
obj1:setRenderMode(OE.Render.renderTypes.INPUT)
local a = obj1:addComponent(OE.Component.componentTypes.MATERIAL)
local b = obj1.Components[obj1:addComponent(OE.Component.componentTypes.TEXT)]
b.Text.Text = "test"
b.Text.PlaceHolder = 'PlHold'
b.Text.LocalizationPlaceHolder = 'Idk'
OE.CurrentScene.Localization['Russian']['Idk'] = 'Test????'
obj1.Components[a].Color.First = 0x007755
obj1.Components[a].Color.Second = 0xFFFFFF
obj1.Components[a].Color.Third = 0xFFFFFF
obj1.Components[a].Color.Fiveth = 0xFFFFFF
obj1.Components[a].Color.Fourth = 0x007755
obj1.Transform.Position.x = 10
obj1.Transform.Position.y = 20
obj1.Transform.Scale.Width = 20
obj1.Transform.Scale.Height = 3
obj.Components[obj:addComponent(OE.Component.componentTypes.SCRIPT)].file = "Test.lua"
local function button(Object)
  --obj.addItem(b.Text.Text,OE.Script.getMethod('choosedItem')[1])
  --obj.updateItems()
  obj.Roll()
  print('You change me!:3')
  if b.Text.Text == 'new' then
    obj:addToRender()
  elseif b.Text.Text == 'remove' then
    obj:removeFromRender()
  end
  obj.Components[a1].Color.First = math.random(0x0,0xFFFFFF)
  obj.Components[a1].Color.Second = math.random(0x0,0xFFFFFF)
  obj.Components[a1].Color.Third = math.random(0x0,0xFFFFFF)
  obj.Components[a1].Color.Fiveth = math.random(0x0,0xFFFFFF)
  obj.Components[a1].Color.Fourth = math.random(0x0,0xFFFFFF)
end
local function choosedItem(Item)
  print(Item.name)
end
OE.CurrentScene.Storage.test = {}
local function update(...)
  local args = {...}
  args[1].Transform.Position.x = args[1].Transform.Position.x + 60 * args[2].deltaTime
  if  args[1].Transform.Position.x > 160 then
     args[1].Transform.Position.x = -2
  end
  obj1.Transform.Position.x = obj1.Transform.Position.x + 60 * args[2].deltaTime
  if  obj1.Transform.Position.x > 160 then
     obj1.Transform.Position.x = -20
  end
  b.Text.Text = tostring(args[2].deltaTime)
 -- if type(args[2].lastEvent[4]) == "number" then
 --  args[1].Transform.Position.x = args[2].lastEvent[3]-math.ceil(args[1].Transform.Scale.Width/2)-args[2].Render.Window.x
  --  args[1].Transform.Position.y = args[2].lastEvent[4]-math.ceil(args[1].Transform.Scale.Height/2)-args[2].Render.Window.y
 -- end
end
OE.Storage.createFile(OE.CurrentScene.Storage.test,'Test.lua',{choosedItem = choosedItem,Start=start,Update=update,button=button})
OE.Script.Reload()
--obj.addItem('Test',OE.Script.getMethod('choosedItem')[1])
--obj.addItem('Tt',OE.Script.getMethod('choosedItem')[1])
--obj.addItem('Tjj',OE.Script.getMethod('choosedItem')[1])
--obj.onValueChanged = OE.Script.getMethod('button')[1]
obj1.onInputFinished = OE.Script.getMethod('button')[1]
obj1:addToRender()
obj:addToRender()
