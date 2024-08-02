local drawImage,Image,UIObject = require('Screen').drawImage,require('image')
transperent = false
sourceImage = 'MAIN_Placeholder.pic'
local image = OE.Storage.getFile(sourceImage)
local function draw(obj)
	drawImage(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),image,transperent)
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

function setImage(imageFile)
	image = OE.Storage.getFile(imageFile)
	sourceImage = image
	OE.Render.Matrix.addQueue(UIObject)
	Transform.Scale.h = Image.getHeight(image)
	Transform.Scale.w = Image.getWidth(image)
end

function Init()
	UIObject = OE.Render.Matrix.newObject(math.ceil(Transform.Position.x),math.ceil(Transform.Position.y),math.ceil(Transform.Scale.w),math.ceil(Transform.Scale.h),draw)
	setImage(sourceImage)
end

onObjectEnable = Init
onObjectDisable = onObjectRemove