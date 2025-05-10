local drawText,uni, wrap, UIObject = OE.Render.DrawLibrary.drawText,unicode,require('Text').wrap, {}
text = "text"
color = 0xFFFFFF
vertical = 1
layer = 1
horizontal = 1
local resultDrawText = {''}
local function draw(obj)
	for i = 1, UIObject.h do
		drawText(obj.rawx,obj.rawy + i - 1,color or math.random(0,0xFFFFFF),resultDrawText[i])
	end
end

function recalculateOffsets(horizontalnew, verticalnew)
	horizontal = horizontalnew or horizontal
	vertical = verticalnew or vertical
	UIObject.x = Transform.Position.x + (horizontal == 1 and 0 or horizontal == 2 and math.ceil(Transform.Scale.w /2)-math.ceil(uni.len(resultDrawText[1])/2) or horizontal == 3 and Transform.Scale.w)
	UIObject.y = Transform.Position.y + (vertical == 1 and 0 or vertical == 2 and math.floor(Transform.Scale.h / 2) or vertical == 3 and Transform.Scale.h)
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
	recalculateOffsets()
    UIObject.changed = true
end

function redraw()
    UIObject.changed = true
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function onObjectResize(w,h) --Transform script
	resultDrawText = wrap(text,math.ceil(w))
    UIObject.w = w
    UIObject.h = #resultDrawText
	recalculateOffsets()
    UIObject.changed = true
end

function setText(newText)
	text = newText
	resultDrawText = wrap(text,math.ceil(Transform.Scale.w))
	recalculateOffsets()
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
	setText(text)
	UIObject = OE.Render.newObject(layer, math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),uni.len(text),#resultDrawText,draw)
	UIObject.EngineObject = Object
	recalculateOffsets()
end

onObjectEnable = Init
onObjectDisable = onObjectRemove