local Input = {}
local Event = require("Event")
local kb = require("KeyBoard")
local args = {...}
local OE = args[1]

function Input.getButton(key)
    return kb.getKey(key)
end

function Input.getButtonDown(key)
    if OE.lastEvent[4] == key and OE.lastEvent[1] == "key_down" then
        return true
    else
        return false
    end
end

function Input.getButtonUp(key)
    if OE.lastEvent[4] == key and OE.lastEvent[1] == "key_up" then
        return true
    else
        return false
    end
end

OE.keyCode = {
    controlLeft = 29,
    controlRight = 157,
    shiftLeft = 42,
    shiftRight = 54,
    altLeft = 56,
    altRight = 184,
    windows = 219,
    one = 2,
    two = 3,
    three = 4,
    four = 5,
    five = 6,
    six = 7,
    seven = 8,
    eight = 9,
    nine = 10,
    zero = 11,
    a = 30,
    b = 48,
    c = 46,
    d = 32,
    e = 18,
    f = 33,
    g = 34,
    h = 35,
    i = 23,
    j = 36,
    k = 37,
    l = 38,
    m = 50,
    n = 49,
    o = 24,
    p = 25,
    q = 16,
    r = 19,
    s = 31,
    t = 20,
    u = 22,
    v = 47,
    w = 17,
    x = 45,
    y = 21,
    z = 44,
    minus= 12,
    plus = 13,
    backspace = 14,
    tab = 15,
    quoteSingle = 26,
    exclamation = 27,
    enter = 28,
    quoteOpen = 40,
    comma = 51,
    dot = 52,
    space = 57,
    up = 200,
    down = 208,
    right = 205,
    left = 203,
}

return Input