local GUI = require('GUI')
local Image = require("Image")
local Render = {}
local args = {...}
local OE = args[1]
Render.renderTypes = {
    TEXT = 1,
    PANEL = 2,
    BUTTON = 3,
    IMAGE = 4,
    INPUT = 5,
    SLIDER = 6,
    SWITCH = 7,
    COMBOBOX = 8,
    PROGRESSINDICATOR = 9,
    PROGRESSBAR = 10
}
Render.ButtonTypes = {
  Default = 'button',
  Rounded = 'roundedButton',
  Framed = 'framedButton'
}
function Render.clearRender()
    for i,v in pairs(OE.CurrentScene.RenderObjects) do
        Render.removeFromRender(OE.CurrentScene.Objects[i])
    end
end
local function loadText(text,textOrHolder)
  if textOrHolder then
    if text.Text.LocalizationPlaceHolder ~= '' and text.Text.LocalizationPlaceHolder then
      return OE.Localization.getLocalization(text.Text.LocalizationPlaceHolder)
    else
      return text.Text.PlaceHolder
    end
  else
    if text.Text.LocalizationText ~= '' and text.Text.LocalizationText then
      return OE.Localization.getLocalization(text.Text.LocalizationText)
    else
      return text.Text.Text
    end
  end
end
function Render.removeFromRender(Object)
  if OE.CurrentScene.RenderObjects[Object.ID] then
    -- Recover normal values
    local material = Object:getComponent(OE.Component.componentTypes.MATERIAL) or {Color={}}
    local Color
    if material then
      Color = material.Color
    end
    material = {ID=material.ID,type=material.type,Color={
      First=OE.deepcopy(Color.First),
      Second=OE.deepcopy(Color.Second),
      Third=OE.deepcopy(Color.Third),
      Fourth=OE.deepcopy(Color.Fourth),
      Fiveth=OE.deepcopy(Color.Fiveth)}
    }
    local Position = Object.Transform.Position
    Position = {Width = OE.deepcopy(Position.Width),Height = OE.deepcopy(Position.Height)}
    local Scale = Object.Transform.Scale
    Scale = {Width = OE.deepcopy(Scale.Width),Height = OE.deepcopy(Scale.Height)}
    local text = Object:getComponent(OE.Component.componentTypes.TEXT) or {Text={}}
    text.Text = {
      ID = text.ID,
      type = text.type,
      LocalizationPlaceHolder = text.Text.LocalizationPlaceHolder,
      LocalizationText = text.Text.LocalizationText,
      Text = OE.deepcopy(text.Text.Text),
      PlaceHolder = OE.deepcopy(text.Text.PlaceHolder)
    }
    if Object.renderMode == Render.renderTypes.PROGRESSINDICATOR then
      Object.Active = OE.CurrentScene.RenderObjects[Object.ID].Active
      Object.Roll = function() return 'Add to render fisrt!' end
    end
    Object.Enabled = nil
    Object.Enabled = OE.CurrentScene.RenderObjects[Object.ID].hidden
    -- Deleting render object
    OE.CurrentScene.RenderObjects[Object.ID]:remove()
    OE.CurrentScene.RenderObjects[Object.ID] = nil
  end
end
function Render.redrawObject(Object)
  Render.removeFromRender(Object)
  Render.addToRender(Object)
end
function Render.downRenderOrder(Object)
    return OE.CurrentScene.RenderObjects[Object.ID]:moveBackward()
end
function Render.upRenderOrder(Object)
    return OE.CurrentScene.RenderObjects[Object.ID]:moveForward()
end
function Render.toTopRenderOrder(Object)
    return OE.CurrentScene.RenderObjects[Object.ID]:moveToFront()
