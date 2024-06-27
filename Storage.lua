local fs = require("Filesystem")
local Storage = {intensity = 2}
local MAIN_scripts = string.gsub(require'System'.getCurrentScript(),'Storage.lua','MAIN_scripts/')
local args = {...}
local OE = args[1]
local loaded = setmetatable({},{__index = function(me,k) return me[k] end,
__newindex = function(me,k,v) 
    if not me[k].lock then
        me[k] = v
    end
end})
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
function Storage.loadFile(name,lock)
    loaded[name] = {file=fs.read(name), lock = not not lock}
    return loaded[name]
end
function Storage.unloadFile(name)
    loaded[name] = nil
end
function Storage.getFile(name)
    local file = loaded[name].file or loadFile(name)
    if Storage.intensity < 2 then
        Storage.unloadFile(name)
    end
    return file
end

local engineScriptsFiles = fs.list(MAIN_scripts)

for i = 1, #engineScriptsFiles do
    Storage.Import('MAIN_'..engineScriptsFiles[i],MAIN_scripts..engineScriptsFiles[i], true)
end

return Storage