local args = {...}
local Render = {Matrix = assert(load(require('filesystem').read(args[1].root..'Matrix.lua'), nil, args[6]))(args[2],args[3],args[4],args[5])}

function Render.clearRender()
  local objList = Render.Matrix.objects
  while #objList > 1 do
      Render.Matrix.objects[1]:remove()
  end
end

return Render