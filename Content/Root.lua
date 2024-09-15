ID = math.random(0,OE.huge)
Enabled = true
Index = 1
Remove = shared()
setIndex = shared()
addScript = shared()
scriptsOrder = {}
print(addScript, "HERE")
function getScriptOrder(name)
	for i, v in pairs(scriptsOrder) do
		if v == name then
			return i
		end
	end
	return false
end
