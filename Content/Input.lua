local drawText,drawPanel,focused,UIObject = require('Screen').drawText,require('Screen').drawRectangle, false
cursorSymbol, text, placeholderText, cursorPosition, forusedTextColor, focusedBackgroundColor, textColor, backgroundColor, cursorColor, placeholderColor, eraseOnFocus = "┃", "", "", 1, 0xFFFFFF,0x0,0x0,0xFFFFFF,0x008AFF,0xFF0000, false
local function draw(obj)
	drawPanel(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),color,0x0,' ')
	drawText(math.ceil(Transform.Position.x)+math.ceil(Transform.Scale.w/2),math.ceil(Transform.Position.y)+math.ceil(Transform.Scale.h/2),colors,text)
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

function setCursor(position)
	if position < 1 then
		cursorPosition = 1
	elseif position > #text + 1 then
		cursorPosition = #text + 1
	else
		cursorPosition = position
	end
end

function onTouch(button,x,y)
	if not OE.pointInside(object,x,y) and focused then
		focused = false
		OE.Input.focus = {}
	end
end

function onObjectTouch(button,x,y)

end

function onDrag(x,y,button)
	if focused then
		setCursor(x)
	end
end

function onKeyDown(key)
	
end

function Init()
	UIObject = OE.Render.Matrix.newObject(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),draw)
end