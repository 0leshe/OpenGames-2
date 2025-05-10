local KeyCodes, pauseToggle = OE.Input.keyCodes
local anims = {[KeyCodes.A] = "Left", [KeyCodes.S] = "Down", [KeyCodes.D] = "Right", [KeyCodes.W] = "Up"}
function KeyDown(key)
	if anims[key] then
		Object.SpriteBehavior[anims[key]]()
	elseif key == KeyCodes.SPACE then
		if pauseToggle then
			Time.scale = 0
			Object.Audio.Pause()
		else
			Time.scale = 1
			Object.Audio.Resume()
		end
		pauseToggle = not pauseToggle
	end
end