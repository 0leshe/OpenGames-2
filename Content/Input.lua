local drawText,drawPanel,focused,UIObject = require('Screen').drawText,require('Screen').drawRectangle, false
local function draw(obj)
	drawPanel(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),color,0x0,' ')
	drawText(math.ceil(Transform.Position.x)+math.ceil(Transform.Position.w/2),math.ceil(Transform.Position.y)+math.ceil(Transform.Position.h/2),colors,text)
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

function onTouch(button,x,y)
	if button == 1 and x>=Transform.Position.x and x < Transform.Position.x + Transform.Position.w and not focused and y>=Transform.Position.y and y < Transform.Position.y + Transform.Position.h then
		focused = true
		OE.Input.focusObject = Object
	end
end

function onKeyDown(key)
	
end

function Init()
	UIObject = OE.Render.Matrix.newObject(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),draw)
end