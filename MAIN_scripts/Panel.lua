local drawPanel,UIObject = require('Screen').drawRectangle
color = 0xFFFFFF
local function draw(obj)
	drawPanel(obj.x,obj.y,obj.w,obj.h,color,0x0,' ')
end

function Init()
	UIObject = OE.Render.Matrix.newObject(Transform.Position.x,Transform.Position.y,Transform.Scale.w,Transform.Scale.h,draw)
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