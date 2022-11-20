--- Brakes are elements designed to produce thrust opposite to the movement of a construct. They can be used to slow
-- down your construct.
--
-- Element class:
-- <ul>
--   <li>Airbrake</li>
--   <li>Spacebrake</li>
-- </ul>
--
-- Extends: @{Element} &gt; @{Engine}
-- @module BrakeUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockEngine = require "dumocks.Engine"

local CLASS_ATMO = "Airbrake"
local CLASS_SPACE = "Spacebrake"

local elementDefinitions = {}
elementDefinitions["atmospheric airbrake s"] = {mass = 55.55, maxHitPoints = 50.0, itemId = 65048663, class = CLASS_ATMO, maxThrust = 50000.0}
elementDefinitions["atmospheric airbrake m"] = {mass = 285.25, maxHitPoints = 50.0, itemId = 2198271703, class = CLASS_ATMO, maxThrust = 500000.0}
elementDefinitions["atmospheric airbrake l"] = {mass = 1501.55, maxHitPoints = 767.0, itemId = 104971834, class = CLASS_ATMO, maxThrust = 5000000.0}
elementDefinitions["retro-rocket brake s"] = {mass = 137.55, maxHitPoints = 50.0, itemId = 3039211660, class = CLASS_SPACE, maxThrust = 100000.0}
elementDefinitions["retro-rocket brake m"] = {mass = 714.0, maxHitPoints = 199.0, itemId = 3243532126, class = CLASS_SPACE, maxThrust = 600000.0}
elementDefinitions["retro-rocket brake l"] = {mass = 3770.9, maxHitPoints = 1422.0, itemId = 1452351552, class = CLASS_SPACE, maxThrust = 3600000.0}
local DEFAULT_ELEMENT = "atmospheric airbrake s"

local M = MockEngine:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.maxThrustBase = elementDefinition.maxThrust
    o.currentMaxThrust = o.maxThrustBase

    return o
end

--- Start the brake at full power (works only when run inside a cockpit or under remote control).
function M:activate()
end

--- Stops the brake (works only when run inside a cockpit or under remote control).
function M:deactivate()
end

--- Checks if the brake is active.
-- @treturn 0/1 1 when the brake is on.
function M:isActive()
end

--- <b>Deprecated:</b> Returns the activation state of the brake.
--
-- This method is deprecated: isActive should be used instead
-- @see isActive
-- @treturn 0/1 1 when the brake is on, 0 otherwise.
function M:getState()
    M.deprecated("getState", "isActive")
    return M:isActive()
end

--- Toggle the state of the brake.
function M:toggle()
end

--- Set the thrust of the brake. Note that brakes can generate a force only in the movement opposite direction.
-- @tparam float thrust The brake thrust in newtons (limited by the maximum thrust).
function M:setThrust(thrust)
    self.currentThrust = math.max(self.currentMaxThrust, thrust)
end

--- Returns the current thrust of the brake.
-- @treturn float The thrust the brake is currently delivering in newtons.
function M:getThrust()
    return self.currentThrust
end

--- Returns the maximal thrust the brake can deliver in principle, under optimal conditions. Note that the actual
-- current max thrust will most of the time be less than the max thrust.
-- @treturn float The base max thrust of the brake in newtons.
function M:getMaxThrust()
    return self.maxThrustBase
end

--- Returns the minimal thrust the brake can deliver at the moment (can be more than zero), which will depend on
-- various conditions like atmospheric density, obstruction, orientataion, etc. Most of the time, this will be 0 but it
-- can be greater than 0.
-- @treturn float The current min brake thrust in newtons.
function M:getCurrentMinThrust()
    return self.currentMinThrust
end

--- Returns the maximal thrust the brake can deliver at the moment, which might depend on various conditions like
-- atmospheric density, obstruction, orientataion, etc. The actual thrust will be anything below this maxThrust, which
-- defines the current max capability of the brake.
-- @treturn float The current max brake thrust in newtons.
function M:getCurrentMaxThrust()
    return self.currentMaxThrust
end

--- Returns the ratio between the current maximum thrust and the optimal maximum thrust.
-- @treturn float Usually 1 but can be lower for certain brakes.
function M:getMaxThrustEfficiency()
end

--- Returns the brake thrust direction in construct local coordinates.
-- @treturn vec3 The brake thrust direction vector in construct local coordinates.
function M:getThrustAxis()
end

--- Returns the brake thrust direction in world coordinates.
-- @treturn vec3 The brake thrust direction vector in world coordinates.
function M:getWorldThrustAxis()
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockEngine.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.toggle = function() return self:toggle() end
    closure.setThrust = function(thrust) return self:setThrust(thrust) end
    closure.getThrust = function() return self:getThrust() end
    closure.getMaxThrust = function() return self:getMaxThrust() end
    closure.getCurrentMinThrust = function() return self:getCurrentMinThrust() end
    closure.getCurrentMaxThrust = function() return self:getCurrentMaxThrust() end
    closure.getMaxThrustEfficiency = function() return self:getMaxThrustEfficiency() end
    closure.getThrustAxis = function() return self:getThrustAxis() end
    closure.getWorldThrustAxis = function() return self:getWorldThrustAxis() end
    return closure
end

return M