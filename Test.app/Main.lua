local OE = loadfile("/OpenGames 2/Main.lua")()
OE.createScene('Dev')
local sky = OE.createObject('Skybox','Dev')
local obj = OE.createObject('obj','Dev')
local obj1 = OE.createObject('obj1','Dev')
OE.Storage.Import('Test.pic','/Icons/HDD.pic')
OE.Storage.loadFile('Test.lua',[[
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
local objects = {}
function onKeyDown(key)
    if key == OE.Input.keyCodes.SPACE then
        Object.Render.setColor(math.random(0,0xFFFFFF))
    elseif key == OE.Input.keyCodes.CONTROL_LEFT then
        table.insert(objects,OE.createObject(tostring(math.random(0,100))))
        objects[#objects]:_addScript('MAIN_Text.lua',"Render",true)
        objects[#objects].Render.setText(tostring(math.random(0,100)))
        objects[#objects].Transform.Position.x = 50
        objects[#objects].Transform.Position.y = 30
    elseif key == OE.Input.keyCodes.SHIFT_LEFT and #objects > 0 then
        objects[#objects]:_Remove()
        print(objects,#objects)
    end
end
function Start()
    Transform.Position.y = 25
    Transform.Position.x = 78
end
]])
OE.Storage.loadFile('Test2.lua',[[
function onTouch(x,y,button)
    OE.log(Transform.Position.x,Transform.Position.y,'1')
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
    OE.log(Transform.Position.x,Transform.Position.y,'2')
end
function onDrag(x,y,button)
    if button == Object._Index-2 then
        Transform.Position.y = y
        Transform.Position.x = x
    end
end
function onKeyDown(key)
    if key == OE.Input.keyCodes.SPACE then
     --   Object.Render.setColor(math.random(0,0xFFFFFF))
    end
end]])

sky:_addScript('MAIN_Panel.lua',"Render")
sky.Render.color = 0x989898
sky.Transform.Scale = {}
sky.Transform.Scale.w = 160
sky.Transform.Scale.h = 50

obj:_addScript('MAIN_Text.lua',"Render")
obj:_addScript('Test.lua',"TestScript")
obj.Render.text = '1234'

obj1:_addScript('Test2.lua','TestScript')
obj1:_addScript('MAIN_Sprite.lua','Render')
--[[obj1.Render.color = 0x989898
obj1.Transform.Scale = {}
obj1.Transform.Scale.w = 160
obj1.Transform.Scale.h = 50]]
obj1.Render.sourceImage = 'Test.pic'
obj1.Render.transperent = true

OE.log('Project init completed')
OE.loadScene('Dev')
OE.log('Scene loaded')
OE.initWindow()