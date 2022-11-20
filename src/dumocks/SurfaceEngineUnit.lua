--- Surface engines require a surface to push off from. They support movement of ships across the ground or other
-- surfaces. Hover engines require an atmosphere to function, while vertical boosters provide more thrust and can
-- operate in space but consume space fuel.
--
-- Element class:
-- <ul>
--   <li>HoverEngineSmallGroup</li>
--   <li>HoverEngineMediumGroup</li>
--   <li>HoverEngineLargeGroup</li>
--   <li>AtmosphericVerticalBoosterXtraSmallGroup</li>
--   <li>AtmosphericVerticalBoosterSmallGroup</li>
--   <li>AtmosphericVerticalBoosterMediumGroup</li>
--   <li>AtmosphericVerticalBoosterLargeGroup</li>
-- </ul>
--
-- Extends: @{Element} &gt; @{Engine} &gt; @{FueledEngine}
-- @module SurfaceEngineUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockFueledEngine = require "dumocks.FueledEngine"

local CLASS_HOVER_S = "HoverEngineSmallGroup"
local CLASS_HOVER_M = "HoverEngineMediumGroup"
local CLASS_HOVER_L = "HoverEngineLargeGroup"
local CLASS_VERTICAL_XS = "AtmosphericVerticalBoosterXtraSmallGroup"
local CLASS_VERTICAL_S = "AtmosphericVerticalBoosterSmallGroup"
local CLASS_VERTICAL_M = "AtmosphericVerticalBoosterMediumGroup"
local CLASS_VERTICAL_L = "AtmosphericVerticalBoosterLargeGroup"

local elementDefinitions = {}
elementDefinitions["basic hover engine s"] = {mass = 56.91, maxHitPoints = 50.0, itemId = 2333052331, class = CLASS_HOVER_S, maxThrust = 50000.0, maxDistance = 30.0}
elementDefinitions["basic vertical booster xs"] = {mass = 22.7, maxHitPoints = 50.0, itemId = 3775402879, class = CLASS_VERTICAL_XS, maxThrust = 15000.0, maxDistance = 30}
local DEFAULT_ELEMENT = "basic hover engine s"

local M = MockFueledEngine:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockFueledEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.maxThrustBase = elementDefinition.maxThrust
    o.currentMaxThrust = o.maxThrustBase
    o.currentMinThrust = 0

    o.maxDistance = elementDefinition.maxDistance or 0
    o.distance = -1

    return o
end

--- Returns the distance to the first object detected in the direction of the thrust.
-- @treturn float The distance to the first obstacle in meters or -1 if nothing closer than max distance.
function M:getDistance()
    if self.distance > self.maxDistance or self.distance < 0 then
        return -1
    end
    return self.distance
end

--- Returns the maximum functional distance from the ground.
-- @treturn float The maximum functional distance in meters.
function M:getMaxDistance()
    return self.maxDistance
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockFueledEngine.mockGetClosure(self)
    closure.getDistance = function() return self:getDistance() end
    closure.getMaxDistance = function() return self:getMaxDistance() end
    return closure
end

return M