local args = {...}
local x, y = args[1], args[2]
if y >= SCREEN_Y and y <= SCREEN_HEIGHT then
	args[4] = tostring(args[4])
	gpu.setForeground(args[3])
	local len = unicode.len(args[4])
	for i = 1, len do
		local localx = x+i-1
		if localx >= SCREEN_X and localx <= SCREEN_WIDTH then
			local tmp = {gpu.get(localx,y)}
			gpu.setBackground(tmp[3])
			gpu.set(localx,y,unicode.sub(args[4],i,i))
		end
	end
end