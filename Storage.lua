local fs = require("Filesystem")
local Storage = {intensity = 2}
local MAIN_scripts = string.gsub(require'System'.getCurrentScript(),'Storage.lua','MAIN_scripts/')
local args = {...}
local OE = args[1]
local loaded = {}
local storage = OE.Project.Storage


function Storage.createFile(name, data)
    storage[name] = data
end
function Storage.Export(path,what)
    fs.write(path,loaded[what])
end
function Storage.Import(name, path)
    storage[name] = path
end
function Storage.loadFile(name,data)
    loaded[name] = data or fs.read(storage[name])
    return loaded[name]
end
function Storage.unloadFile(name)
    loaded[name] = nil
end
function Storage.getFile(name)
    local file = loaded[name] or Storage.loadFile(name)
    if Storage.intensity < 2 then
        Storage.unloadFile(name)
    end
    return file
end

local engineScriptsFiles = fs.list(MAIN_scripts)

for i = 1, #engineScriptsFiles do
    Storage.Import('MAIN_'..engineScriptsFiles[i],MAIN_scripts..engineScriptsFiles[i])
end

return Storage