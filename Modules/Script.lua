local System = require("System")
local args = {...}
local OE = args[1]
local sharedToken = {'1234',1234,math.random(1,1000)}
local shared = {}
local Scripts = {shared = shared, volcab={},vars={}}

-- Big thanks to fingercomp bc i dont know how this shi works
local globalEnv = setmetatable({
  shared = function()
    return sharedToken
  end,
}, {__index = _ENV})
local function runScript(code, privateVars, object, script)
  local vars = {}
  local scriptObj = script
  local privateNames = {}
  local sharedNames = {}
  local privateNamesVars = {}
  privateVars = privateVars or {}
  for i, _ in pairs(privateVars) do
    privateNamesVars[i] = true
  end
  local envMeta = {
    __index = function(self, k)
      OE.log('get.',k, scriptObj._SourceFile, scriptObj._Enabled)
      return sharedNames[k] and shared[k] or privateNamesVars[k] and privateVars[k] or (privateNames[k] or vars[k] ~= nil) and vars[k] or globalEnv[k]
       --[[ Оно выше, просто сжато. На спичках, да-да
          if sharedNames[k] then 
            return shared[k]
          elseif privateNamesVars[k] then
            return privateVars[k]
          elseif
              privateNames[k]
              or vars[k] ~= nil then 
            return vars[k]
          end
          return globalEnv[k]]
    end,

    __newindex = function(self, k, v)
      OE.log('set.',k,v, scriptObj._SourceFile, scriptObj._Enabled)
      if scriptObj._Enabled then
          if rawequal(sharedToken, v) then
            sharedNames[k] = true
          elseif sharedNames[k] then
            shared[k] = v
          elseif privateNamesVars[k] then
            privateVars[k] = v
          else
            privateNames[k] = true
            vars[k] = v
            if type(v) == 'function' then
              OE.log('addedToValcab.',k,v,scriptObj._SourceFile,object._Name)
              if not Scripts.volcab[k] then Scripts.volcab[k]={} end
              table.insert(Scripts.volcab[k], {object,v,scriptObj._SourceFile,k})
            end
          end
        end
    end,
  }
  OE.log('compilation start.',scriptObj._SourceFile)
  result, reason = pcall(load(code, scriptObj._SourceFile, "t", setmetatable({}, envMeta)))
  if result then
      OE.log('compilation end.',scriptObj._SourceFile, result, vars)
      return vars, true
  else
      OE.errlog('COMPILATION FAILED.',scriptObj._SourceFile,reason, result, vars)
      return vars, false
  end
end

function Scripts.runEveryWithName(name,object,...)
    if name ~= 'Update' then OE.log('runEveryWithName.',name, object and object._Name or (object and not object._Name and object ~= {} and '_Grouped') or '_WithoutFilter','args:',...) end
    if Scripts.volcab[name] then
        for i = 1, #Scripts.volcab[name] do
            v = Scripts.volcab[name][i][1]
            k = Scripts.volcab[name][i][4]
            scriptName = Scripts.volcab[name][i][3]
            i = Scripts.volcab[name][i][2]
            OE.log('inVolcab.',i,k,scriptName,v._Name)
            if object and v._ID == object._ID then
                OE.log('calling exactly for.',scriptName,v._Name)
                i(...)
            elseif object and object[v] then
                OE.log('calling grouped for.',scriptName,v._Name)
                i(...)
            elseif not object or object and object == {} then
                OE.log('calling overall for.',scriptName,v._Name)
                i(...)
            end
        end
    end
end
local function Patern(script,patern)
    for i, v in pairs(patern) do
        if string.sub(i,1,1) ~= '_' then
            if type(v) == 'table' then
                Patern(script[i],v)
            else
                script[i] = v
            end
        end
    end
end

function Scripts.Compile(object, scriptObj, scriptName)
    local script, success = runScript(OE.Storage.getFile(scriptObj._SourceFile), {script = object[scriptName], Transform = object.Transform, Object = object, OE = OE, Debug = OE.Debug, CurrentScene = OE.CurrentScene, Input = OE.Input, Time = OE.Time}, object, scriptObj)
    Patern(script,scriptObj)
    object[scriptName] = setmetatable(object[scriptName],{__index=script,newindex=script})
   --object[scriptName] = script
    return script, script.Init and script.Init()
end

return Scripts
