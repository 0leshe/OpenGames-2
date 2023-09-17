local OE = {}
local function loadModule()
  OE = loadfile("/OpenGames 2/Main.lua")()
end
loadModule()
local function start()
end
local function update(...)
  --local args = {...}
 -- if type(args[2].lastEvent[4]) == "number" then
   --args[1].Transform.Position.x = args[2].lastEvent[3]-math.ceil(args[1].Transform.Scale.Width/2)-args[2].Render.Window.x
    --args[1].Transform.Position.y = args[2].lastEvent[4]-math.ceil(args[1].Transform.Scale.Height/2)-args[2].Render.Window.y
  --end
end
OE.Storage.createFile(OE.CurrentScene.Storage,'Test.pic',require("Image").load('/Icons/HDD.pic'))
OE.Project.Window.Color = 0x202020
OE.Project.Window.Width = 160
OE.Project.Window.Height = 50
OE.Project.Window.Title = "Test Window"
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
--obj.Components[obj:addComponent(OE.Component.componentTypes.SCRIPT)].file = "Test.lua"
local function button(Object)
  --obj.addItem(b.Text.Text,OE.Script.getMethod('choosedItem')[1])
  --obj.updateItems()
  obj.Roll()
  print('You change me!:3')
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
OE.Storage.createFile(OE.CurrentScene.Storage.test,'Test.lua',{choosedItem = choosedItem,Start=start,Update=update,button=button})
OE.Script.Reload()
--obj.addItem('Test',OE.Script.getMethod('choosedItem')[1])
--obj.addItem('Tt',OE.Script.getMethod('choosedItem')[1])
--obj.addItem('Tjj',OE.Script.getMethod('choosedItem')[1])
--obj.onValueChanged = OE.Script.getMethod('button')[1]
obj1.onInputFinished = OE.Script.getMethod('button')[1]
obj1:addToRender()
obj:addToRender()
