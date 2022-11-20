--- Abstract class to define functions common to engines. Many methods found here are deprecated for the general engine
-- type, though more specific engine unites may re-implement them for their type.
--
-- Element class: <none>
--
-- Extends: @{Element}
--
-- Extended by:
-- <ul>
--   <li>@{AdjustorUnit}</li>
--   <li>@{AirfoilUnit}</li>
--   <li>@{BrakeUnit}</li>
--   <li>@{FueledEngine}</li>
-- </ul>
-- @module Engine
-- @alias M

local MockElement = require "dumocks.Element"

local M = MockElement:new()
M.helperId = "engine_unit"
M.widgetType = "engine_unit"

function M:new(o, id, elementDefinition)
    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.maxThrustBase = 0
    o.currentMaxThrust = 0
    o.currentThrust = 0

    o.obstructionFactor = 0
    o.tags = ""
    o.ignoringTags = false

    return o
end

local DATA_TEMPLATE =
    '{"helperId":"%s","type":"%s","name":"%s","currentMaxThrust":%f,"currentThrust":%f,"maxThrustBase":%f}'
--- Get element data as JSON.
--
-- Engines have an <code>engine_unit</code> widget, which contains the following fields (bold fields are visible when
-- making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">currentThrust</span></b> (<span class="type">float</span>) Current thrust in
--     newtons.</li>
--   <li><b><span class="parameter">currentMaxThrust</span></b> (<span class="type">float</span>) Current max thrust in
--     newtons.</li>
--   <li><b><span class="parameter">maxThrustBase</span></b> (<span class="type">float</span>) Max thrust under ideal
--     conditions in newtons.</li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>engine_unit</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>engine_unit</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    local currentMaxThrust = self.currentMaxThrust
    local currentThrust = self.currentThrust
    local maxThrustBase = self.maxThrustBase
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, currentMaxThrust,
                            currentThrust, maxThrustBase)
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Returns the obstruction ratio of the engine exhaust by elements and voxels. The more obstructed the engine is, the
-- less properly it will work. Try to fix your design if this is the case.
-- @treturn float The obstruction ratio of the engine.
function M:getObstructionFactor()
    return self.obstructionFactor
end

--- Returns the tags of the engine.
-- @treturn string Tags of the engine, in a CSV string.
function M:getTags()
    return self.tags
end

--- Set the tags of the engine.
-- @tparam string tags The CSV string of the tags.
-- @tparam bool ignore True to ignore the default engine tags.
function M:setTags(tags, ignore)
    self.tags = tags
    -- accepts 1 or true, as well as anything parseable as a whole number besides 0
    local numberIgnore = tonumber(ignore)
    self.ignoringTags = (ignore == true) or (numberIgnore and numberIgnore ~= 0 and numberIgnore % 1 == 0) or false
end

--- Checks if the engine is ignoring default tags.
-- @treturn 0/1 1 if the engine ignores default engine tags.
function M:isIgnoringTags()
    if self.ignoringTags then
        return 1
    end
    return 0
end

--- <b>Deprecated:</b> Switches the engine on.
--
-- This method is deprecated: element-specific methods should be used instead.
function M:activate()
    M.deprecated("activate")
end

--- <b>Deprecated:</b> Switches the engine off.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
function M:deactivate()
    M.deprecated("deactivate")
end

--- <b>Deprecated:</b> Returns the activation state of the engine.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn 0/1 1 when the engine is on, 0 otherwise.
function M:getState()
    M.deprecated("getState")
end

--- <b>Deprecated:</b> Toggle the state of the engine.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
function M:toggle()
    M.deprecated("toggle")
end

--- <b>Deprecated:</b> Set the engine thrust between 0 and maxThrust.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @tparam Newton thrust The engine thrust.
function M:setThrust(thrust)
    M.deprecated("setThrust")
end

--- <b>Deprecated:</b> Returns the maximal thrust the engine can deliver in principle, under optimal conditions. Note
-- that the actual maxThrust will most of the time be less than maxThrustBase.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn Newton The base max thrust.
function M:getMaxThrustBase()
    M.deprecated("getMaxThrustBase")
end

--- <b>Deprecated:</b> Returns the maximal thrust the engine can deliver at the moment, which might depend on various
-- conditions like atmospheric density, obstruction, orientation, etc. The actual thrust will be anything below this
-- maxThrust, which defines the current max capability of the engine.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn Newton The current max thrust.
function M:getMaxThrust()
    M.deprecated("getMaxThrust")
end

