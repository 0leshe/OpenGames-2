local args = {...}
local OE = args[1]
local Sound = {SoundCard={}}

if require("Component").isAvailable('tape_drive') then
    local tape = require("Component").tape_drive
    function Sound.prepere(soundFileName)
        tape.write(OE.Storage.getFile(soundFileName).audio)
        OE.Script.ExecutableForFrame[math.random(-OE.huge,-1)] = {update=function()
            
        end}
    end
    function Sound.play()
        tape.play()
    end
    function Sound.stop()
        tape.stop()
    end
    function Sound.avialible()
        return true
    end
else
    function Sound.avialible()
        return false
    end
end


return Sound