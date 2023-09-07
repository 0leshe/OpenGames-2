local fs = require("Filesystem")
local Storage = {}
local args = {...}
local OE = args[1]

local function getFile(where,filename)
    for i,v in pairs(where) do
        if i == filename then
            return v
        end
        if type(v) == "table" then
            local tmp = getFile(v,filename)
            if tmp then
                return tmp
            end
        end
    end
end
function Storage.createFile(where, FileName, Data)
    where[FileName] = Data
end
function Storage.Export(path,what)
    fs.write(path,what)
end
function Storage.Import(path,toWhere)
    toWhere[fs.name(path)] = fs.read(path)
end
function Storage.getFile(FileName)
    local idk = getFile(OE.CurrentScene.Storage, FileName)
    if idk then
        return idk
    else
        return getFile(OE.Project.Storage,FileName)
    end
end

return Storage