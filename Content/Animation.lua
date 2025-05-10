local animationRunning, keyIndex, currentAnimation = false, 0
animations = {}
function Play(name)
	animationRunning = true
	currentAnimation = {}
	keyIndex = 0
	for i, v in pairs(animations[name].frames) do
		currentAnimation[i+Time.time] = v
	end
	currentAnimation.onEnd = animations[name].onEnd
end

local function getTableSize(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

function Update()
	if animationRunning then
		if getTableSize(currentAnimation) == 1 and currentAnimation.onEnd then
			animationRunning = false
			currentAnimation.onEnd()
			return
		end
		for i, v in pairs(currentAnimation) do
			if i ~= "onEnd" and i <= Time.time then
				keyIndex = keyIndex + 1
				v(keyIndex)
				currentAnimation[i] = nil
				break
			end
		end
	end
end