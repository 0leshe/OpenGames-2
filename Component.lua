local args = {...}
local OE = args[1]
local Component = {}
Component.componentTypes = {
    SCRIPT = 1,
    SPRITE = 2,
    TEXT = 3,
    MATERIAL = 4
}
function Component.getComponent(Object,Type)
    for i, v in pairs(Object.Components) do
        if Object.Components[i].type == Type then
            return v
        end
    end
end 
function Component.getComponentID(Component)
    return Component.ID
end
function Component.createComponent(Object,ComponentType)
    local ID = math.random(0,OE.huge)
    if ComponentType == Component.componentTypes.SCRIPT then
        Object.Components[ID] = {
            type = Component.componentTypes.SCRIPT,
            ID = ID,
            called = false,
            file = "",
            preVars={}
        }
    elseif ComponentType == Component.componentTypes.MATERIAL then
        Object.Components[ID] = {
            type = Component.componentTypes.MATERIAL,
            ID = ID,
            Color = {
                First = 0x0,
                Second = 0x0,
                Third = 0x0,
                Fourth = 0x0,
                Fiveth = 0x0
            }
        }
    elseif ComponentType == Component.componentTypes.TEXT then
        Object.Components[ID] = {
            type = Component.componentTypes.TEXT,
            ID = ID,
            Text = {
            Text  = "Hello World!",
            PlaceHolder = "Place Holder",
            LocalizationText = "",
            LocalizationPlaceHolder = ""}
        }
    elseif ComponentType == Component.componentTypes.SPRITE then
        Object.Components[ID] = {
            type = Component.componentTypes.SPRITE,
            ID = ID,
            file = ''
        }
    end
    return ID
end
return Component