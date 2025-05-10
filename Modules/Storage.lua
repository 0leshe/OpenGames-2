local fs = require("Filesystem")
local Storage = {intensity = 3,isStreamingAssets=false}
local args = {...}
local OE = args[1]
local loaded = {}
local storage = OE.Project.Storage
OE.fileRoot = OE.applicationRoot .. 'Additional_Content/'
OE.contentPath = OE.root .. 'Content/'
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
            OE.log("Missing " .. name ..' loading..')
            if fs.exists(storage[name] or '-/') and fs.extension(storage[name]) == '.pic' and not data then
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
local engineFiles = fs.list(OE.contentPath)

for i = 1, #engineFiles do
    Storage.Import('MAIN_'..engineFiles[i],OE.contentPath..engineFiles[i])
end
function Storage.reloadAdditionalFiles(dir)
    local additionalFiles,why = fs.list(dir)
    for i = 1, #additionalFiles do
        if fs.isDirectory(dir) then
            Storage.reloadAdditionalFiles(dir .. additionalFiles[i])
        else
            Storage.Import(additionalFiles[i],dir)
        end
    end
end

return Storage