--- <b>Deprecated:</b> Returns the minimal thrust the engine can deliver at the moment (can be more than zero), which
-- will depend on various conditions like atmospheric density, obstruction, orientation, etc. Most of the time, this
-- will be 0 but it can be greater than 0, particularly for ailerons, in which case the actual thrust will be at least
-- equal to minThrust.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn Newton The current min thrust.
function M:getMinThrust()
    M.deprecated("getMinThrust")
end

--- <b>Deprecated:</b> Returns the ratio between the current MaxThrust and the base MaxThrust.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @return Usually 1 but can be lower for certain engines.
function M:getMaxThrustEfficiency()
    M.deprecated("getMaxThrustEfficiency")
end

--- <b>Deprecated:</b> Returns the current thrust level of the engine.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn Newton The thrust the engine is currently delivering.
function M:getThrust()
    M.deprecated("getThrust")
end

--- <b>Deprecated:</b> Returns the engine torque axis.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn vec3 The torque axis in world coordinates.
function M:torqueAxis()
    M.deprecated("torqueAxis")
end

--- <b>Deprecated:</b> Returns the engine thrust direction.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn vec3 The engine thrust direction in world coordinates.
function M:thrustAxis()
    M.deprecated("thrustAxis")
end

--- <b>Deprecated:</b> Returns the distance to the first object detected in the direction of the thrust.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn meter The distance to the first obstacle.
function M:getDistance()
    M.deprecated("getDistance")
end

--- <b>Deprecated:</b> Is the engine out of fuel?
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn bool 1 when there is no fuel left, 0 otherwise.
function M:isOutOfFuel()
    M.deprecated("isOutOfFuel")
end

--- <b>Deprecated:</b> Is the engine linked to a functional fuel tank?
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn bool 1 when linked tank is functional, 0 otherwise.
function M:hasFunctionalFuelTank()
    M.deprecated("hasFunctionalFuelTank")
end

--- <b>Deprecated:</b> The engine rate of fuel consumption per newton delivered per second.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn m3/(N.s) How many litres of fuel per newton per second.
function M:getCurrentFuelRate()
    M.deprecated("getCurrentFuelRate")
end

--- <b>Deprecated:</b> Returns the ratio between the current fuel rate and the theoretical nominal fuel rate.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @return Usually 1 but can be higher for certain engines at certain speeds.
function M:getFuelRateEfficiency()
    M.deprecated("getFuelRateEfficiency")
end

--- <b>Deprecated:</b> The time needed for the engine to reach 50% of its maximal thrust (all engines do not instantly
-- reach the thrust that is set for them, but they can take time to "warm up" to the final value).
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn second The time to half thrust.
function M:getT50()
    M.deprecated("getT50")
end

--- <b>Deprecated:</b> The current rate of fuel consumption.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
-- @treturn m3/s How many cubic meters of fuel per unit of time.
function M:getFuelConsumption()
    M.deprecated("getFuelConsumption")
end

--- <b>Deprecated:</b> Set the value of a signal in the specified IN plug of the element.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
--
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    M.deprecated("setSignalIn")
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- The general engine version of this method is deprecated: check the more specific unit type for a new implementation.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
--
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    M.deprecated("getSignalIn")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getObstructionFactor = function() return self:getObstructionFactor() end
    closure.getTags = function() return self:getTags() end
    closure.setTags = function(tags, ignore) return self:setTags(tags, ignore) end
    closure.isIgnoringTags = function() return self:isIgnoringTags() end

    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.getState = function() return self:getState() end
    closure.toggle = function() return self:toggle() end
    closure.setThrust = function(thrust) return self:setThrust(thrust) end
    closure.getMaxThrustBase = function() return self:getMaxThrustBase() end
    closure.getMaxThrust = function() return self:getMaxThrust() end
    closure.getMinThrust = function() return self:getMinThrust() end
    closure.getMaxThrustEfficiency = function() return self:getMaxThrustEfficiency() end
    closure.getThrust = function() return self:getThrust() end
    closure.torqueAxis = function() return self:torqueAxis() end
    closure.thrustAxis = function() return self:thrustAxis() end
    closure.getDistance = function() return self:getDistance() end
    closure.isOutOfFuel = function() return self:isOutOfFuel() end
    closure.hasFunctionalFuelTank = function() return self:hasFunctionalFuelTank() end
    closure.getCurrentFuelRate = function() return self:getCurrentFuelRate() end
    closure.getFuelRateEfficiency = function() return self:getFuelRateEfficiency() end
    closure.getT50 = function() return self:getT50() end
    closure.getFuelConsumption = function() return self:getFuelConsumption() end
    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M