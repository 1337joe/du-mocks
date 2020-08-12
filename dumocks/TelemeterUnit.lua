--- Telemeter unit.
-- Measures the distance to an obstacle in front of it.
-- @module TelemeterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
local DEFAULT_ELEMENT = "telemeter"

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.distance = -1
    o.maxDistance = 20 -- m

    return o
end

--- Returns the distance to the first obstacle in front of the telemeter.
-- @treturn meter The distance to the obstacle. Returns -1 if there are no obstacles up to getMaxDistance.
function M:getDistance()
    return self.distance
end

--- Returns the max distance from which an obstacle can be detected (default is 20m).
-- @treturn meter The max distance to detectable obstacles.
function M:getMaxDistance()
    return self.maxDistance
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getDistance = function() return self:getDistance() end
    closure.getMaxDistance = function() return self:getMaxDistance() end
    return closure
end

return M