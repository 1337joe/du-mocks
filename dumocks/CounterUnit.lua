--- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received
-- on its IN plug.
-- @module CounterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["counter 2"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 2}
elementDefinitions["counter 3"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 3}
elementDefinitions["counter 5"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 5}
elementDefinitions["counter 7"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 7}
elementDefinitions["counter 10"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 10}
local DEFAULT_ELEMENT = "counter 2"

local M = MockElement:new()
M.elementClass = "CounterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.activeOut = 0 -- indexed at 0
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
    self.activeOut = (self.activeOut + 1) % self.maxCount
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