local cmp, getFile,len1,len2 = require('component'), OE.Storage.getFile
local empty = string.rep("\xAA",8192)
local listOfTapes = cmp.list('tape_drive')
tape1 = cmp.proxy(listOfTapes())
tape2 = cmp.proxy(listOfTapes())
local lengts = {}
if not tape1 or not tape2 then
	OE.log("Not enough tapes")
	return false
end
function Start()
	tape1.play()
	tape2.play()
end

function Update()
	if tape1.getPosition() >= len2 then
		tape1.stop()
		tape2.stop()
		OE.exit()
		-- BSOD picture, sound, crash system
	end
end

function Pause()
	tape1.stop()
	tape2.stop()
end
Resume = Start
function Wipe()
	tape1.seek(-math.huge)
	tape2.seek(-math.huge)
	local k = tape1.getSize()
	for i = 1, k + 8191, 8192 do
		tape1.write(empty)
		tape2.write(empty)
	end
	tape1.seek(-math.huge)
	tape2.seek(-math.huge)
end
function Dissolve()
	Pause()
	Wipe()
end
onApplicationExit = Dissolve

Dissolve()
tape1.seek(-math.huge)
tape2.seek(-math.huge)
tape1.write(getFile('Inst.dfpwm'))
len1 = #getFile('Inst.dfpwm')
OE.Storage.unloadFile("Inst.dfpwm")

tape2.write(getFile('Voices.dfpwm'))
len2 = #getFile('Voices.dfpwm')
OE.Storage.unloadFile("Voices.dfpwm")

tape1.seek(-math.huge)
tape2.seek(-math.huge)