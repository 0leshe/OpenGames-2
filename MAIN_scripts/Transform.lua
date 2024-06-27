local transform = {x=1,y=1,w=1,h=1}
Position = setmetatable({}, {__index = function(k) return transform[k] end, __newindex(k, v)
	transform[k] = v
	OE.Script.runEveryWithName('onObjectMove', Object)
end})
Scale = setmetatable({}, {__index = function(k) return transform[k] end, __newindex(k, v)
	transform[k] = v
	OE.Script.runEveryWithName('onObjectResize', Object)
end})
