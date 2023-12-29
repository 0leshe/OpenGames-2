local args = {...}
local cmp = require("Component")
local OE = args[1]
local modem
local LN = {
    MAC = "BOOTING"
    ip = '127.0.0.'..tostring(math.random(0,255)),
    CurrentConnection = {
        ip = '127.0.0.1',
        lastPing = 0,
        pingFreq = 2.5,
        pingTrash = 3,
        port = 30255,
        lastMessage = {'Empty'},
        connections = {}
    }
}
)
modem = cmp.modem
if modem then
    LN.MAC = modem.address
end
function noModem()
    OE.Debug.Log("Modem component not available, but we still call it", true)
end
function LN.host(ip, port, onMessage) -- onMessage is script

end
function LN.connect(ip,port)

end
function LN.broadcast(...)

end
function LN.available()
    return modem and true
end
function LN.send(ip, ...)

end
return LN