local args = {...}
local Render = {Matrix = assert(loadfile(string.gsub(require'System'.getCurrentScript(),"Render.lua","/Misc/Matrix.lua")))(args[2],args[3],args[4],args[5])}

function Render.clearRender()
  local objList = Render.Matrix.objects
  while #objList > 1 do
      Render.Matrix.objects[1]:remove()
  end
end

return Render