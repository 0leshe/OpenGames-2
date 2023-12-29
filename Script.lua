local System = require("System")
local args = {...}
local OE = args[1]
local sharedToken = {}
local shared = {}
local Scripts = {ExecutableForFrame={}}

function Scripts.Execute(script,objectThatCalls)
    if script.Start then
        System.call(script.Start)
    end
    if script.Update then
        table.insert(Scripts.ExecutableForFrame,{Script = script,objectThatCalls = objectThatCalls})
    end
    return script
end

function Scripts.loadMethod(from,what)
    return from[what]
end
-- Big thanks to fingercomp bc i dont know how is this shi works
local globalEnv = setmetatable({
  shared = function()
    return sharedToken
  end,
}, {__index = _ENV})
local function runScript(code, privateVars)
  local vars = {}
  local sharedNames = {}
  local privateNames = {}
  local privateNamesVars = {}
  privateVars = privateVars or {}
  for i, _ in pairs(privateVars) do
    privateNamesVars[i] = true
  end
  local envMeta = {
    __index = function(self, k)
      if sharedNames[k] then
        return shared[k]
      elseif privateNamesVars[k] then
        return privateVars[k]
      elseif
          privateNames[k]
          or vars[k] ~= nil then 
        return vars[k]
      end

      return globalEnv[k]
    end,

    __newindex = function(self, k, v)
      if rawequal(sharedToken, v) then
        sharedNames[k] = true
      elseif sharedNames[k] then
        shared[k] = v
      elseif privateNamesVars[k] then
        privateVars[k] = v
      else
        privateNames[k] = true
        vars[k] = v
      end
    end,
  }

  assert(load(code, "@OE_TMP_SCRIPT_EXECUTION_KYS_BTW.lua", "t", setmetatable({}, envMeta)))()

  return vars
end
-- Yeah, that all was fingercomp, lady and gentelmans! Cool guy
function Scripts.Compile(code, vars, addToExecuteForFrame)
    local vars = vars or {}
    local code = runScript(code, vars)
    if addToExecuteForFrame then
        Scripts.Execute(code)
    end
    return code
end
function Scripts.CompileScript(object, str, addToExecuteForFrame)
    return Scripts.Compile(str, {Transform = object.Transform, GameObject = object, OE = OE, Debug = OE.Debug, CurrentScene = OE.CurrentScene, Input = OE.Input, keyCodes = OE.keyCodes, Time = OE.Time}, addToExecuteForFrame)
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
        toend[1] = function() print('There is no method founded: '..what) return false end
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
            if w.type == OE.Component.componentTypes.SCRIPT and v.Enabled and w.Enabled then
                w.Script = Scripts.Execute(Scripts.CompileScript(v, OE.Storage.getFileByName(w.file)), v)
            end
        end
    end
end

return Scripts