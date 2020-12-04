--- An engine is capable to produce a force and/or a torque to move your construct.
--
-- Applies to engines, ailerons, wings, stabilizers, adjustors, etc.
--
-- Element class:
-- <ul>
--   <li>Hovercraft</li>
--   <li>VerticalBooster</li>
--   <li>Spacebrake</li>
--   <li>Airbrake</li>
--   <li>Wing2</li>
--   <li>Aileron2</li>
--   <li>Stabilizer</li>
--   <li>Adjustor</li>
--   <li>AtmosphericEngine<Size>Group</li>
--   <li>SpaceEngine<Size>Group</li>
--   <li>RocketEngine</li>
-- </ul>
--
-- Displayed widget fields:
-- <ul>
--   <li>currentMaxThrust</li>
--   <li>currentThrust</li>
--   <li>maxThrustBase</li>
-- </ul>
--
-- Extends: Element &gt; ElementWithState &gt; ElementWithToggle
-- @see Element
-- @see ElementWithState
-- @see ElementWithToggle
-- @module EngineUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local CLASS_HOVER = "Hovercraft"
local CLASS_BOOSTER = "VerticalBooster"
local CLASS_SPACEBRAKE = "Spacebrake"
local CLASS_AIRBRAKE = "Airbrake"
local CLASS_WING2 = "Wing2"
local CLASS_AILERON2 = "Aileron2"
local CLASS_STABILIZER = "Stabilizer"
local CLASS_ADJUSTOR = "Adjustor"
local CLASS_ATMO_XS = "AtmosphericEngineXtraSmallGroup"
local CLASS_ATMO_S = "AtmosphericEngineSmallGroup"
local CLASS_SPACE_XS = "SpaceEngineXtraSmallGroup"
local CLASS_SPACE_S = "SpaceEngineSmallGroup"
local CLASS_ROCKET = "RocketEngine"

local elementDefinitions = {}
elementDefinitions["hover engine s"] = {mass = 56.91, maxHitPoints = 53.0, class = CLASS_HOVER}
elementDefinitions["vertical booster s"] = {mass = 102.0, maxHitPoints = 50.0, class = CLASS_BOOSTER}
elementDefinitions["retro-rocket brake s"] = {mass = 137.55, maxHitPoints = 50.0, class = CLASS_SPACEBRAKE}
elementDefinitions["atmospheric airbrake s"] = {mass = 55.55, maxHitPoints = 50.0, class = CLASS_AIRBRAKE}
elementDefinitions["atmospheric airbrake l"] = {mass = 1501.55, maxHitPoints = 767.0, class = CLASS_AIRBRAKE}
elementDefinitions["wing xs"] = {mass = 61.2, maxHitPoints = 50.0, class = CLASS_WING2}
elementDefinitions["compact aileron xs"] = {mass = 61.2, maxHitPoints = 50.0, class = CLASS_AILERON2}
elementDefinitions["aileron xs"] = {mass = 122.4, maxHitPoints = 50.0, class = CLASS_AILERON2}
elementDefinitions["stabilizer xs"] = {mass = 69.88, maxHitPoints = 50.0, class = CLASS_STABILIZER}
elementDefinitions["adjustor xs"] = {mass = 22.7, maxHitPoints = 50.0, class = CLASS_ADJUSTOR}
elementDefinitions["basic atmospheric engine xs"] = {mass = 101.88, maxHitPoints = 50.0, class = CLASS_ATMO_XS}
elementDefinitions["basic space engine xs"] = {mass = 146.23, maxHitPoints = 50.0, class = CLASS_SPACE_XS}
elementDefinitions["basic space engine s"] = {mass = 761.74, maxHitPoints = 221.0, class = CLASS_SPACE_S}
elementDefinitions["rocket engine s"] = {mass = 223.76, maxHitPoints = 113.0, class = CLASS_ROCKET}
local DEFAULT_ELEMENT = "hover engine s"

