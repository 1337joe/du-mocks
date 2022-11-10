--- Measures the distance to an obstacle in front of it.
--
-- Element class: TelemeterUnit
--
-- Extends: @{Element}
-- @module TelemeterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["telemeter xs"] = {mass = 40.79, maxHitPoints = 50.0, itemId = 1722901246}
local DEFAULT_ELEMENT = "telemeter xs"

local M = MockElement:new()
M.elementClass = "TelemeterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.distance = -1
    o.maxDistance = 100 -- m

    return o
end

--- <b>Deprecated:</b> Returns the distance to the first obstacle in front of the telemeter.
--
-- This method is deprecated: raycast().distance should be used instead
-- @see raycast
-- @treturn meter The distance to the obstacle. Returns -1 if there are no obstacles up to getMaxDistance.
function M:getDistance()
    M.deprecated("getDistance", "raycast().distance")
    return self:raycast().distance
end

--- Emits a raycast from the telemeter, returns a raycastHit object.
-- @treturn table A table with fields: {[bool] hit, [float] distance, [vec3] point}
function M:raycast()
    local distance = self.distance
    if distance > self.maxDistance or distance < 0 then
        distance = -1
    end
    return {hit = false, distance = distance, point = {0, 0, 0}}
end

--- Returns telemeter raycast origin in local construct coordinates.
-- @treturn vec3 The telemeter raycast origin.
function M:getRayOrigin()
end

--- Returns telemeter raycast origin in world coordinates.
-- @treturn vec3 The telemeter raycast origin.
function M:getRayWorldOrigin()
end

--- Returns telemeter raycast axis in local construct coordinates.
-- @treturn vec3 The telemeter raycast axis.
function M:getRayAxis()
end

--- Returns telemeter raycast axis in world coordinates.
-- @treturn vec3 The telemeter raycast axis.
function M:getRayWorldAxis()
end

--- Returns the max distance from which an obstacle can be detected (default is 100m).
-- @treturn float The max distance to detectable obstacles in meters.
function M:getMaxDistance()
    return self.maxDistance
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getDistance = function() return self:getDistance() end
    closure.raycast = function() return self:raycast() end
    closure.getRayOrigin = function() return self:getRayOrigin() end
    closure.getRayWorldOrigin = function() return self:getRayWorldOrigin() end
    closure.getRayAxis = function() return self:getRayAxis() end
    closure.getRayWorldAxis = function() return self:getRayWorldAxis() end
    closure.getMaxDistance = function() return self:getMaxDistance() end
    return closure
end

return M