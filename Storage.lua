local fs = require("Filesystem")
local image = require("Image")
local Storage = {}
local args = {...}
local OE = args[1]

local function getFile(where,filename,canNotRecursive)
    for i,v in pairs(where) do
        if i == filename then
            return v
        end
        if type(v) == "table" and not canNotRecursive then
            local tmp = getFile(v,filename)
            if tmp then
                return tmp
            end
        end
    end
end
function Storage.getCurrentSceneStorage()
    return OE.CurrentScene.Storage
end
function Storage.getSceneStorage(name)
    return OE.Project.Scenes[name].Storage
end
function Storage.getProjectStorage()
    return OE.Project.Storage
end
function Storage.createFile(where, FileName, Data)
    where[FileName] = Data
end
function Storage.Export(path,what)
    fs.write(path,what)
end
function Storage.Import(toWhere, path)
    if fs.name(path):match("[^%/]+(%.[^%/]+)%/?$") == '.pic' then
        toWhere[fs.name(path)] = image.toString(image.load(path))
    else
        toWhere[fs.name(path)] = fs.read(path)
    end
end
function Storage.createFolder(toWhere, name)
	toWhere[name] = {}
end
function Storage.loadImage(path)
    return require("Image").fromString(path)
end
function Storage.getFileByName(FileName)
    local idk = getFile(OE.CurrentScene.Storage, FileName)
    if idk then
        return idk
    else
        return getFile(OE.Project.Storage,FileName)
    end
end
function Storage.getFile(where, name)
    getFile(where,name,true)
end

return Storage