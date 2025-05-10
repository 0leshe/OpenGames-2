local drawPanel, UIObject = require('Screen').drawRectangle
color = 0xFFFFFF
local function draw(obj)
	drawPanel(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),color,0x0,' ')
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function onObjectResize(w,h) --Transform script
  UIObject.w = w
  UIObject.h = h
end

function onObjectRemove()
	UIObject:remove()
end

function Init()
	
end

onObjectEnable = Init
onObjectDisable = onObjectRemove