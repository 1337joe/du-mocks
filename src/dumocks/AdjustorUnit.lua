--- Adjustors are specific motors that expel gas to generate torque on your construct.
--
-- Element class: Adjustor
--
-- Extends: @{Element} &gt; @{Engine}
-- @module AdjustorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockEngine = require "dumocks.Engine"

local elementDefinitions = {}
elementDefinitions["adjustor xs"] = {mass = 25.0, maxHitPoints = 50.0, itemId = 2648523849, maxThrust = 2000.0}
elementDefinitions["adjustor s"] = {mass = 100.0, maxHitPoints = 50.0, itemId = 47474508, maxThrust = 8000.0}
elementDefinitions["adjustor m"] = {mass = 450.0, maxHitPoints = 50.0, itemId = 3790013467, maxThrust = 32000.0}
elementDefinitions["adjustor l"] = {mass = 1550.0, maxHitPoints = 298.0, itemId = 2818864930, maxThrust = 128000.0}
local DEFAULT_ELEMENT = "adjustor xs"

local M = MockEngine:new()
M.elementClass = "Adjustor"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.maxThrustBase = elementDefinition.maxThrust
    o.currentMaxThrust = o.maxThrustBase

    o.plugIn = 0.0

    return o
end

--- Start the adjustor at full power (works only when run inside a cockpit or under remote control).
function M:activate()
end

--- Stops the adjustor (works only when run inside a cockpit or under remote control).
function M:deactivate()
end

--- Checks if the adjustor is active.
-- @treturn 0/1 1 when the adjustor is on.
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

--- Toggle the state of the adjustor.
function M:toggle()
end

--- Set the exhaust thrust of the adjustor.
-- @tparam float thrust The adjustor thrust in newtons (limited by the maximum thrust).
function M:setThrust(thrust)
    self.currentThrust = math.max(self.currentMaxThrust, thrust)
end

--- Returns the current exhaust thrust of the adjustor.
-- @treturn float The current exhaust thrust of the adjustor in newtons.
function M:getThrust()
    return self.currentThrust
end

--- Returns the maximal exhaust thrust the adjustor can deliver.
-- @treturn float The maximum exhaust thrust of the adjustor in newtons.
function M:getMaxThrust()
    return self.maxThrustBase
end

--- Returns the adjustor exhaust thrust direction in construct local coordinates.
-- @treturn vec3 The adjustor exhaust thrust direction vector in construct local coordinates.
function M:getThrustAxis()
end

--- Returns the adjustor torque axis in construct local coordinates.
-- @treturn vec3 The torque axis vector in construct local coordinates.
function M:getTorqueAxis()
end

--- Returns the adjustor exhaust thrust direction in world coordinates.
-- @treturn vec3 The adjustor exhaust thrust direction vector in world coordinates.
function M:getWorldThrustAxis()
end

--- Returns the adjustor torque axis in world coordinates.
-- @treturn vec3 The torque axis vector in world coordinates.
function M:getWorldTorqueAxis()
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
--
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- testing found no response to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
--
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
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
    closure.getThrustAxis = function() return self:getThrustAxis() end
    closure.getTorqueAxis = function() return self:getTorqueAxis() end
    closure.getWorldThrustAxis = function() return self:getWorldThrustAxis() end
    closure.getWorldTorqueAxis = function() return self:getWorldTorqueAxis() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end

    -- remove missing deprecated functions
    closure.getMaxThrustEfficiency = nil
    closure.getMinThrust = nil
    return closure
end

return M