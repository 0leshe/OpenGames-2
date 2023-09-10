local args = {...}
local fs = require('Filesystem')
local GUI = require('GUI')
local OE = loadfile("/OpenGames 2/Main.lua")(true)
OE.Project = fs.readTable(fs.removeSlashes(args[1]..'/.Game.data'))