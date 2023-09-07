local System = require("System")
local args = {...}
local OE = args[1]
local Scripts = {ExecutableForFrame={}}

function Scripts.Execute(script)
    System.call(script.Start,OE)
    table.insert(Scripts.ExecutableForFrame,script)
end

return Scripts