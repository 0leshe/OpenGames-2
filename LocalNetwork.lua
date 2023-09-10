local args = {...}
local OE = args[1]
local LN = {
    MAC = 'NIL',
    ip = '123.0.1.'..tostring(math.random(0,255)),
    CurrentConnection = {
        ip = '127.0.0.1',
        port = 30255,
        lastMessage = {'Empty'},
        messageTrashhold = 1,
        messageHistory = {('Empty')},
        connections = {}
    }
}


if require("Component").isAvailable('modem') then
    local modem = require("Component").modem
    LN.MAC = modem.address
    local function connect(ip,port,onMessage,host)
        modem.close(LN.CurrentConnection.port)
        LN.CurrentConnection.ip = ip
        LN.CurrentConnection.port = port
        modem.open(port)
        OE.Script.ExecutableForFrame[math.random(-OE.huge,-1)] = {Script={Update = function()
             if OE.lastEvent[1] == 'modem_message' then
                local packedMesage = {}
                for i = 6,#OE.lastEvent do
                    table.insert(packedMesage,OE.lastEvent[i])
                end
                if packedMesage[1] == LN.CurrentConnection.ip then
                    if packedMesage[3] == 'connect pls' then
                        if host then
                            LN.CurrentConnection.connections[OE.lastEvent[3]] = {ip=packedMesage[2]}
                        end
                    elseif packedMesage[3] == 'disconnect pls' then
                        if host then
                            table.remove(LN.CurrentConnection.connections,OE.lastEvent[3])
                        end
                    else
                        LN.CurrentConnection.lastMessage = packedMesage
                        table.remove(LN.CurrentConnection.messageHistory, LN.CurrentConnection.messageTrashhold)
                        table.insert(LN.CurrentConnection.messageHistory, 1, packedMesage)
                        onMessage()
                    end
                end
             end
        end}}
    end
    function LN.host(ip,port,onMessage)
        connect(ip,port,onMessage,true)
    end
    function LN.send(...)
        modem.broadcast(LN.CurrentConnection.port, LN.CurrentConnection.ip, LN.ip, ...)
    end
    function LN.avialible()
        return true
    end
    function LN.connect(ip,port,onMessage)
        connect(ip,port,onMessage)
        LN.send('connect pls')
    end
    function LN.disconnect()
        modem.close(LN.CurrentConnection.port)
        LN.send('disconnect pls')
    end
else
    function LN.avialible()
        return false
    end
end

return LN