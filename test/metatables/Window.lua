Window = {}
-- create the prototype with default values
Window.prototype = {x=0, y=0, width=100, height=100, }
-- create a metatable
Window.mt = {}
-- declare the constructor function
function Window.new (o)
    setmetatable(o, Window.mt)
    return o
end

Window.mt.__index = function (table, key)
    return Window.prototype[key]
end

local w = Window.new{x=10, y=20}
print(w)    --> 100