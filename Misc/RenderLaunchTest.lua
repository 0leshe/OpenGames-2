local render = assert(loadfile(string.gsub(require('system').getCurrentScript(),"/RenderLaunchTest.lua","/RenderTest.lua")))(nil,false,true) -- Подгружаем рендер. Аргументы: 
--Без предварительного режима рендера
--Без буферов видеокарты. Нативные вызовы gpu будут мигать.
--Не подгружать библиотеку screen
local gpu = require('component').gpu
local screen = require('screen')
local fps = 1

local function panelRender1(obj) -- Функций рендера.
  --screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,0x989898,0x0," ")
  gpu.setBackground(0x989898)
  gpu.fill(obj.x,obj.y,obj.w,obj.h," ")
end

local function panelRender2(obj)
  --screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,0x989898,0x0," ")
  gpu.setBackground(0x505050)
  gpu.fill(obj.x,obj.y,obj.w,obj.h," ")
end

local function fpsRender(obj)
  --screen.drawText(obj.x,obj.y,0xFFFFFF,0x0,tostring(fps).."   ")
  gpu.setBackground(0x989898)
  gpu.setForeground(0xFFFFFF)
  gpu.set(obj.x,obj.y,tostring(fps).."   ")
end

render.newObject(1,1,160,50,panelRender1) -- Создаём новые объекты на экране. Координаты и размер контейнера, а так-же функция отрисовки.
render.newObject(1,2,20,10,panelRender2) -- 2 панели..
render.newObject(1,1,4,1,fpsRender) -- И счётчик fps

local wk = require("GUI").workspace()
local timerFPS = os.clock()

wk.eventHandler = function(_,_,...) -- Для обрабтки нас, и отрисовки картинки
  local events = {...}
  if events[1] == 'touch' or events[1] == 'drag' then -- Нажали! Перемещяем 2й объект(Четырёхугольник, строка 25)...
    render.objects[2].y = math.ceil(events[4])
    render.objects[2].x = math.ceil(events[3])
  end

  fps = fps + 1
  render.addQueue(render.objects[3]) -- Добовляем в очередь счётчик фпс вручную, так-как контейнер не изменился, тригер не сработал. 
  --Не каждое изменение объекта может требовать его перерисовки, в теорий
  render.process() -- Рендерим. Там происходит магия.

  if timerFPS < os.clock() then
    timerFPS = os.clock() + 1
     fps = 0
  end
end
wk:start(0) -- На 0, если хотите без тормозов стабильную картинку
