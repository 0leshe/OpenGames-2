local nilFunction = function()
end
local master = {setDrawLimit = nilFunction, objects = {}, x = 0, y = 0, w = 160, h = 50}
local screenUpdate = nilFunction
local gpu = require("component").gpu
local uptime = require('computer').uptime
local objects = master.objects
local args = {...}
local currentRender = "perObject"
local timerFPS = os.clock()
local fpsTotal, absoluteTotal, fps = 0, 0, 0
local debugInfo = {0, 0, 0, 0, "nil"}
if not args[3] then
    local screen = require("screen")
    master.setDrawLimit = screen.setDrawLimit
    screenUpdate = screen.update
end

local debug = args[4]
local function colide(a, b)
    local x, y = a.x, a.y
    local x1, y1 = b.x, b.y
    return x1 <= x + a.w - 1 and x1 + b.w - 1 >= x and y1 <= y + a.h - 1 and y1 + b.h - 1 >= y
end
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
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
    object.colides = {} -- Calc new
    for i = 1, object.index - 1 do
        if colide(objects[i], object) then
            table.insert(object.colides, objects[i])
        end
    end
    for i = object.index + 1, #objects do
        if colide(objects[i], object) then
            table.insert(object.colides, objects[i])
        end
    end
    local toremove = {} -- Compare to old
    for i = 1, #object.bObj.colides do
        if not object.colides[i] then
            table.insert(toremove, i)
        end
    end
    for i = 1, #toremove do
        table.remove(object.bObj.colides, toremove[i]-i+1)
    end
    if debug then debugInfo[2] = debugInfo[2] + 1 end
end
local function drawFrom(index, object)
    for i = 1, #object.colides do
        if object.colides[i].index >= index and not object.colides[i].changed then
            object.colides[i]:draw()
            if debug then debugInfo[1] = debugInfo[1] + 1 end
        end
    end
end
local renderProcesses = {
    perObject = function()
        local objectsTime = 0
        for i, v in pairs(objects) do
            if v.changed then
                local time = os.clock()
                local bObj = v.bObj
                master.setDrawLimit(bObj.x, bObj.y, bObj.x + bObj.w - 1, bObj.y + bObj.h - 1)
                drawFrom(1, bObj)
                screenUpdate()
                master.setDrawLimit(v.rawx, v.rawy, v.rawx + v.w - 1, v.rawy + v.h - 1)
                v:draw()
                colidesWith(v)
                v:updateBuffer()
                if debug then debugInfo[1] = debugInfo[1] + 1 end
                drawFrom(v.index+1, v)
                screenUpdate()
                objectsTime = objectsTime + os.clock() - time
                v.changed = false
            end
        end
        debugInfo[3] = objectsTime / debugInfo[1]
    end,
    nothing = nilFunction,
    default = function()
        setFullDrawLimit()
        local objectsTime = 0
        for i = 1, #objects do
            local time = os.clock()
            objects[i].draw(objects[i])
            objectsTime = objectsTime + os.clock() - time
        end
        debugInfo[1] = #objects
        debugInfo[3] = objectsTime / #objects
        screenUpdate()
    end
}
function setFullDrawLimit()
    master.setDrawLimit(master.x + 1, master.y + 1, master.w, master.h)
end
function master.changeRender(mode)
    if renderProcesses[mode] then
        currentRender = mode
    else
        return false, "This render does not exist"
    end
    return true
end
master.changeRender(args[1])
local function set(x, y, symbol)
    gpu.setForeground(0xffffff)
    local tmp = {gpu.get(x, y)}
    gpu.setBackground(tmp[3])
    gpu.set(x, y, symbol .. "           ")
end
local avgtimewas = 0
function master.process()
    renderProcesses[currentRender]()
    if debug then
        fps = fps + 1
        absoluteTotal = absoluteTotal + 1
        set(1, 6, "Custom " .. debugInfo[4])
        set(1, 1, "FPS " .. tostring(fpsTotal))
        set(1, 2, "CurrentFrame " .. tostring(fps) .. "/" .. absoluteTotal)
        if timerFPS < uptime() then
            timerFPS = uptime() + 1
            fpsTotal = fps
            fps = 0
            set(1, 3, "Objects drawn " .. tostring(debugInfo[1]))
            if avgtimewas ~= debugInfo[3] then
                set(1, 4, "Avg time per object " .. tostring(debugInfo[3] * 100000) .. "ms")
                avgtimewas = debugInfo[3]
            end
            set(1, 5, "Colides called " .. tostring(debugInfo[2]))
            debugInfo = {0, 0, debugInfo[3], debugInfo[4]}
        end
    end
end
local objectRemove = function(me)
    table.remove(objects, me.index)
    drawFrom(1,me)
    me = nil
end
function master.windowChanged()
    for i = 1, #objects do
        objects[i].x = objects[i].x
        objects[i].y = objects[i].y
    end
end
local objectSetIndex = function(me, newIndex)
    local tmp = objects[newIndex]
    objects[newIndex] = me
    objects[me.index] = tmp
    me.index = newIndex
end
local function updateBuffer(object)
    object.bObj.x = object.rawx
    object.bObj.y = object.rawy
    object.bObj.w = object.w
    object.bObj.h = object.h
    object.bObj.index = object.index
    object.bObj.colides = object.colides
end
local transformRelated = {x = true, y = true}
local scaleRelated = {w = true, h = true}
local raws = {rawx=true,rawy=true}
function master.newObject(x, y, w, h, draw)
    local object = {
        x = x,
        y = y,
        w = w,
        h = h,
        bObj = {colides={}},
        updateBuffer = updateBuffer,
        draw = draw,
        id = math.random(0, 9999999),
        setIndex = objectSetIndex,
        remove = objectRemove
    }
    local RAW = {x=x,y=y}
    local obj =
        setmetatable(
        {},
        {
            __newindex = function(self, k, v)
                if transformRelated[k] then
                    object[k] = math.ceil(v)
                    RAW[k] = object[k] + master[k]
                elseif scaleRelated[k] then
                    object[k] = math.ceil(v)
                else
                    object[k] = v
                end
            end,
            __index = function(self, k)
                if raws[k] then
                    return RAW[k:gsub('raw','')]
                else
                    return object[k]
                end
            end
        }
    )
    objects[#objects + 1] = obj
    obj.index = #objects
    obj.changed = true
    colidesWith(obj)
    obj:updateBuffer()
    return obj
end

return master