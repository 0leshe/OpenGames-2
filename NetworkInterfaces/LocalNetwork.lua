local function err(reason,nonFatal)
  io.stderr:write(reason..'\n')
  os.exit()
end
local cmp = require('component')
local event = require('event')
local modem = cmp.modem
local args = {...}
local ser = require('text')
if not modem then
  err("No modem card")
end
local function tryOpenPort(port)
  if not modem.open(port) and not modem.isOpen(port) then
    err("Cannot open "..port.." port")
  end
  return true
end
local methods = {public = true}
function methods.send(ip,port,message)
  local serialized = false
  if type(message) == 'table' then
      message = ser.serialize(message)
      serialized = true
  end
  return modem.send(ip,port,serialized,message)
end
function methods.broadcast(port,message)
  modem.broadcast(port,message)
end
function methods.scan(port,time)
  tryOpenPort(port)
  local callbacked, startTime = {}, os.time()/72
  methods.broadcast(port,'ping')
  while true do
    local e = {event.pull(time,'modem_message')}
    if e[7] == 'pong' then
      table.insert(callbacked,e[3])
    end
    if os.time()/72 > startTime+time then
      break
    end
  end
  return callbacked
end
function methods.createHandler(port,handler)
  tryOpenPort(port)
  local toreturn = {handler=handler,eventId}
  toreturn.eventId = event.addHandler(function(...)
    local e = {...}
    if e[1] == 'modem_message' then
      if e[6] == true then
        e[7] = ser.deserialize(e[7])
      end
      if type(e[6]) == "string" then
          e[7] = e[6]
      end
      if e[7] == 'ping' and methods.public then
          methods.send(e[3],e[4],'pong')
      end
      toreturn.handler(e[3],e[7])
    end
  end)
  return toreturn
end
return methods
