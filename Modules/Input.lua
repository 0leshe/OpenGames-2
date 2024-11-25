local Input = {focus={}}
local kb = require("KeyBoard")
local args = {...}
local OE = args[1]

function Input.getButton(key)
    return kb.isKeyDown(key)
end

function Input.getButtonDown(key)
    return (OE.lastEvent[4] == key and OE.lastEvent[1] == "key_down") and true or false
end

function Input.getButtonUp(key)
    return (OE.lastEvent[4] == key and OE.lastEvent[1] == "key_up") and true or false
end

local YESSSSthatoutboys = {
    touch=function() OE.Script.runEveryWithName("onTouch",focus,OE.lastEvent[3],OE.lastEvent[4],OE.lastEvent[5]) end,
    drag=function() OE.Script.runEveryWithName("onDrag",focus,OE.lastEvent[3],OE.lastEvent[4],OE.lastEvent[5]) end,
    key_down=function() OE.Script.runEveryWithName("onKeyDown",focus,OE.lastEvent[4]) end,
    key_up=function() OE.Script.runEveryWithName("onKeyUp",focus,OE.lastEvent[4]) end,
    drop=function() OE.Script.runEveryWithName("onDrop",focus,OE.lastEvent[3],OE.lastEvent[4],OE.lastEvent[5]) end
}
function Input.onEvent()
    return YESSSSthatoutboys[OE.lastEvent[1]] and YESSSSthatoutboys[OE.lastEvent[1]]()
end

Input.keyCodes = {
    CONTROL_LEFT = 29,
    CONTROL_RIGHT = 157,
    SHIFT_LEFT = 42,
    SHIFT_RIGHT = 54,
    ALT_LEFT = 56,
    ALT_RIGHT = 184,
    WINDOWS = 219,
    ONE = 2,
    TWO = 3,
    THREE = 4,
    FOUR = 5,
    FIVE = 6,
    SIX = 7,
    SEVEN = 8,
    EIGHT = 9,
    NINE = 10,
    ZERO = 11,
    A = 30,
    B = 48,
    C = 46,
    D = 32,
    E = 18,
    F = 33,
    G = 34,
    H = 35,
    I = 23,
    J = 36,
    K = 37,
    L = 38,
    M = 50,
    N = 49,
    O = 24,
    P = 25,
    Q = 16,
    R = 19,
    S = 31,
    T = 20,
    U = 22,
    V = 47,
    W = 17,
    X = 45,
    Y = 21,
    Z = 44,
    MINUS= 12,
    PLUS = 13,
    BACKSPACE = 14,
    TAB = 15,
    QUOTE_SINGLE = 26,
    EXCLAMATION = 27,
    ENTER = 28,
    QUOTE_DOUBLE = 40,
    COMMA = 51,
    DOT = 52,
    SPACE = 57,
    UP = 200,
    DOWN = 208,
    RIGHT = 205,
    LEFT = 203,
    FLOATLINE = 41
}

return Input