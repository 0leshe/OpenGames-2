local drawPanel, UIObject = OE.Render.DrawLibrary.drawRectangle
color = 0xFFFFFF
layer = 1
transparency = false
local function draw(obj)
	drawPanel(obj.rawx,obj.rawy,math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),color or math.random(0,0xFFFFFF),0x0,' ', transparency)
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
    UIObject.changed = true
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function redraw()
    UIObject.changed = true
end

function onObjectResize(w,h) --Transform script
  UIObject.w = w
  UIObject.h = h
  UIObject.changed = true
end

function onObjectRemove()
	UIObject:remove()
end

function setColor(newColor)
	color = newColor
    UIObject.changed = true
end

function Init()
	UIObject = OE.Render.newObject(layer, math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),draw)
end

onObjectEnable = Init
onObjectDisable = onObjectRemove