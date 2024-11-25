local master = {objects = {},allocatedBuffer,objectsID = {}}
local nilFunction = function() end
local screenUpdate,setDrawLimit = nilFunction, nilFunction
local gpu = require('component').gpu
local queueIndex,queueBuffer = {}, {}
local objects, objectsID = master.objects, master.objectsID
local args = {...}
local currentRender = "perObject"
local timerFPS = os.clock()
local fpsTotal, fps = 0, 0
local debugInfo = {0,0,0,0,'nil'}
if args[2] then
  master.allocatedBuffer = gpu.allocateBuffer()
  gpu.setActiveBuffer(master.allocatedBuffer)
end
if not args[3] then
    local screen = require('screen')
    setDrawLimit = screen.setDrawLimit
    screenUpdate = screen.update
end
local debug = args[4]
local function colide(a,b)
    local x,y = a.x,a.y
    local x1,y1 = b.x,b.y
    return x1 <= x+a.w-1 and x1+b.w-1 >= x and y1 <= y+a.h-1 and y1+b.h-1 >= y
end
local function deepcopy(orig)
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
local function colidesWith(object)
    local colides = {}
    for i = 1,object.index-1 do
        if colide(objects[i], object) then
            table.insert(colides,objects[i])
        end
    end
    for i = object.index+1,#objects do
        if colide(objects[i], object) then
            table.insert(colides,objects[i])
        end
    end
    debugInfo[2] = debugInfo[2] + 1
    return colides
end
local renderProcesses = {
    perObject = function()
      local objectsTime = 0
      for i = 1, #objects do
        local v = objects[i]
        if v.changed then
            local time = os.clock()
            local bObj = queueBuffer[v.id]
            setDrawLimit(bObj.x,bObj.y,bObj.x+bObj.w-1,bObj.y+bObj.h-1)
            local colidesB = colidesWith(bObj)
            for i = 1, #colidesB do
                local obj = colidesB[i]
                if not queueIndex[obj.id] then
                    obj.draw(obj)
                    debugInfo[1] = debugInfo[1] + 1
                end
            end
            screenUpdate()
            setDrawLimit(v.x,v.y,v.x+v.w-1,v.y+v.h-1)
            v.draw(v)
            debugInfo[1] = debugInfo[1] + 1
            local colides = colidesWith(v)
            bObj.x = v.x
            bObj.y = v.y
            bObj.h = v.h
            bObj.w = v.w
            bObj.index = v.index
            for i = 1, #colides do
                local obj = colides[i]
                if  not queueIndex[obj.id] and v.index < obj.index then
                    obj.draw(obj)
                    debugInfo[1] = debugInfo[1] + 1
                    debugInfo[4] = obj.index
                end
            end
            screenUpdate()
            v.changed = false
            objectsTime = objectsTime + os.clock()-time
        end
      end
      debugInfo[3] = objectsTime/debugInfo[1]
    end,
    nothing = function() end,
    default = function()
        setDrawLimit(1,1,160,50)
        local objectsTime = 0
        for i = 1, #objects do
            local time = os.clock()
            objects[i].draw(objects[i])
            objectsTime = objectsTime + os.clock()-time
        end
        debugInfo[1] = #objects
        debugInfo[3] = objectsTime/#objects
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
function master.addQueue(obj)
  queueIndex[obj.id] = true
  obj.changed = true
end
local addQueue = master.addQueue
local function set(x,y,symbol)
    gpu.setForeground(0xffffff)
    local getResult = {gpu.get(x,y)}
    gpu.setBackground(getResult[3])
    gpu.set(x,y,symbol..'           ')
end
function master.process(forceFullFrame)
   if debug then
      set(1,6,'Custom '..debugInfo[5])
      if timerFPS < os.clock() then
        timerFPS = os.clock() + 1
         fpsTotal = fps
         fps = 0
        set(1,1,'FPS '..tostring(fpsTotal))
        set(1,2,'Objects drawn '..tostring(debugInfo[1]))
        set(1,3,'Avg time per object '..tostring(debugInfo[3]*100000)..'ms')
        set(1,4,'Last drawn '..tostring(debugInfo[4]))
        set(1,5,'Colides called '..tostring(debugInfo[2]))
        debugInfo = {0,0,0,debugInfo[4],debugInfo[5]}
      end
  end
  if forceFullFrame then
    setDrawLimit(1,1,160,50)
    screenUpdate()
  renderProcesses['default']()
else
  renderProcesses[currentRender]()
  end
  fps = fps + 1
  queueIndex = {}
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
    local object = {x=x,y=y,w=w,h=h,colides={},draw=draw,id=math.random(0,9999999),
    setIndex = function(me,newIndex) 
        local tmp = objects[newIndex]
        objects[newIndex] = objects[me.index]
        objects[me.index] = tmp
        me.index = newIndex
    end,
    remove = function(me) 
        objectsID[me.id] = nil
        table.remove(objects,me.index)
        queueBuffer[me.id] = nil
        me = nil
        master.process(true)
    end}
   local object = addObject(setmetatable({},{
        __newindex = function(self,k,v)
            if transformRelated[k] then
                object[k] = math.max(1,math.ceil(v))
                addQueue(object)
            else 
                object[k] = v
            end
        end, 
        __index = object}
    ))
    queueBuffer[object.id] = {x = object.x,y = object.y,h = object.h,w = object.w,index = object.index}
   addQueue(object)
   return object
end


return master