local System = require("System")
local args = {...}
local OE = args[1]
local Scripts = {ExecutableForFrame={}}

function Scripts.Execute(script,objectThatCalls)
    System.call(script.Start,objectThatCalls,OE)
    table.insert(Scripts.ExecutableForFrame,{Script = script,objectThatCalls = objectThatCalls})
end

function Scripts.loadMethod(from,what)
    return from[what]
end

local function findMethondPls(where,what,toend)
    for i,v in pairs(where) do
        if type(v) == 'table' and i:match("[^%/]+(%.[^%/]+)%/?$") == '.lua' then
            if v[what] then
                table.insert(toend,1, v[what])
            end
        elseif type(v) == 'table' and not i:match("[^%/]+(%.[^%/]+)%/?$") then
            findMethondPls(v,what,toend)
        end
    end
end

function Scripts.getMethod(what)
    local toend = {}
    findMethondPls(OE.CurrentScene.Storage,what,toend)
    findMethondPls(OE.Project.Storage,what,toend)
    if not toend[1] then
        toend[1] = function() print('There is no method founded: '..what) end
    end
    return toend
end

function Scripts.Reload()
    for i,v in pairs(Scripts.ExecutableForFrame) do
        if tonumber(i) > 0 then
            table.remove(Scripts.ExecutableForFrame,i)
        end
    end
    for i,v in pairs(OE.CurrentScene.Objects) do
        for e,w in pairs(v.Components) do
            if w.type == OE.Component.componentTypes.SCRIPT then
                Scripts.Execute(OE.Storage.getFile(w.file),v)
            end
        end
    end
end

return Scripts