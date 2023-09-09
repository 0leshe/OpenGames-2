local fs = require("Filesystem")
local System = require("System")
local args = {...}
local path = args[1]
local EngineFolder = System.getUserSettings().OEEngineFolder
local OE = loadfile(EngineFolder..'/Main.lua')()
OE.Project = fs.readTable(path..'/'..fs.name(path)..'_Data.dat')
OE.init()
OE.loadScene(OE.Project.FirsScene)