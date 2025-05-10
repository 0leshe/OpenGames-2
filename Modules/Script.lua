local System = require("System")
local args = {...}
local OE = args[1]
local sharedToken = {'1234',1234,math.random(1,1000)}
local shared = {}
local Scripts, k, i, v = {toInvoke = {}, shared = shared, volcab={}}

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
      local v = sharedNames[k] and shared[k] or privateNamesVars[k] and privateVars[k] or (privateNames[k] or vars[k] ~= nil) and vars[k] or globalEnv[k]
      if OE.loglevel == 1 then OE.log('get.',k, scriptObj._Name,scriptObj._SourceFile) end
      return v
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
      if OE.loglevel == 1 then OE.log('set.',k,v, scriptObj._Name,scriptObj._SourceFile) end
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
              if not Scripts.volcab[k] then Scripts.volcab[k]={} end
              if not object._Volcab[k] then object._Volcab[k]={} end
              for i = 1, #object._Volcab[k] do
                if object._Volcab[k][i][6] == vars then
                  OE.log('rewritedInValcab.',k,v,scriptObj._Name,scriptObj._SourceFile,object._Name)
                  Scripts.volcab[k][object._Volcab[k][i][5]][2] = v
                  object._Volcab[k][i][2] = v
                  return
                end
              end
              OE.log('addedToValcab.',k,v,scriptObj._Name,scriptObj._SourceFile,object._Name)
              table.insert(Scripts.volcab[k], {object,v,scriptObj,k,#object._Volcab[k]+1,vars})
              table.insert(object._Volcab[k], {object,v,scriptObj,k,#Scripts.volcab[k],vars})
            elseif Scripts.volcab[k] then
              OE.log('tryToRemoveFromValcab.',k,v,scriptObj._Name,scriptObj._SourceFile,object._Name)
              for i = 1, #Scripts.volcab[k] do
                if Scripts.volcab[k][i] and Scripts.volcab[k][i][1] == object then
                  OE.log('removedFromValcab.',k,v,scriptObj._Name,scriptObj._SourceFile,object._Name)
                  table.remove(object._Volcab[k], Scripts.volcab[k][i][5])
                  table.remove(Scripts.volcab[k], i)
                end
              end
            end
          end
        end
    end,
  }
  OE.log('compilation start.',scriptObj._Name,scriptObj._SourceFile)
  result, reason = pcall(load(code, scriptObj._SourceFile, "t", setmetatable({}, envMeta)))
  if result then
      OE.log('compilation end.',scriptObj._Name,scriptObj._SourceFile)
      return vars, true
  else
      OE.errlog('COMPILATION FAILED.',scriptObj._Name,scriptObj._SourceFile,reason)
      return vars, false
  end
end
local function callNameForObject(object,name,mode, ...)
  if object and object._Enabled and object._ID and object._Volcab[name] then
    for i = 1, #object._Volcab[name] do
        script = object._Volcab[name][i][3]
        if script._Enabled then
          v = object._Volcab[name][i][1]
          k = object._Volcab[name][i][4]
          i = object._Volcab[name][i][2]
          if OE.loglevel == 1 then OE.log('calling '..mode..' for.',script._Name,script._SourceFile,object._Name,v._Name,k,i) end
          i(...)
        end
    end
    return true
  else
    return false
  end
end

function Scripts.runEveryWithName(name,object,...)
    if name ~= 'Update' and OE.loglevel == 1 then OE.log('runEveryWithName.',name, object and object._Name or (object and not object._Name and object ~= {} and '_Grouped') or '_WithoutFilter','args:',...) end
    local result = callNameForObject(object,name,'exactly',...)
    if result or object and  object._Name then
      return
    elseif object then
      local someonePLEASE = false
      for i = 1, #object do
        callNameForObject(object[i],name,'grouped',...)
        someonePLEASE = true
      end
      if someonePLEASE then return end
    end
    if Scripts.volcab[name] then
        for i = 1, #Scripts.volcab[name] do
            script = Scripts.volcab[name][i][3]
            v = Scripts.volcab[name][i][1]
            if v and script and v._Enabled and script._Enabled then
              k = Scripts.volcab[name][i][4]
              i = Scripts.volcab[name][i][2]
              if OE.loglevel == 1 then OE.log('calling overall for.',script._Name,script._SourceFile,v._Name,k,i) end
              i(...)
            end
        end
    end
end
local function Patern(script,patern)
    OE.log('paterning.',script,patern)
    for i, v in pairs(patern) do
        if type(v) == 'table' then
            Patern(script[i],patern[i])
        else
            OE.log('paternValuing.',script[i],v)
            script[i] = v
        end
    end
end

local requireCache = {}
local function scriptRequire(name)
  if not requireCache[name] then
      requireCache[name] = require(name)
  end
  return requireCache[name]
end

function Scripts.Invoke(func, time)
    time = time + OE.Time.time
    if not Scripts.toInvoke[time] then Scripts.toInvoke[time] = {} end
    table.insert(Scripts.toInvoke[time], func)
end

function Scripts.Compile(object, scriptObj, scriptName)
    local script, success = runScript(OE.Storage.getFile(scriptObj._SourceFile), {script = object[scriptName], require = scriptRequire, Transform = object.Transform, Object = object, OE = OE, Debug = OE.Debug, CurrentScene = OE.CurrentScene, Input = OE.Input, Time = OE.Time}, object, scriptObj)
    Patern(script,scriptObj)
    object[scriptName] = script
    OE.log(object)
    return script, script.Init and script.Init()
end

return Scripts

