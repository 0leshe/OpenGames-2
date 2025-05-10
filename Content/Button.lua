local colorTransition, pressed, state, focusStarted, someoneDragging, someoneDraggingNow = require('Color').transition
focusedTextColor, focusedBackgroundColor, textScript, panelScript, currentPanelColor, currentTextColor, smooth, focusedTime, callOffset, textColor,panelColor = 0xFFFFFF,0x0,{color=0,redraw = OE.nilfunction},{color=0,redraw = OE.nilfunction},nil,nil,true,0.25,0.25

function onClick()
  -- User script
end
function fadeIn()
    if state > 1 then
        Update = nil
        return
    end
    panelScript.setColor(colorTransition(panelColor, focusedBackgroundColor, state))
    textScript.setColor(colorTransition(textColor, focusedTextColor, state))
    state = (Time.time-focusStarted) / focusedTime
end
function fadeOut()
    if state > 1 then
        Update = nil
        return
    end
    panelScript.setColor(colorTransition(panelColor, focusedBackgroundColor, 1-state))
    textScript.setColor(colorTransition(textColor, focusedTextColor, 1-state))
    state = (Time.time-focusStarted) / focusedTime
end
function onObjectTouch(button,x,y)
    pressed = true
    state, focusStarted = 0, Time.time
    if smooth then
        Update = fadeIn
    else
        textScript.setColor(focusedTextColor)
        panelScript.setColor(focusedBackgroundColor)
        panelScript.redraw()
        textScript.redraw()
    end
    OE.Script.Invoke(onClick, callOffset)
end

function onObjectDrag()
    someoneDragging = true
    if not pressed and not Update and not someoneDraggingNow then
        state, focusStarted = 0, Time.time
        someoneDraggingNow = true
        if smooth then
            Update = fadeIn
        else
            textScript.setColor(focusedTextColor)
            panelScript.setColor(focusedBackgroundColor)
            panelScript.redraw()
            textScript.redraw()
        end
    end
end
function onDrag()
    if not pressed then
        if someoneDragging then
            someoneDragging = false
        elseif someoneDraggingNow then
            Update = nil
            someoneDraggingNow = false
            textScript.setColor(textColor)
            panelScript.setColor(panelColor)
            panelScript.redraw()
            textScript.redraw()
        end
    end
end

function onDrop()
    if pressed then
        pressed = false
        state, focusStarted = 0, Time.time
        if smooth then
            Update = fadeOut
        else
            textScript.setColor(textColor)
            panelScript.setColor(panelColor)
            panelScript.redraw()
            textScript.redraw()
        end
    elseif someoneDraggingNow then
        Update = nil
        someoneDraggingNow = false
        textScript.setColor(textColor)
        panelScript.setColor(panelColor)
        panelScript.redraw()
        textScript.redraw()
    end
end

function colorUpdate()
    textColor, panelColor = textScript.color, panelScript.color
end
function Init()
    textScript = Object[textScript]
    panelScript = Object[panelScript]
    colorUpdate()
end
Start = colorUpdate