local transform = {x=1, y=1, w=1, h=1}
Position = setmetatable({}, {__index = transform, __newindex = function(me,k, v)
	transform[k] = v
	OE.Script.runEveryWithName('onObjectMove', Object,transform.x,transform.y)
end})
Scale = setmetatable({}, {__index = transform, __newindex = function(me,k, v)
	transform[k] = v
	OE.Script.runEveryWithName('onObjectResize', Object,transform.w,transform.h)
end})

function onObjectDisable()
	script:_SetEnable(true)
end