local currentPath = string.gsub(debug.getinfo(2, "S").source:sub(2):match("(.*/)"),'Server.lua','')
local args = {...}
local event = require('event')
local localhost = require('component').modem.address
local prefMethod = args[1] or 'LocalNetwork'
local methods = loadfile(currentPath .. "/NetworkInterfaces/"..prefMethod..".lua")()
local server = {methods = methods, timerId, isServer = true, port = tonumber(args[2]) or 1212, maxConnections = math.huge, connections = {}, connectionsPlace = {}, maxPingLose = 2, pingLoses = {}, pingable = {}, handler=function() end}
if type(args[3]) == 'function' then
  server.handler = args[3]
end
local function deleteConnection(ip)
  server.connections[server.connectionsPlace[ip]] = nil
  server.connectionsPlace[ip] = nil
  server.pingLoses[ip] = nil
end
local function addConnection(ip)
  server.connectionsPlace[ip] = #server.connections+1
  server.connections[#server.connections+1] = ip
  server.pingLoses[ip] = 0
end
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
server.eventHandler = methods.createHandler(server.port,function(ip,message)
  if server.connectionsPlace[ip] then
    if message == 'disconnect' then
      if server.isServer then
        deleteConnection(ip)
      else
        server.disconnect()
      end
    end
    if not server.isServer and message == 'ping' then
      methods.send(ip,server.port,'pong')
      server.pingable[ip] = true
    elseif message == 'pong' then
      server.pingable[ip] = true
    else
      server.handler(ip,message)
    end
  end
  if server.isServer and type(message) == 'table' and message[1] == 'connect' and message[2] == localhost and #server.connectionsPlace < server.maxConnections then
    if not server.connectionsPlace[ip] then
      addConnection(ip)
      methods.send(ip,server.port,'connected')
      server.handler(ip,'connected')
    else
      methods.send(ip,server.port,'already connected')
    end
  end
  if #server.connections == 0 and not server.isServer and message == 'connected' then
    addConnection(ip)
    server.handler(ip,'connected')
  end
  return true
end)
function server.connect(ip,port)
  server.isServer = false
  methods.public = false
  methods.send(ip,port,{'connect',ip})
end
function server.onDisconnect()
end
function server.disconnect()
   print('done')
  if not server.isServer and #server.connections == 1 then
   local address = server.connections[1]
   print('done')
   server.isServer = true
   methods.public = true
   methods.send(address,server.port,'disconnect')
   deleteConnection(address)
   print('done')
   server.onDisconnect(address)
  end
end
server.timerId = event.addHandler(function()
  for i = 1, #server.connections do
    if server.pingable[server.connections[i]] then
      server.pingLoses[server.connections[i]] = 0
    else
      local v = server.connections[i]
      server.pingLoses[v] = server.pingLoses[v] + 1
      if server.pingLoses[v] >= server.maxPingLose then
        if server.isServer then
          deleteConnection(v)
        else
          server.disconnect()
        end
      end
    end
  end
  server.pingable = {}
  if server.isServer then
    for i = 1,#server.connections do
      methods.send(server.connections[i],server.port,'ping')
    end
  end
end,2.5)
function server.stop()
  print(event.removeHandler(server.timerId), event.removeHandler(server.eventHandler.eventId))
  for i = 1, #server.connections do
    server.methods.send(server.connections[i],server.port,'disconnect')
  end
  --server = nil
end
return server
