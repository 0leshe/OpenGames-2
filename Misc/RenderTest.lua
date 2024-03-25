local master = {zonesRender = {zones = {}},objects = {},objectsID = {}}
local nilFunction = function() end
local screenUpdate = nilFunction
local setDrawLimit = nilFunction
local gpu = require('component').gpu
local queue = {}
local queueIndex = {}
local queueBuffer = {}
local objects, objectsID = master.objects, master.objectsID
local args = {...}
local allocatedBuffer
local currentRender = "perObject"
if args[2] then
  allocatedBuffer = gpu.allocateBuffer()
  gpu.setActiveBuffer(allocatedBuffer)
end
if not args[3] then
    local screen = require('screen')
    setDrawLimit = screen.setDrawLimit
    screenUpdate = screen.update()
end
local renderProcesses = {
    perObject = function()
      for _,v in ipairs(queue) do
          local bObj = queueBuffer[v.id]
          setDrawLimit(bObj.x,bObj.y,bObj.x+bObj.w-1,bObj.y+bObj.h-1)
          for i = 1, #bObj.colides do
             local obj = objectsID[bObj.colides[i]]
             obj.draw(obj)
          end
          queueBuffer[v.id] = deepcopy(v)
          screenUpdate()
          setDrawLimit(v.x,v.y,v.x+v.w-1,v.y+v.h-1)
          v.draw(v)
          for i = 1, #v.colides do
            local obj = objectsID[v.colides[i]]
            if obj.index > v.index then
                obj.draw(obj)
            end
          end
          screenUpdate()
      end
    end,
    nothing = function() end,
    default = function()
        setDrawLimit(1,1,160,50)
        for i = 1, #objects do
            objects[i].draw(objects[i])
        end
        screenUpdate()
    end
}
function master.changeRender(mode)
    if renderProcesses[mode] then
        currentRender = mode
    else
        return false, 'This render does not exist'
    end
end
master.changeRender(args[1])
local function colide(a,b)
    local x,y = a.x,a.y
    local x1,y1 = b.x,b.y
    return x1 <= x+a.w and x1+b.w >= x and y1 <= y+a.h and y1+b.h >= y
end
local zonesRender = master.zonesRender
function zonesRender.addZone(zone) 
    local index = #zonesRender.zones+1
    table.insert(zonesRender.zones,{index = index,x=zone.x,y=zone.y,w=zone.w+zone.x-1,h=zone.h+zone.y-1})
end
function zonesRender.removeZone(index)
    table.remove(zonesRender.zones,index)
end
function master.addQueue(obj)
  if not queueIndex[obj.id] then
    queueIndex[obj.id] = true
  else
    return false, 'Object already in queue'
  end
  table.insert(queue, obj)
end
local addQueue = master.addQueue
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
function master.process(forceFullFrame)
  renderProcesses[currentRender]()
  if forceFullFrame then
    setDrawLimit(1,1,160,50)
    screenUpdate()
  end
  queue,queueIndex = {},{}
  if args[2] then
    gpu.bitblt()
  end
end
local function addObject(obj)
    objects[#objects+1] = obj
    objectsID[obj.id] = obj
    obj.index = #objects
    return obj
end
local transformRelated = {x=0,y=0,w=0,h=0}
function master.newObject(x,y,w,h,draw)
  local object = {x=x,y=y,w=w,h=h,colides={},draw=draw,id=math.random(0,9999999),remove = function() 
        object = nil
    end}
   local object = addObject(setmetatable({},{
        __newindex = function(self,k,v)
            if transformRelated[k] then
                object[k] = math.max(0,v)
                object.colides = {}
                for i = 1,object.index-1 do
                    if colide(objects[i], object) then
                        table.insert(object.colides,objects[i].id)
                    end
                end
                for i = object.index+1,#objects do
                    if colide(objects[i], object) then
                         table.insert(object.colides,objects[i].id)
                     end
                end
                addQueue(object)
            else 
                object[k] = v
            end
        end, 
        __index = function(self,k) 
            return object[k]
        end}
    ))
    object.colides = {}
    for i = 1,object.index-1 do
        local w = objects[i]
        if colide(w, object) then
            table.insert(object.colides,w.id)
        end
    end
    for i = object.index+1,#objects do
        local w = objects[i]
        if colide(w, object) then
            table.insert(object.colides,w.id)
        end
    end
   queueBuffer[object.id] = deepcopy(object)
   addQueue(object)
end

return master