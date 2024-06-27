local render = assert(loadfile(string.gsub(require('system').getCurrentScript(),"/RenderLaunchTest.lua","/RenderTest.lua")))(nil,true,nil,true) -- Подгружаем рендер. Аргументы: 
--Без предварительного режима рендера
--Без буферов видеокарты. Нативные вызовы gpu будут мигать.
--Не подгружать библиотеку screen
local gpu = require('component').gpu
local screen = require('screen')
local fps = 1

local function panelRender1(obj) -- Функций рендера.
  screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,0x989898,0x0," ")
  --gpu.setBackground(0x989898)
  --gpu.fill(obj.x,obj.y,obj.w,obj.h," ")
end
local function initPanel()
    local color = math.random(0x0,0xFFFFFF)
return function(obj)
  screen.drawRectangle(obj.x,obj.y,obj.w,obj.h,color,0x0," ")
  --pu.setBackground(0x505050)
  --pu.fill(obj.x,obj.y,obj.w,obj.h," ")
end
end


render.newObject(1,1,160,50,panelRender1) -- Создаём новые объекты на экране. Координаты и размер контейнера, а так-же функция отрисовки.
render.newObject(1,2,20,10,initPanel()) -- 2 панели..
for i = 1, 48 do
    render.newObject(math.random(1,150),math.random(1,50),20,10,initPanel())
end

local wk = require("GUI").workspace()

wk.eventHandler = function(_,_,...) -- Для обрабтки нас, и отрисовки картинки
  local events = {...}
  if events[1] == 'touch' or events[1] == 'drag' then -- Нажали! Перемещяем 2й объект(Четырёхугольник, строка 25)...
    render.objects[2].y = math.ceil(events[4])
    render.objects[2].x = math.ceil(events[3])
  end
  --[[for i = 3, 50 do
    render.objects[i].x = render.objects[i].x + 10
    if render.objects[i].x > 160 then
        render.objects[i].x = -10
    end
  end]]

  --Не каждое изменение объекта может требовать его перерисовки, в теорий
  render.process(false) -- Рендерим. Там происходит магия.

end
wk:start(0) -- На 0, если хотите без тормозов стабильную картинку
