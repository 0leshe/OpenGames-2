local UIObject = {}
Text = ""
PlaceHolder = ""
onInputFinished = function() return false end
Colors = setmetatable({
	Background = 0xFFFFFF,
	Foreground = 0x0,
	Placeholder = 0x999999,
	BackgroundP = 0x0,
	ForegroundP = 0xFFFFFF
},
{
	_index = function(self, k)
		local def = UIObject.colors.default
		local foc = UIObject.colors.focused
		local compatability = {Background = "background", Foreground = "text"}
		if k == "Placeholder" then
			return UIObject.colors.placeholderText
		elseif k:find("P") then
			return foc[compatability[string:gsub(k,'P','')]]
		else
			return def[compatability[k]]
		end
	end,
	_newindex = function(self, k, v)
		local def = UIObject.colors.default
		local foc = UIObject.colors.focused
		local compatability = {Background = "background", Foreground = "text"}
		if k == "Placeholder" then
			UIObject.colors.placeholderText = v
		elseif k:find("P") then
			foc[compatability[string:gsub(k,'P','')]] = v
		else
			def[compatability[k]] = v
		end
	end,
})
function OnDisable()
	OE.Render.removeFromRender(GameObject)
end
function OnEnable()
	UIObject = OE.Render.addToRender(GameObject, table.unpack(Colors))
	UIObject.onInputFinished = function(...) 
		onInputFinished(...)
		Text = UIObject.text 
	end
end