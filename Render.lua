local args = {...}
local Render = {Matrix = assert(loadfile(string.gsub(require'System'.getCurrentScript(),"Render.lua","Matrix.lua")))(args[2],args[3],args[4])}

function Render.clearRender()
  local objList = Render.Matrix.objects
  for i = 1, #objList do
      Render.Matrix.objects:remove()
  end
end

return Render