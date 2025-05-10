local args, temp = {...}
local x,y, width,height = args[1], args[2],args[3],args[4]
if x < SCREEN_X then
	width = width - SCREEN_X + x
	x = SCREEN_X
end

-- Right
temp = x + width - 1
if temp > SCREEN_WIDTH then
	width = width - temp + SCREEN_WIDTH
end

-- Top
if y < SCREEN_Y then
	height = height - SCREEN_Y + y
	y = SCREEN_Y
end

-- Bottom
temp = y + height - 1
if temp > SCREEN_HEIGHT then
	height = height - temp + SCREEN_HEIGHT
end
if args[8] then
	for lx = x, width do
		for ly = y, height do
			local tmp = gpu.get(lx,ly)
			gpu.setForeground(colorBlend(tmp[2], args[6], args[8]))
			gpu.setBackground(colorBlend(tmp[3], args[5], args[8]))
			gpu.set(lx,ly,width,height,args[7])
		end
	end
else
	gpu.setForeground(args[6])
	gpu.setBackground(args[5])
	gpu.fill(x,y,width,height,args[7])
end