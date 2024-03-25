local render = assert(loadfile(string.gsub(require('system').getCurrentScript(),"/RenderLaunchTest.lua","/RenderTest.lua")))(nil,false,true)
local gpu = require('component').gpu
local screen = require('screen')
local i = 1
local function panelRender1(obj)
  --screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,0x989898,0x0," ")
  gpu.setBackground(0x989898)
  gpu.fill(obj.x,obj.y,obj.w,obj.h," ")
end
local function panelRender2(obj)
  --screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,0x989898,0x0," ")
  gpu.setBackground(0x505050)
  gpu.fill(obj.x,obj.y,obj.w,obj.h," ")
end
render.changeRender('perObject')
render.newObject(1,1,160,50,panelRender1)
render.newObject(1,2,20,10,panelRender2)
local wk = require("GUI").workspace()
local timer = os.clock()
wk.eventHandler = function(_,_,...)
  local args = {...}
  if args[1] == 'touch' or args[1] == 'drag' then
    render.objects[2].y = math.ceil(args[4])
    render.objects[2].x = math.ceil(args[3]) 
  end
  i = i + 1
  render.process()
  if timer < os.clock() then
    timer = os.clock() + 1
     i = 0
  end
end
wk:start(0)
