--- Counter unit.
-- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received on
-- its IN plug.
-- @module CounterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["counter 2"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 2}
-- TODO others
local DEFAULT_ELEMENT = "counter 2"

local M = MockElement:new()
M.elementClass = "CounterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    -- TODO indexed at 0 or 1? assuming 1
    o.activeOut = 1
    o.maxCount = elementDefinition.maxCount

    return o
end

--- Returns the rank of the currently active OUT plug.
-- @return The index of the active plug.
function M:getCounterState()
    return self.activeOut
end

--- Moves the counter one step further (equivalent to signal received on the IN plug).
function M:next()
    -- mod resets to 0 when max reached, add 1 after for 1-index
    self.activeOut = (self.activeOut % self.maxCount) + 1
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getCounterState = function() return self:getCounterState() end
    closure.next = function() return self:next() end
    return closure
end

return M