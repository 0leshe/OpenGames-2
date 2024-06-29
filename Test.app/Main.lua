local OE = loadfile("/OpenGames 2/Main.lua")()
OE.createScene('Dev')
local sky = OE.createObject('SkyBox','Dev')
local obj = OE.createObject('Name','Dev')
local obj1 = OE.createObject('Name?','Dev')
OE.Storage.loadFile('Test.lua',[[
speed = 20

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
function Start()
    Transform.Position.y = 25
    Transform.Position.x = 78
    Transform.Scale.w = 20
    Transform.Scale.h = 10
end
]])
sky:_addScript('MAIN_Panel.lua',"Render")
sky.Render.color = 0x989898
sky._Transform.Scale = {}
sky._Transform.Scale.w = 160
sky._Transform.Scale.h = 50
obj:_addScript('MAIN_Text.lua',"Render")
obj:_addScript('Test.lua',"TestScript")
obj.Render.text = 'TEST'
obj1:_addScript('Test.lua','TestScript')
obj1:_addScript('MAIN_Panel.lua','Render')
obj1.Render.color = 0xAA00AA
OE.loadScene('Dev')
OE.initWindow()
OE.Render.Window:start(0)