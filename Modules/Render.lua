local args = {...}
local fs, gpu = require('filesystem'), require('component').gpu
local Render = {layers={},DrawLibrary={}}
local layers = Render.layers
local RenderEngineAssembly = loadfile(string.gsub(require'System'.getCurrentScript(),"Render.lua","/Misc/Matrix.lua"))

function Render.clearRender()
  local objList = Render.Matrix.objects
  while #objList > 1 do
      Render.Matrix.objects[1]:remove()
  end
end

function Render.returnBuffer()
    gpu.freeAllBuffers()
    gpu.setActiveBuffer(0)
end

function Render.redraw(objects)
  local function redraw(objects)
    for i = 1, #objects._ScriptsOrder do
      if objects[objects._ScriptsOrder[i]].redraw then objects[objects._ScriptsOrder[i]].redraw() end
    end
  end
  if objects._Name then
    redraw(objects)
  else
    for i = 1, #objects do
      redraw(objects[i])
    end
  end
end

function Render.addLayer(forceBuffer)
    layers[#layers+ 1] = RenderEngineAssembly(args[2],forceBuffer and args[3],args[4],true)
    if args[4] then
        layers[#layers].setDrawLimit = Render.DrawLibrary.setDrawLimit
    end
    if args[3] and #layers > 1 then
        layers[#layers].buffers = true
        layers[#layers-1].buffers = false
        layers[#layers].allocatedBuffer = layers[#layers-1].allocatedBuffer
    end
end
local cachedrequire = {}
local publicvars = {
    require = function(name)
        if not cachedrequire[name] then
            cachedrequire[name] = require(name)
        end
        return cachedrequire[name]
    end,
    gpu = gpu,
    colorBlend = require('color').blend,
    SCREEN_HEIGHT = 50,
    SCREEN_WIDTH = 160
}

function Render.processAll()
    for i = 1, #layers do
        Render.process(i)
    end
    if args[3] then gpu.bitblt() end
end
function Render.recalcAllLayers()
    for i = 1, #layers do
        Render.recalcLayer(i)
    end
end

function Render.recalcLayer(index)
    layers[index].windowChanged()
end

function Render.process(index)
    publicvars.SCREEN_X = layers[index].x
    publicvars.SCREEN_Y = layers[index].y
    publicvars.layer = layers[index]
    layers[index].process()
end

function Render.moveLayers(old,new)
    local tmp = layers[new]
    layers[new] = layers[old]
    layers[old] = tmp
end

function Render.newObject(layer,...)
    return layers[layer].newObject(...)
end

function Render.dissolve()
    gpu.freeAllBuffers()
    gpu.setActiveBuffer(0)
end

function Render.setResolution(w,h)
    gpu.setResolution(w,h)
    gpu.freeAllBuffers()
   if args[3] then Render.allocatedBuffer = gpu.allocateBuffer(w,h)
    gpu.setActiveBuffer(Render.allocatedBuffer) end
    for i = 1, #layers do
        layers[i].w = w
        layers[i].h = h
    end
    publicvars.SCREEN_WIDTH = w
    publicvars.SCREEN_HEIGHT = h
end

local drawlibrarypath = string.gsub(require'System'.getCurrentScript(),"Render.lua","/Misc/DrawLibrary/")
function newDraw(path)
    local vars = {}
    local envMeta = {
        __index = function(self, k)
          return vars[k] or publicvars[k] or _ENV[k]
        end,

        __newindex = function(self, k, v)
            if publicvars[k] then
                publicvars[k] = v
            else
                vars[k] = v
            end
        end,
      }
      return load(fs.read(path),path,'t', setmetatable({}, envMeta))
end
local additionalFiles,why = fs.list(drawlibrarypath)
for i = 1, #additionalFiles do
    Render.DrawLibrary[string.gsub(additionalFiles[i],".lua","")], why = newDraw(drawlibrarypath .. additionalFiles[i])
end
Render.addLayer(args[3])

return Render