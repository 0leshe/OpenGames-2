local args = {...}
local x,y,picture,blendForeground = args[1], args[2], args[3], args[4]
local imageWidth, imageHeight, pictureIndex, temp = picture[1], picture[2], 3
local clippedImageWidth, clippedImageHeight = imageWidth, imageHeight

-- Clipping left
if x < SCREEN_X then
	temp = SCREEN_X - x
	clippedImageWidth, x, pictureIndex = clippedImageWidth - temp, SCREEN_X, pictureIndex + temp * 4
end

-- Right
temp = x + clippedImageWidth - 1
	
if temp > SCREEN_WIDTH then
	clippedImageWidth = clippedImageWidth - temp + SCREEN_WIDTH
end

-- Top
if y < SCREEN_Y then
	temp = SCREEN_Y - y
	clippedImageHeight, y, pictureIndex = clippedImageHeight - temp, SCREEN_Y, pictureIndex + temp * imageWidth * 4
end

-- Bottom
temp = y + clippedImageHeight - 1

if temp > SCREEN_HEIGHT then
	clippedImageHeight = clippedImageHeight - temp + SCREEN_HEIGHT
end

local
	pictureIndexStep,
	background,
	foreground,
	alpha,
	char = (imageWidth - clippedImageWidth) * 4
for ly = 1, clippedImageHeight do
	local endy = ly+y-1
	for lx = 1, clippedImageWidth do
		local endx = lx+x-1
		alpha, char = picture[pictureIndex + 2], picture[pictureIndex + 3]
		local tmp = {gpu.get(endx,endy)}
		if alpha == 0 then
			gpu.setForeground(picture[pictureIndex+1])
			gpu.setBackground(picture[pictureIndex])
			gpu.set(endx,endy,char)
		elseif alpha > 0 and alpha < 1 then
			gpu.setBackground(colorBlend(tmp[3], picture[pictureIndex], alpha))
				
			if blendForeground then
				gpu.setForeground(colorBlend(tmp[2], picture[pictureIndex + 1], alpha))
			else
				gpu.setForeground(picture[pictureIndex+1])
			end
			gpu.set(endx,endy,char)
		end

		pictureIndex = pictureIndex + 4
	end

	pictureIndex = pictureIndex + pictureIndexStep
end