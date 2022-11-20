--- Abstract class to define functions common to fueled engines.
--
-- Element class: <none>
--
-- Extends: @{Element} &gt; @{Engine}
-- <ul>
--   <li>@{SurfaceEngineUnit}</li>
--   <li>@{EngineUnit}</li>
-- </ul>
-- @module FueledEngine
-- @alias M

local MockEngine = require "dumocks.Engine"

local M = MockEngine:new()

function M:new(o, id, elementDefinition)
    o = o or MockEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    return o
end

--- Start the engine at full power (works only when run inside a cockpit or under remote control).
function M:activate()
end

--- Stops the engine (works only when run inside a cockpit or under remote control).
function M:deactivate()
end

--- Checks if the engine is active.
-- @treturn 0/1 1 when the engine is on.
function M:isActive()
end

--- <b>Deprecated:</b> Returns the activation state of the engine.
--
-- This method is deprecated: isActive should be used instead
-- @see isActive
-- @treturn 0/1 1 when the engine is on, 0 otherwise.
function M:getState()
    M.deprecated("getState", "isActive")
    return M:isActive()
end

--- Toggle the state of the engine.
function M:toggle()
end

--- Set the thrust of the engine.
-- @tparam float thrust The engine thrust in newtons (limited by the maximum thrust).
function M:setThrust(thrust)
    self.currentThrust = math.max(self.currentMaxThrust, thrust)
end

--- Returns the current thrust of the engine.
-- @treturn float The current thrust of the engine in newtons.
function M:getThrust()
    return self.currentThrust
end

--- Returns the maximal thrust the engine can deliver in principle, under optimal conditions. Note that the actual
-- current max thrust will most of the time be less than the max thrust.
-- @treturn float The base max thrust of the engine in newtons.
function M:getMaxThrust()
    return self.maxThrustBase
end

--- Returns the minimal thrust the engine can deliver at the moment (can be more than zero), which will depend on
-- various conditions like atmospheric density, obstruction, orientataion, etc. Most of the time, this will be 0 but it
-- can be greater than 0.
-- @treturn float The current min engine thrust in newtons.
function M:getCurrentMinThrust()
    return self.currentMinThrust
end

--- Returns the maximal thrust the engine can deliver at the moment, which might depend on various conditions like
-- atmospheric density, obstruction, orientataion, etc. The actual thrust will be anything below this maxThrust, which
-- defines the current max capability of the engine.
-- @treturn float The current max engine thrust in newtons.
function M:getCurrentMaxThrust()
    return self.currentMaxThrust
end

--- Returns the ratio between the current maximum thrust and the optimal maximum thrust.
-- @treturn float Usually 1 but can be lower for certain engines.
function M:getMaxThrustEfficiency()
end

--- Checks if the torque generation is enabled on the engine.
-- @treturn 0/1 1 if the torque is enabled on the engine.
function M:isTorqueEnabled()
end

--- Sets the torque generation state on the engine.
-- @tparam bool state True to enable the torque generation.
function M:enableTorque(state)
end

--- Returns the engine thrust direction in construct local coordinates.
-- @treturn vec3 The engine thrust direction vector in construct local coordinates.
function M:getThrustAxis()
end

--- Returns the engine torque axis in construct local coordinates.
-- @treturn vec3 The torque axis vector in construct local coordinates.
function M:getTorqueAxis()
end

--- Returns the engine thrust direction in world coordinates.
-- @treturn vec3 The engine thrust direction vector in world coordinates.
function M:getWorldThrustAxis()
end

--- Returns the engine torque axis in world coordinates.
-- @treturn vec3 The torque axis vector in world coordinates.
function M:getWorldTorqueAxis()
end

--- Checks if the engine is out of fuel.
-- @treturn 0/1 1 when there is no fuel left, 0 otherwise.
function M:isOutOfFuel()
end

--- Returns the item ID of the fuel currently used by the engine.
-- @treturn int The item ID of the fuel currently used.
function M:getFuelId()
end

--- Returns the local ID of the fueltank linked to the engine.
-- @treturn int The local ID of the fueltank.
function M:getFuelTankId()
end

--- <b>Deprecated:</b> Is the engine linked to a broken fuel tank?
--
-- This method is deprecated: hasFunctionalFuelTank should be used instead
-- @see hasFunctionalFuelTank
-- @treturn bool 1 when linked tank is broken, 0 otherwise.
function M:hasBrokenFuelTank()
    M.deprecated("hasBrokenFuelTank", "hasFunctionalFuelTank")
    if self:hasFunctionalFuelTank() then
        return 0
    end
    return 1
end

--- Checks if the engine is linked to a functional fuel tank (not broken or colliding).
-- @treturn 0/1 1 when the linked tank is functional, 0 otherwise.
function M:hasFunctionalFuelTank()
end

--- Returns the engine fuel consumption rate per newton of thrust delivered per second.
-- @treturn float The current rate of fuel consumption in m3/(N.s).
function M:getCurrentFuelRate()
end

--- Returns the ratio between the current fuel rate and the theoretical nominal fuel rate.
-- @treturn float Usually 1 but can be higher for certain engines at certain speeds.
function M:getFuelRateEfficiency()
end

--- Returns the fuel consumption rate.
-- @treturn float The rate of fuel consumption in m3/s.
function M:getFuelConsumption()
end

--- Returns the T50: the time needed for the engine to reach 50% of its maximal thrust. All engines do not instantly
-- reach the thrust that is set for them; they can take time to "warm up" to the final value.
-- @treturn float The time to half thrust in seconds.
function M:getWarmupTime()
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
    closure.isTorqueEnabled = function() return self:isTorqueEnabled() end
    closure.enableTorque = function(state) return self:enableTorque(state) end
    closure.getThrustAxis = function() return self:getThrustAxis() end
    closure.getTorqueAxis = function() return self:getTorqueAxis() end
    closure.getWorldThrustAxis = function() return self:getWorldThrustAxis() end
    closure.getWorldTorqueAxis = function() return self:getWorldTorqueAxis() end
    closure.isOutOfFuel = function() return self:isOutOfFuel() end
    closure.getFuelId = function() return self:getFuelId() end
    closure.getFuelTankId = function() return self:getFuelTankId() end
    closure.hasBrokenFuelTank = function() return self:hasBrokenFuelTank() end
    closure.hasFunctionalFuelTank = function() return self:hasFunctionalFuelTank() end
    closure.getCurrentFuelRate = function() return self:getCurrentFuelRate() end
    closure.getFuelRateEfficiency = function() return self:getFuelRateEfficiency() end
    closure.getFuelConsumption = function() return self:getFuelConsumption() end
    closure.getWarmupTime = function() return self:getWarmupTime() end
    return closure
end

return M