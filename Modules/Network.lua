local modem = require("Component").modem
local Network = {}

function Network.startServer(handler,mode,port)
    if not modem then return false, 'No component with name "modem" found' end
	return assert(loadfile(string.gsub(require'System'.getCurrentScript(),"Network.lua","/Misc/NetworkServer.lua")))(mode,port, handler)
end


return Network