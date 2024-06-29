local drawText,uni,UIObject = require('Screen').drawText,unicode
text = ""
color = 0xFFFFFF
local function draw(obj)
	drawText(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),color,text)
end

function Init()
	UIObject = OE.Render.Matrix.newObject(Transform.Position.x,Transform.Position.y,uni.len(text),1,draw)
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function setText(newText)
    UIObject.w = uni.len(newText)
	text = newText
end