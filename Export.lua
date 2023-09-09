local fs = require("Filesystem")
local args = {...}
local OE = args[2]
local path = args[1]..OE.Project.Name..'.app'
local towrite = ''
fs.makeDirectory(path)
fs.writeTable(path..OE.Project.Name.."_Data.dat",OE.Project)
fs.copy(OE.Storage.getFile(OE.Project.IconFile) or "/Icons/Sample.app",path..'/Icon.pic')

towrite = towrite .. "--Loading Engine\n--Get system lib\nlocal System = require('System')\n--Get engine folder\nlocal EngineFolder = System.getUserSettings().OEEngineFolder\n"
towrite = towrite .. "--Loading compiler\nlocal Compiler = loadfile(EngineFolder..'/Compiler.lua')\n--Execute complier on that game\nCompiler(System.getCurrentScript())"

fs.write(path..'Main.lua',towrite)
return true