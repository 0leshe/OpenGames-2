local render = assert(loadfile(string.gsub(require('system').getCurrentScript(),"/RenderLaunchTest.lua","/RenderTest.lua")))(nil,false,nil,true) -- Подгружаем рендер. Аргументы: 
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
local function initPanel(obj)
  local color = math.random(0,0xFFFFFF)
  return function(obj) screen.drawRectangle(obj.rawx,obj.rawy,obj.w,obj.h,color,0x0," ") end
  --pu.setBackground(0x505050)
  --pu.fill(obj.x,obj.y,obj.w,obj.h," ")
end
local function initText()
  local color, text = math.random(0,0xFFFFFF), tostring(math.random(0,0xFFFFFF))
  return function(obj) screen.drawText(obj.rawx,obj.rawy,color,text) end
--pu.setBackground(0x505050)
--pu.fill(obj.x,obj.y,obj.w,obj.h," ")
end


render.newObject(1,1,160,50,panelRender1) -- Создаём новые объекты на экране. Координаты и размер контейнера, а так-же функция отрисовки.
--[[for i = 1, 100 do
    render.newObject(math.random(1,150),math.random(1,50),20,10,initText())
end]]
render.newObject(math.random(1,150),math.random(1,50),20,10,initPanel())
render.newObject(1,1,20,10,initPanel())
render.newObject(1,1,20,10,initText())
for i = 1, 2 do
    render.newObject(math.random(1,150),math.random(1,50),20,10,initPanel())
end


local wk = require("GUI").workspace()
render.process()

wk.eventHandler = function(_,_,...) -- Для обрабтки нас, и отрисовки картинки
  local events = {...}
  if events[1] == 'touch' or events[1] == 'drag' then -- Нажали! Перемещяем 2й объект...
    for i = 3,4 do
      render.objects[i].y = math.ceil(events[4])
      render.objects[i].x = math.ceil(events[3])
      render.objects[i].changed = true
    end
  elseif events[1] == 'key_down' then
    local changed = false
    if events[4] == 200 then
        render.y = render.y - 1
        changed = true
    elseif events[4] == 208 then
        render.y = render.y + 1
        changed = true
    elseif events[4] == 203 then
        render.x = render.x - 1
        changed = true
    elseif events[4] == 205 then
        render.x = render.x + 1
        changed = true
    end
    if changed then
        for i = 1, #render.objects do
            render.objects[i].changed = true
        end
        render.windowChanged()
    end
  end
  --[[for i = 4, 50 do
    render.objects[i].x = render.objects[i].x + 1
    if render.objects[i].x > 159 then
        render.objects[i].x = 1
    end
  end]]

  --Не каждое изменение объекта может требовать его перерисовки, в теорий
  render.process() -- Рендерим. Там происходит магия.
end
wk:start(0) -- На 0, если хотите без тормозов стабильную картинку
