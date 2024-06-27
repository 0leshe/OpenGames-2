local text,uni,UIObject = require('Screen').drawText,unicode
text = ""
color = 0xFFFFFF
local function draw(obj)
	text(Transform.x,Transform.y,color,text)
end

function Start()
	UIObject = OE.Render.Matrix.newObject(Transform.x,Transform.y,uni.len(text),1,draw)
end

function onObjectMove(x,y) --Transoform script
    UIObject.x = x
	UIObject.y = y
end

function onObjectReindex(newIndex)
	UIObject:setIndex(newIndex)
end

function onObjectResize()
  Transoform.width = uni.len(text)
  Transoform.height = 1
end

function setText(newText)
    UIObject.w = uni.len(newText)
	text = newText
	Transoform.width = UIObject.w
end