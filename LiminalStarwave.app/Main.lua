local scriptPath = string.gsub(require('System').getCurrentScript(),'/LiminalStarwave.app','')
local args = {...}
_, args = require('System').parseArguments(table.unpack(args))
local OE, why = assert(loadfile(scriptPath))()
if not OE then print(why) return end
OE.applicationRoot = string.gsub(require('System').getCurrentScript(),'Main.lua','')
OE.fileRoot = OE.applicationRoot .. 'Additional_Content/'
OE.createScene('Game')
OE.Render.addLayer() -- Main game
OE.Render.layers[2].y = -16
OE.Render.addLayer() -- Arrows and fly windows
OE.Render.setResolution(135,50)
local sky = OE.createObject('Skybox','Game')
sky:_addScript('MAIN_Panel.lua',"Render")
sky.Render.color = 0
sky.Transform.Scale = {w = 135, h = 50}

local BL = OE.createObject('BottomLine','Game')
BL:_addScript('MAIN_Panel.lua',"Render")
BL.Render.color = 0
BL.Render.layer = 3
BL.Transform.Scale = {w = 135, h = 3}
BL.Transform.Position = {y=48}
local UL = OE.createObject('UpperLine','Game')
UL:_addScript('MAIN_Panel.lua',"Render")
UL.Render.color = 0
UL.Render.layer = 3
UL.Transform.Scale = {w = 135, h = 3}

local BG = OE.createObject('Background','Game')
BG:_addScript('MAIN_Sprite.lua','Render')
BG.Render.sourceImage = 'Background.pic'
BG.Render.transperent = true
BG.Render.layer = 2

local ENA = OE.createObject('ENA','Game')
ENA:_addScript('MAIN_Sprite.lua','Render')
ENA.Render.sourceImage = 'ENAIdle1.pic'
ENA.Render.transperent = true
ENA.Render.layer = 2
ENA:_addScript('CharactersSpriteBehavior.lua','SpriteBehavior')
ENA:_addScript('PlayerInput.lua','PlayerInput')
--ENA:_addScript('SoundManager.lua','Audio')
ENA.Transform.Position = {y=32}

OE.Storage.reloadAdditionalFiles(OE.fileRoot)

OE.log('Project init completed')
OE.loadScene("Game")
OE.log('Scene loaded')
OE.initWindow()