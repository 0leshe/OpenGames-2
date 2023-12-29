local fs = require("Filesystem")
local System = require("System")
local args = {...}
local path = args[1]
local EngineFolder = System.getUserSettings().OpenGames2EnignePath
local OE = loadfile(EngineFolder..'/Main.lua')()
OE.Project = fs.readTable(path..'/'..fs.name(path)..'_Data.dat')
OE.init()
OE.loadScene(OE.Project.FirsScene)
