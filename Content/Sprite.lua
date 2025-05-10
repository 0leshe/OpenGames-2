local drawImage,Image,UIObject = OE.Render.DrawLibrary.drawImage,require('image')
transperent = false
layer = 1
sourceImage = 'MAIN_Placeholder.pic'
local image = OE.Storage.getFile(sourceImage)
local function draw(obj)
	drawImage(obj.rawx,obj.rawy,image,transperent)
end

function onObjectMove(x,y) --Transform script
    UIObject.x = x
	UIObject.y = y
    UIObject.changed = true
end

function redraw()
    UIObject.changed = true
end

function onObjectReindex(newIndex) --Main object script
	UIObject:setIndex(newIndex)
end

function onObjectResize(w,h) --Transform script
  UIObject.w = w
  UIObject.h = h
  UIObject.changed = true
end

function onObjectRemove()
	UIObject:remove()
end

function setImage(imageFile,scaleAdjust)
	image = OE.Storage.getFile(imageFile)
	sourceImage = image
    UIObject.changed = true
	if not scaleAdjust then
		Transform.Scale.h = Image.getHeight(image)
		Transform.Scale.w = Image.getWidth(image)
	end
end

function Init()
	UIObject = OE.Render.newObject(layer, math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),draw)
	setImage(sourceImage)
end

onObjectEnable = Init
onObjectDisable = onObjectRemove