local fs = require("Filesystem")
local Storage = {intensity = 1,isStreamingAssets=false}
local ContentPath = string.gsub(require'System'.getCurrentScript(),'Storage.lua','Content/')
local args = {...}
local OE = args[1]
local loaded = {}
local storage = OE.Project.Storage
OE.fileRoot = OE.root .. 'Additional_Content/'
if fs.exists(OE.fileRoot) then
    if fs.extension(OE.fileRoot) == '.dat' then
        Storage.isStreamingAssets = true
    else
        return false, 'No content folder founded'
    end
end

function Storage.Export(path,what)
    fs.write(path,Storage.getFile[what])
end
function Storage.Import(name, path)
    storage[name] = path
end
function Storage.loadFile(name,data)
    if data then
        loaded[name] = data
    else
        if not Storage.isStreamingAssets then
            if fs.exists(storage[name]) and fs.extension(storage[name]) == '.pic' and not data then
                loaded[name] = require('Image').load(storage[name]) or false
            else
                loaded[name] = fs.read(storage[name])
            end
        else
            print('We cant do this for now :p')
        end
    end
    return loaded[name]
end
function Storage.unloadFile(name)
    loaded[name] = nil
end
function Storage.getFile(name)
    local wasLoaded = loaded[name] and true or false
    local file = loaded[name] or Storage.loadFile(name)
    if not wasLoaded and Storage.intensity < 2 then
        Storage.unloadFile(name)
    end
    return file
end

local engineScriptsFiles = fs.list(ContentPath)

for i = 1, #engineScriptsFiles do
    Storage.Import('MAIN_'..engineScriptsFiles[i],ContentPath..engineScriptsFiles[i])
end

return Storage