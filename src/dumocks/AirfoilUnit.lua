--- Airfoils are aerodynamic elements that produce a lift force according to their aerodynamic profile as wings,
-- stabilizers, and ailerons.
--
-- Element class:
-- <ul>
--   <li>Aileron2</li>
--   <li>Stabilizer</li>
--   <li>Wing2</li>
-- </ul>
--
-- Extends: @{Element} &gt; @{Engine}
-- @module AirfoilUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockEngine = require "dumocks.Engine"

local CLASS_AILERON = "Aileron2"
local CLASS_STABILIZER = "Stabilizer"
local CLASS_WING = "Wing2"

local elementDefinitions = {}
elementDefinitions["compact aileron xs"] = {mass = 61.2, maxHitPoints = 50.0, itemId = 2334843027, class = CLASS_AILERON, maxLift = 50000.0}
elementDefinitions["aileron xs"] = {mass = 122.4, maxHitPoints = 50.0, itemId = 2292270972, class = CLASS_AILERON, maxLift = 100000.0}
elementDefinitions["compact aileron s"] = {mass = 319.15, maxHitPoints = 211.0, itemId = 1923840124, class = CLASS_AILERON, maxLift = 200000.0}
elementDefinitions["aileron s"] = {mass = 638.3, maxHitPoints = 423.0, itemId = 2737703104, class = CLASS_AILERON, maxLift = 400000.0}
elementDefinitions["compact aileron m"] = {mass = 1704.95, maxHitPoints = 1695.0, itemId = 4017253256, class = CLASS_AILERON, maxLift = 800000.0}
elementDefinitions["aileron m"] = {mass = 3409.9, maxHitPoints = 3391.0, itemId = 1856288931, class = CLASS_AILERON, maxLift = 1600000.0}
elementDefinitions["stabilizer xs"] = {mass = 69.88, maxHitPoints = 50.0, itemId = 1455311973, class = CLASS_STABILIZER, maxLift = 62500.0}
elementDefinitions["stabilizer s"] = {mass = 366.89, maxHitPoints = 225.0, itemId = 1234961120, class = CLASS_STABILIZER, maxLift = 250000.0}
elementDefinitions["stabilizer m"] = {mass = 2026.11, maxHitPoints = 4810.0, itemId = 3474622996, class = CLASS_STABILIZER, maxLift = 1000000.0}
elementDefinitions["stabilizer l"] = {mass = 11501.15, maxHitPoints = 60926.0, itemId = 1090402453, class = CLASS_STABILIZER, maxLift = 4000000.0}
elementDefinitions["wing xs"] = {mass = 61.2, maxHitPoints = 50.0, itemId = 1727614690, class = CLASS_WING, maxLift = 62500.0}
elementDefinitions["wing s"] = {mass = 319.15, maxHitPoints = 300.0, itemId = 2532454166, class = CLASS_WING, maxLift = 250000.0}
elementDefinitions["wing m"] = {mass = 1704.95, maxHitPoints = 1500.0, itemId = 404188468, class = CLASS_WING, maxLift = 1000000.0}
elementDefinitions["wing variant m"] = {mass = 1704.95, maxHitPoints = 1500.0, itemId = 4179758576, class = CLASS_WING, maxLift = 1000000.0}
local DEFAULT_ELEMENT = "aileron xs"

local M = MockEngine:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.maxThrustBase = elementDefinition.maxLift
    o.currentMaxThrust = o.maxThrustBase

    return o
end

--- Returns the current lift of the airfoil.
-- @treturn float The current lift of the airfoil.
function M:getLift()
    return self.currentThrust
end

--- Gives the maximum lift that the airfoil can generate, under optimal conditions. Note that the actual maximum lift
-- will most of the time be less than this value.
-- @treturn float The maximum lift of the airfoil in newtons.
function M:getMaxLift()
    return self.maxThrustBase
end

--- Returns the current drag of the airfoil.
-- @treturn float The current drag of the airfoil.
function M:getDrag()
end

--- The ratio between lift and drag, depending on the aerodynamic profile of the airfoil.
-- @treturn float The ration between lift and drag.
function M:getDragRatio()
end

--- Returns the minimal lift the airfoil can deliver at the moment (can be higher than zero), which will depend on
-- various conditions like velocity, atmospheric density, obstruction, orientation, etc. Most of the time, this will be
-- 0, but it can be greater than 0, particularly for ailerons, in which case the actual thrust will be at least equal
-- to minThrust.
-- @treturn float The current minimal airfoil lift in newtons.
function M:getCurrentMinLift()
end

--- Returns the maximal lift the airfoil can deliver at the moment, which might depend on various conditions like
-- velocity, atmospheric density, obstruction, orientation, etc. The actual lift will be anything below this maximum
-- lift, which devines the current max capability of the airfoil.
-- @treturn float The current maximal airfoil lift in newtons.
function M:getCurrentMaxLift()
end

--- Returns the ratio between the current maximum lift and the optimal maximum lift.
-- @treturn float Usually 1 but can be lower for certain airfoils.
function M:getMaxLiftEfficiency()
end

--- Returns the airfoil lift direction in construct local coordinates.
-- @treturn vec3 The airfoil lift direction vector in construct local coordinates.
function M:getLiftAxis()
end

--- Returns the airfoil torque axis in construct local coordinates.
-- @treturn vec3 The torque axis vector in construct local coordinates.
function M:getTorqueAxis()
end

--- Returns the airfoil lift direction in world coordinates.
-- @treturn vec3 The torque axis vector in world coordinates.
function M:getWorldLiftAxis()
end

--- Returns the airfoil torque axis in world coordinates.
-- @treturn vec3 The torque axis vector in world coordinates.
function M:getWorldTorqueAxis()
end

--- Checks if the airfoil is stalled.
-- @treturn 0/1 1 if the airfoil is stalled.
function M:isStalled()
end

--- Returns the airfoil stall angle.
-- @treturn float The stall angle of the airfoil in degrees.
function M:getStallAngle()
end

--- Returns the minimum angle to produce the maximum lift of the airfoil. Note that the airfoil will produce lift at a
-- lower angle but not optimally.
-- @treturn float The angle of the airfoil in degrees.
function M:getMinAngle()
end

---  Returns the maximum angle to produce the maximum lift of the airfoil. Note that the airfoil will produce lift at a
-- higher angle but not optimally.
-- @treturn float The angle of the airfoil in degrees.
function M:getMaxAngle()
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockEngine.mockGetClosure(self)
    closure.getLift = function() return self:getLift() end
    closure.getMaxLift = function() return self:getMaxLift() end
    closure.getDrag = function() return self:getDrag() end
    closure.getDragRatio = function() return self:getDragRatio() end
    closure.getCurrentMinLift = function() return self:getCurrentMinLift() end
    closure.getCurrentMaxLift = function() return self:getCurrentMaxLift() end
    closure.getMaxLiftEfficiency = function() return self:getMaxLiftEfficiency() end
    closure.getLiftAxis = function() return self:getLiftAxis() end
    closure.getTorqueAxis = function() return self:getTorqueAxis() end
    closure.getWorldLiftAxis = function() return self:getWorldLiftAxis() end
    closure.getWorldTorqueAxis = function() return self:getWorldTorqueAxis() end
    closure.isStalled = function() return self:isStalled() end
    closure.getStallAngle = function() return self:getStallAngle() end
    closure.getMinAngle = function() return self:getMinAngle() end
    closure.getMaxAngle = function() return self:getMaxAngle() end
    return closure
end

return M