end
function Render.addToRender(Object)
  if OE.CurrentScene.RenderObjects[Object.ID] then
    return false, 'Object alr exists'
  end
  local material = Object:getComponent(OE.Component.componentTypes.MATERIAL) or {Color={}}
  local Color
  if material then
    Color = material.Color
  end
  local Position = Object.Transform.Position
  local Scale = Object.Transform.Scale
  local sprite = Object:getComponent(OE.Component.componentTypes.SPRITE) or {}
  local text = Object:getComponent(OE.Component.componentTypes.TEXT) or {Text={}}
    if Object.renderMode == Render.renderTypes.PANEL then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.panel(
          Position.x,
          Position.y,
          Scale.Width,
          Scale.Height,
          Color.First
      ))
    elseif Object.renderMode == Render.renderTypes.TEXT then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.text(
          Position.x,
          Position.y,
          Color.First,
          loadText(text,false)
      ))
    elseif Object.renderMode == Render.renderTypes.PROGRESSINDICATOR then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.progressIndicator(
          Position.x,
          Position.y,
          Color.First,
          Color.Second,
          Color.Third
      ))
      OE.CurrentScene.RenderObjects[Object.ID].active = Object.Active
      Object.Active = nil
      function Object.Roll()
         OE.CurrentScene.RenderObjects[Object.ID]:roll()
      end
      Object = setmetatable(Object,{
        __index = function(self, k)
          if k == 'Active' then
            return OE.CurrentScene.RenderObjects[Object.ID].active
          end
        end,
        __newindex = function(self, k, v)
          if k == 'Active' then
            OE.CurrentScene.RenderObjects[Object.ID].active = v
          end
        end
      })
    elseif Object.renderMode == Render.renderTypes.PROGRESSBAR then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.progressBar(
          Position.x,
          Position.y,
          Scale.Width,
          Color.First,
          Color.Second,
          Color.Third,
          Object.Value,
          true
      ))
      Object.Value = nil
      Object = setmetatable(Object,{
        __index = function(self, k)
          if k == 'Value' then
            return OE.CurrentScene.RenderObjects[Object.ID].value
          end
        end,
        __newindex = function(self, k, v)
          if k == 'Value' then
            OE.CurrentScene.RenderObjects[Object.ID].value = v
          end
        end
      })
    elseif Object.renderMode == Render.renderTypes.COMBOBOX then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.comboBox(
          Position.x,
          Position.y,
          Scale.Width,
          Scale.Height,
          Color.First,
          Color.Second,
          Color.Third,
          Color.Fourth
      ))
      function Object.updateItems()
        OE.CurrentScene.RenderObjects[Object.ID]:clear()
        for i = 1, #Object.Items do
          local tmp = OE.CurrentScene.RenderObjects[Object.ID]:addItem(Object.Items[i].name)
          tmp.onTouch = function()
            Object.Items[i].onTouch(Object.Items[i], Object, OE)
          end
        end
      end
      Object.updateItems()
    elseif Object.renderMode == Render.renderTypes.BUTTON then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI[Object.ButtonType](
          Position.x,
          Position.y,
          Scale.Width,
          Scale.Height,
          Color.First,
          Color.Second,
          Color.Third,
          Color.Fourth,
          loadText(text,false)
      ))
      OE.CurrentScene.RenderObjects[Object.ID].onTouch = Object.onTouch
    elseif Object.renderMode == Render.renderTypes.IMAGE then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.image(
          Position.x,
          Position.y,
          OE.Storage.getFile(sprite.file)
      ))
    elseif Object.renderMode == Render.renderTypes.SWITCH then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.switch(
          Position.x,
          Position.y,
          Scale.Width,
          Color.First,
          Color.Second,
          Color.Third
      ))
      OE.CurrentScene.RenderObjects[Object.ID].onStateChanged = function(state) Object.State = state.state Object.onStateChanged(Object,OE) end
    elseif Object.renderMode == Render.renderTypes.SLIDER then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.slider(
          Position.x,
          Position.y,
          Scale.Width,
          Color.First,
          Color.Second,
          Color.Third,
          Color.Fourth,
          Object.minValue,
          Object.maxValue,
          Object.Value
      ))
      OE.CurrentScene.RenderObjects[Object.ID].onValueChanged = function(_,self) Object.Value = self.value Object.onValueChanged(Object,OE) end
    elseif Object.renderMode == Render.renderTypes.INPUT then
      OE.CurrentScene.RenderObjects[Object.ID] = OE.Render.Workspace:addChild(GUI.input(
          Position.x,
          Position.y,
          Scale.Width,
          Scale.Height,
          Color.First,
          Color.Second,
          Color.Third,
          Color.Fourth,
          Color.Fiveth,
          loadText(text,false),
          loadText(text,true)
      ))
      OE.CurrentScene.RenderObjects[Object.ID].onInputFinished = function() Object.onInputFinished(Object,OE) end
    end
    if OE.CurrentScene.RenderObjects[Object.ID] then -- Making links. If we change object parameter, we change render parameter
          local UI = OE.CurrentScene.RenderObjects[Object.ID]
          local renderTypes = Render.renderTypes
          local colors = UI.colors
          local renderMode = Object.renderMode
          Object.Enabled = nil
          Object = setmetatable(Object, {
              __index = function(self, k)
                if k == 'Enabled' then
                  print(UI.hidden)
                  if not UI.hidden then
                    return false
                  else
                    return true
                  end
                end
              end,
              __newindex = function(self, k, v)
                if k == 'Enabled' then
                  UI.hidden = v
                end
              end
          })
          --                      POSITION
        
          OE.CurrentScene.Objects[Object.ID].Transform.Position = setmetatable({}, {
              __index = function(self, k)
                if k == 'x' then
                  return UI.localX
                elseif k == 'y' then
                  return UI.localY
                end
              end,
              __newindex = function(self, k, v)
                if k == 'x' then
                  for i,v in pairs(Object.Components) do
                    if v.type == OE.Component.componentTypes.BOXCOLIDER then
                      -- algo of thing that will calc colide
                    end
                  end
                  UI.localX = v
                elseif k == 'y' then
                  UI.localY = v
                end
              end
            })
        
            --                   SCALE
        
            OE.CurrentScene.Objects[Object.ID].Transform.Scale = setmetatable({}, {
                __index = function(self, k)
                  if k == 'Width' then
                    return UI.width
                  elseif k == 'Height' then
                    return UI.height
                  end
                end,
                __newindex = function(self, k, v)
                  if k == 'Width' then
                    UI.width = v
                  elseif k == 'Height' then
                    UI.height = v
                  end
                end
              })
        
              --                 TEXT
              local a,b = text.Text.LocalizationText, text.Text.LocalizationPlaceHolder
              text.Text = setmetatable({}, {
                __index = function(self, k)
                  if k == 'Text' then
                    return UI.text
                  elseif k == 'PlaceHolder' then
                    return UI.placeholderText
                  end
                end,
                __newindex = function(self, k, v)
                  if k == 'Text' then
                    UI.text = v
                  elseif k == 'PlaceHolder' then
                    UI.placeholderText = v
                  end
                end,
                LocalizationText = a,
                LocalizationPlaceHolder = b
              })
        
              --                SPRITE
        
              sprite = setmetatable({sprite.ID,sprite.type}, {
                __index = function(self, k)
                  if k == 'file' then
                    return UI.image
                  end
                end,
                __newindex = function(self, k, v)
                  if k == 'file' then
                    UI.image = Image.load(OE.Storage.getFile(v))
                  end
                end
              })
        
              --               MATERIAL
        
             material.Color = setmetatable({}, {
              __index = function(self, k)
                if k == 'First' then
                  if renderMode == renderTypes.PANEL  then
                    return colors.background
                  elseif renderMode == renderTypes.BUTTON or renderMode == renderTypes.INPUT or renderMode == renderTypes.COMBOBOX then
                    return colors.default.background
                  elseif renderMode == renderTypes.TEXT then
                    return UI.color
                  elseif renderMode == renderTypes.SWITCH or renderMode == renderTypes.PROGRESSBAR then
                    return colors.active
                  elseif renderMode == renderTypes.SLIDER then
                    return colors.pipe
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    return colors.pasive
                  end
                elseif k == 'Second' then
                  if renderMode == renderTypes.BUTTON or renderMode == renderTypes.INPUT or renderMode == renderTypes.COMBOBOX then
                    return colors.default.text
                  elseif renderMode == renderTypes.SWITCH or renderMode == renderTypes.PROGRESSBAR then
                    return colors.passive
                  elseif renderMode == renderTypes.SLIDER then
                    return colors.active
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    return colors.primary
                  end
                elseif k == 'Third' then
                  if renderMode == renderTypes.BUTTON then
                    return colors.pressed.background
                  elseif renderMode == renderTypes.INPUT then
                    return colors.placeholderText
                  elseif renderMode == renderTypes.SWITCH then
                    return colors.pipe
                  elseif renderMode == renderTypes.SLIDER then
                    return colors.passive
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    return colors.secondary
                  elseif renderMode == renderTypes.PROGRESSBAR then
                    return colors.value
                  elseif renderMode == renderTypes.COMBOBOX then
                    return colors.arrow.background
                  end
                elseif k == 'Fourth' then
                  if renderMode == renderTypes.BUTTON then
                    return colors.pressed.text
                  elseif renderMode == renderTypes.INPUT then
                    return colors.focused.background
                  elseif renderMode == renderTypes.SLIDER then
                    return colors.value
                  elseif renderMode == renderTypes.COMBOBOX then
                    return colors.arrow.text
                  end
                elseif k == 'Fiveth' then
                  if renderMode == renderTypes.INPUT then
                    return colors.focused.text
                  end
                end
              end,
              __newindex = function(self, k, v)
                if k == 'First' then
                  if renderMode == renderTypes.PANEL  then
                    colors.background = v
                  elseif renderMode == renderTypes.BUTTON or renderMode == renderTypes.INPUT then
                    colors.default.background = v
                  elseif renderMode == renderTypes.COMBOBOX then
                      UI.dropDownMenu.colors.default.background = v
                      colors.default.background = v
                  elseif renderMode == renderTypes.TEXT then
                    UI.color = v
                  elseif renderMode == renderTypes.SWITCH or renderMode == renderTypes.PROGRESSBAR then
                    colors.active = v
                  elseif renderMode == renderTypes.SLIDER then
                    colors.pipe = v
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    colors.pasive = v
                  end
                elseif k == 'Second' then
                  if renderMode == renderTypes.BUTTON or renderMode == renderTypes.INPUT then
                    colors.default.text = v
                  elseif renderMode == renderTypes.COMBOBOX then
                      UI.dropDownMenu.colors.default.text = v
                      colors.default.text = v
                  elseif renderMode == renderTypes.SWITCH or renderMode == renderTypes.PROGRESSBAR then
                    colors.passive = v
                  elseif renderMode == renderTypes.SLIDER then
                    colors.active = v
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    colors.primary = v
                  end
                elseif k == 'Third' then
                  if renderMode == renderTypes.BUTTON then
                    colors.pressed.background = v
                  elseif renderMode == renderTypes.INPUT then
                    colors.placeholderText = v
                  elseif renderMode == renderTypes.SWITCH then
                    colors.pipe = v
                  elseif renderMode == renderTypes.SLIDER then
                    colors.passive = v
                  elseif renderMode == renderTypes.PROGRESSINDICATOR then
                    colors.secondary = v
                  elseif renderMode == renderTypes.PROGRESSBAR then
                    colors.value = v
                  elseif renderMode == renderTypes.COMBOBOX then
                    colors.arrow.background = v
                    UI.dropDownMenu.colors.selected.background = v
                  end
                elseif k == 'Fourth' then
                  if renderMode == renderTypes.BUTTON then
                    colors.pressed.text = v
                  elseif renderMode == renderTypes.INPUT then
                    colors.focused.background = v
                  elseif renderMode == renderTypes.SLIDER then
                    colors.value = v
                  elseif renderMode == renderTypes.COMBOBOX then
                    colors.arrow.text = v
                    UI.dropDownMenu.colors.selected.text = v
                  end
                elseif k == 'Fiveth' then
                  if renderMode == renderTypes.INPUT then
                    colors.focused.text = v
                  end
                end
              end
            })
        end
end
return Render