local System = require("System")
local args = {...}
local OE = args[1]
local sharedToken = {}
local shared = {}
local Scripts = {volcab={},vars={}}

-- Big thanks to fingercomp bc i dont know how this shi works
local globalEnv = setmetatable({
  shared = function()
    return sharedToken
  end,
}, {__index = _ENV})
local function runScript(code, privateVars, object)
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
      return sharedNames[k] and shared[k] or privateNamesVars[k] and privateVars[k] or (privateNames[k] or vars[k] ~= nil) and vars[k] or globalEnv[k]
      --[[if sharedNames[k] then -- Оно выше, просто сжато. На спичках, да-да
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
          Scripts.volcab[k] = Scripts.volcab[k] or {}
          Scripts.volcab[k][v] = object
        end
      end
    end,
  }

  assert(load(code, "@OE_TMP_SCRIPT_EXECUTION.lua", "t", setmetatable({}, envMeta)))()
  return vars
end

function Scripts.runEveryWithName(name,object)
    for i, v in pairs(Scripts.volcab[name]) do
        if object then
            if v == object then
                i()
            end
        else
            i()
        end
    end
end

function Scripts.Compile(object, script, preset)
    local script = runScript(script, {Transform = object.Transform, Object = object, OE = OE, Debug = OE.Debug, CurrentScene = OE.CurrentScene, Input = OE.Input, Time = OE.Time}, object)
    for i, v in pairs(preset) do
        script[i] = v
    end
    return script
end

return Scripts
