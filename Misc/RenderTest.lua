local GUI = require('GUI')
local wk = GUI.workspace()
local screen = require('screen')
local image = require('image')
local gpu = require('component').gpu
local queue = {}
local queueBuffer = {}
local notParsedQueue = {}
local queueIndex = {}
local allocatedBuffer = gpu.allocateBuffer()
--gpu.setActiveBuffer(allocatedBuffer)
local objects = {}
local function addQueue(args)
	if not queueIndex[args.obj.id] then
		queueIndex[args.obj.id] = true
	else
		return false, 'Object already in queue'
	end
	table.insert(queue, {obj=args.obj,mode=args.mode})
end
function deepcopy(orig) -- For 'load scene'
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
local function colide(x,y,w,h,x1,y1,w1,h1)
	return 
		x + w > x1 and
		y + h > y and
		x < x1 + w1 and
		y < y1 + h1
end
local function process(forceFullFrame)
	screen.setDrawLimit(1,1,1,1)
	for _,v in pairs(queue) do
		if v.mode == 'new' then
			screen.setDrawLimit(v.obj.x-1,v.obj.y-1,v.obj.x+v.obj.w,v.obj.y+v.obj.h)
			v.obj.draw(v.obj)
			queueBuffer[v.obj.id] = deepcopy(v.obj)
			screen.update()
		elseif v.mode == "renew" then
			bObj = queueBuffer[v.obj.id]
			screen.setDrawLimit(bObj.x,bObj.y,bObj.x+bObj.w,bObj.y+bObj.h-1)
			local startFrom = math.huge
			for i, w in ipairs(objects) do
				if w.id ~= v.obj.id then
					if colide(w.x, w.y, w.w, w.h, bObj.x, bObj.y, bObj.w, bObj.h) then
						w.draw(w)
					end
				else
					startFrom = i
				end
			end
			screen.update()
			screen.setDrawLimit(v.obj.x,v.obj.y,v.obj.x+v.obj.w,v.obj.y+v.obj.h-1)
			v.obj.draw(v.obj)
			for e,w in ipairs(objects) do
				if e > startFrom then
					if colide(w.x, w.y, w.w, w.h, v.obj.x,v.obj.y,v.obj.w,v.obj.h) then
						w.draw(w)
					end
				end
			end
			screen.update()
			queueBuffer[v.obj.id] = deepcopy(v.obj)
		end
	end
	queueIndex = {}
	queue = {}
	if forceFullFrame then
		screen.setDrawLimit(1,1,160,50)
		screen.update()
	end
	return gpu.bitblt()
end
local function drawImage(obj)
	return screen.drawImage(obj.x,obj.y,obj.file)
end
local function drawPanel(obj)
	return screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,obj.file,0x0, ' ')
end
local function addObject(x,y,w,h,file,draw)
	local obj = {x=x,y=y,w=w,h=h,file=file,draw=draw,id=math.random(0,9999999)}
	addQueue({mode="new",obj=obj})
	return obj
end
table.insert(objects, addObject(1,1,160,50,0x505050,drawPanel))
table.insert(objects, addObject(78,23,8,4,image.load('/Icons/Application.pic'),drawImage))
table.insert(objects, addObject(2,5,8,4,image.load('/Icons/Floppy.pic'),drawImage))
table.insert(objects, addObject(60,23,8,4,image.load('/Icons/HDD.pic'),drawImage))
process()
wk.eventHandler = function(_,_,...)
	local args = {...}
	if args[1] == 'touch' or args[1] == 'drag' then
		objects[3].y = math.ceil(args[4])
		objects[3].x = math.ceil(args[3])
		addQueue({mode='renew',obj=objects[3]})
	end
	objects[4].x = objects[4].x + 1
	if objects[4].x > 160 then
		objects[4].x = 1
	end
	--addQueue({mode='renew',obj=objects[4]})
	process()
end
wk:start(0)