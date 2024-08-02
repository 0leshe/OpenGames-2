local drawText,uni, wrap, UIObject = require('Screen').drawText,unicode,require('Text').wrap
text = "text"
color = 0xFFFFFF
local resultDrawText
local function draw(obj)
	for i = 1, UIObject.h do
		drawText(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y) + i - 1,color,resultDrawText[i] or "")
	end
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
	OE.log("TEXT",w,h,Transform.Position.x,Transform.Position.y)
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function onObjectResize(w,h) --Transform script
    UIObject.w = w
    UIObject.h = h
	resultDrawText = wrap(text,math.ceil(w))
end

function setText(newText)
	text = newText
    Transform.Scale.w = uni.len(newText)
end

function onObjectRemove()
	UIObject:remove()
end

function setColor(newColor)
	color = newColor
	OE.Render.Matrix.addQueue(UIObject)
end

function Init()
	UIObject = OE.Render.Matrix.newObject(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),uni.len(text),1,draw)
	setText(text)
end

onObjectEnable = Init
onObjectDisable = onObjectRemove