local M = MockElementWithToggle:new()
M.helperId = "engine_unit"
M.widgetType = "engine_unit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    self.elementClass = elementDefinition.class

    return o
end

local DATA_TEMPLATE =
    '{"helperId":"%s","type":"%s","name":"%s [%d]","currentMaxThrust":%f,"currentThrust":%f,"maxThrustBase":%f}'
function M:getData()
    local currentMaxThrust = 0
    local currentThrust = 0
    local maxThrustBase = 0
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, self:getId(), currentMaxThrust,
                            currentThrust, maxThrustBase)
end

-- Override default with realistic patten to id.
function M:getDataId()
    if self.elementClass == CLASS_ITEM then
        return MockElement:getDataId()
    end
    return "e123456"
end

--- Set the engine thrust between 0 and maxThrust.
-- @tparam Newton thrust The engine thrust.
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
function M:getMaxThrust()
end

--- Returns the minimal thrust the engine can deliver at the moment (can be more than zero), which will depend on
-- various conditions like atmospheric density, obstruction, orientation, etc. Most of the time, this will be 0 but it
-- can be greater than 0, particularly for ailerons, in which case the actual thrust will be at least equal to
-- minThrust.
-- @treturn Newton THe current min thrust.
function M:getMinThrust()
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
function M:distance()
end

--- Is the engine out of fuel?
-- @treturn bool 1 when there is no fuel left, 0 otherwise.
function M:isOutOfFuel()
end

--- Is the engine linked to a broken fuel tank?
-- @treturn bool 1 when linked tank is broken, 0 otherwise.
function M:hasBrokenFuelTank()
end

--- <b>Deprecated:</b> The engine rate of fuel consumption per newton delivered per second.
--
-- This method is deprecated: getCurrentFuelRate should be used instead.
-- @see getCurrentFuelRate
-- @treturn m3/(N.s) How many litres of fuel per newton per second.
function M:getFuelRate()
    local message = "Warning: method getFuelRate is deprecated, use getCurrentFuelRate instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
    return self:getCurrentFuelRate()
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


--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
--
-- @param plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        local value = tonumber(state)
        if type(value) ~= "number" then
            value = 0.0
        end

        -- todo, determine behavior

        if value <= 0 then
            self.plugIn = 0
        elseif value >= 1.0 then
            self.plugIn = 1.0
        else
            self.plugIn = value
        end
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
--
-- @param plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        -- clamp to valid values
        local value = tonumber(self.plugIn)
        if type(value) ~= "number" then
            return 0.0
        elseif value >= 1.0 then
            return 1.0
        elseif value <= 0.0 then
            return 0.0
        else
            return value
        end
    end
    return MockElement.getSignalIn(self)
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.setThrust = function(thrust) return self:setThrust(thrust) end
    closure.getMaxThrustBase = function() return self:getMaxThrustBase() end
    closure.getMaxThrust = function() return self:getMaxThrust() end
    closure.getMinThrust = function() return self:getMinThrust() end
    closure.getMaxThrustEfficiency = function() return self:getMaxThrustEfficiency() end
    closure.getThrust = function() return self:getThrust() end
    closure.torqueAxis = function() return self:torqueAxis() end
    closure.thrustAxis = function() return self:thrustAxis() end
    closure.distance = function() return self:distance() end
    closure.isOutOfFuel = function() return self:isOutOfFuel() end
    closure.hasBrokenFuelTank = function() return self:hasBrokenFuelTank() end
    closure.getFuelRate = function() return self:getFuelRate() end
    closure.getCurrentFuelRate = function() return self:getCurrentFuelRate() end
    closure.getFuelRateEfficiency = function() return self:getFuelRateEfficiency() end
    closure.getT50 = function() return self:getT50() end
    closure.isObstructed = function() return self:isObstructed() end
    closure.getObstructionFactor = function() return self:getObstructionFactor() end
    closure.getTags = function() return self:getTags() end
    closure.setTags = function(tags) return self:setTags(tags) end
    closure.getFuelConsumption = function() return self:getFuelConsumption() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M