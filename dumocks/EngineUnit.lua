--- Engine unit.
-- An engine is capable to produce a force and/or a torque to move your construct.
-- @module EngineUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["hover engine s"] = {mass = 56.91, maxHitPoints = 53.0}
elementDefinitions["atmo airbrake l"] = {mass = 1501.55, maxHitPoints = 767.0}
elementDefinitions["stabilizer xs"] = {mass = 69.88, maxHitPoints = 50.0}
local DEFAULT_ELEMENT = "hover engine s"

local M = MockElement:new()
M.elementClass = "Hovercraft" -- TODO different types have different classes, subclass further?

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Start the engine at full power (works only when run inside a cockpit or under remote control).
function M:activate()
    self.state = true
end

--- Stops the engine (works only when run inside a cockpit or under remote control).
function M:deactivate()
    self.state = false
end

--- Toggle the state of the engine.
function M:toggle()
    self.state = not self.state
end

--- Returns the state of activation of the anti-g generator.
-- @return 1 when the angi-g generator is started, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Set the engine thrust between 0 and maxThrust.
-- @tparam Newton thrust THe engine thrust.
function M:setThrust(thrust)
end

--- Returns the maximal thrust the engine can deliver in principle, under optimal conditions. Note that the actual
-- maxThrust will most of the time be less than maxThrustBase.
-- @treturn Newton The base max thrust.
function M:getMaxThrustBase()
end

--- Returns the maximal thrust the engine can deliver at the moment, which might depend on various conditions like
-- atmospheric density, obstruction, orientation, etc. The actual thrust will be anything below this maxThrust, which
-- defines the current max capability of the engine.
-- @treturn Newton The current max thrust.
function M:getCurrentMaxThrust()
end

--- Returns the minimal thrust the engine can deliver at the moment (can be more than zero), which will depend on
-- various conditions like atmospheric density, obstruction, orientation, etc. Most of the time, this will be 0 but it
-- can be greater than 0, particularly for ailerons, in which case the actual thrust will be at least equal to
-- minThrust.
-- @treturn Newton THe current min thrust.
function M:getCurrentMinThrust()
end

--- Returns the ratio between the current MaxThrust and the base MaxThrust.
-- @return Usually 1 but can be lower for certain engines.
function M:getMaxThrustEfficiency()
end

--- Returns the current thrust level of the engine.
-- @treturn Newton The thrust the engine is currently delivering.
function M:getThrust()
end

--- Returns the engine torque axis.
-- @treturn vec3 The torque axis in world coordinates.
function M:torqueAxis()
end

--- Returns the engine thrust direction.
-- @treturn vec3 The engine thrust direction in world coordinates.
function M:thrustAxis()
end

--- Returns the distance to the first object detected in the direction of the thrust.
-- @treturn meter The distance to the first obstacle.
function M:getDistanceToObstacle()
end

--- Is the engine out of fuel?
-- @treturn bool 1 when there is no fuel left, 0 otherwise.
function M:isOutOfFuel()
end

--- Is the engine linked to a broken fuel tank?
-- @treturn bool 1 when linked tank is broken, 0 otherwise.
function M:hasBrokenFuelTank()
end

--- The engine rate of fuel consumption per newton delivered per second.
-- @treturn m3/(N.s) How many litres of fuel per newton per second.
function M:getCurrentFuelRate()
end

--- Returns the ratio between the current fuel rate and the theoretical nominal fuel rate.
-- @return Usually 1 but can be higher for certain engines at certain speeds.
function M:getFuelRateEfficiency()
end

--- The time needed for the engine to reach 50% of its maximal thrust (all engines do not instantly reach the thrust
-- that is set for them, but they can take time to "warm up" to the final value).
-- @treturn second The time to half thrust.
function M:getT50()
end

--- If the engine exhaust is obstructed by some element or voxel material, it will stop working or may work randomly in
-- an instable way and you should probably fix your design.
-- @treturn bool 1 when the engine is obstructed.
function M:isObstructed()
end

--- Returns the obstruction ratio of the engine exhaust by elements and voxels. The more obstructed the engine is, the
-- less properly it will work. Try to fix your design if this is the case.
-- @return The obstruction ratio of the engine.
function M:getObstructionFactor()
end

--- Tags of the engine.
-- @treturn csv Tags of the engine, in a CSV string.
function M:getTags()
end

--- Set the tags of the engine.
-- @tparam string tags CSV string of the tags.
function M:setTags(tags)
end

--- The current rate of fuel consumption.
-- @treturn m3/s How many cubic meters of fuel per unit of time.
function M:getFuelConsumption()
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.toggle = function() return self:toggle() end
    closure.getState = function() return self:getState() end
    closure.setThrust = function(thrust) return self:setThrust(thrust) end
    closure.getMaxThrustBase = function() return self:getMaxThrustBase() end
    closure.getCurrentMaxThrust = function() return self:getCurrentMaxThrust() end
    closure.getCurrentMinThrust = function() return self:getCurrentMinThrust() end
    closure.getMaxThrustEfficiency = function() return self:getMaxThrustEfficiency() end
    closure.getThrust = function() return self:getThrust() end
    closure.torqueAxis = function() return self:torqueAxis() end
    closure.thrustAxis = function() return self:thrustAxis() end
    closure.getDistanceToObstacle = function() return self:getDistanceToObstacle() end
    closure.isOutOfFuel = function() return self:isOutOfFuel() end
    closure.hasBrokenFuelTank = function() return self:hasBrokenFuelTank() end
    closure.getCurrentFuelRate = function() return self:getCurrentFuelRate() end
    closure.getFuelRateEfficiency = function() return self:getFuelRateEfficiency() end
    closure.getT50 = function() return self:getT50() end
    closure.isObstructed = function() return self:isObstructed() end
    closure.getObstructionFactor = function() return self:getObstructionFactor() end
    closure.getTags = function() return self:getTags() end
    closure.setTags = function(tags) return self:setTags(tags) end
    closure.getFuelConsumption = function() return self:getFuelConsumption() end
    return closure
end

return M