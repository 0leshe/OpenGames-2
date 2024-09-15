local scriptPath = string.gsub(require('System').getCurrentScript(),'/Test.app','')
local code = require('filesystem').read(scriptPath)
local args = {...}
print(require('System').getCurrentScript(),scriptPath)
_, args = require('System').parseArguments(table.unpack(args))
local OE = load(code,scriptPath,args.loadMode or 't')()
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

OE.Script.shared.addScript(sky,'MAIN_Panel.lua',"Render")
sky.Render.color = 0x989898
sky.Transform.Scale = {}
sky.Transform.Scale.w = 160
sky.Transform.Scale.h = 50

OE.Script.shared.addScript(obj,'MAIN_Text.lua',"Render")
OE.Script.shared.addScript(obj,'Test.lua',"TestScript")
obj.Render.text = '1234'

OE.Script.shared.addScript(obj1,'Test2.lua','TestScript')
OE.Script.shared.addScript(obj1,'MAIN_Sprite.lua','Render')
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
