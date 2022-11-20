--- Generates graviton condensates to power anti-gravity pulsors.
--
-- <p style="color:red;">Note: This is generated from patch notes and in-game codex and has not yet been tested
--   against the actual element. Accuracy not guaranteed.</p>
--
-- Element class: AntiGravityGeneratorUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module AntiGravityGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["anti-gravity generator s"] = {mass = 27134.86, maxHitPoints = 43117.0, itemId = 3997343699}
elementDefinitions["anti-gravity generator m"] = {mass = 137716.32, maxHitPoints = 304568.0, itemId = 233079829}
elementDefinitions["anti-gravity generator l"] = {mass = 550865.28, maxHitPoints = 2330350.0, itemId = 294414265}
local DEFAULT_ELEMENT = "anti-gravity generator s"

local M = MockElementWithToggle:new()
M.elementClass = "AntiGravityGeneratorUnit"
M.widgetType = "antigravity_generator"

local AG_MIN_BASE_ALTITUDE = 1000
local AG_ALTITUDE_RATE = 4 -- m/s

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.targetAltitude = 2000.0 -- m
    -- setting base altitude sets the target, the base altitude slowly adjusts to match it
    o.baseAltitude = 2000.0 -- m
    o.antiGravityPower = 0.0
    o.antiGravityField = 0.0

    o.plugIn = 0.0

    return o
end

--- Activate the anti-gravity generator.
function M:activate()
    self.state = true
end

--- Deactivate the anti-gravity generator.
function M:deactivate()
    self.state = false
end

--- Returns the state of activation of the anti-gravity generator.
-- @treturn 0/1 1 when the anti-gravity generator is started, 0 otherwise.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

local DATA_TEMPLATE = '{"antiGPower":%.17f,"antiGravityField":%.16f,"baseAltitude\":%f,\"helperId\":\"antigravity_generator'..
    '\",\"name\":\"%s\",\"showError\":%s,\"type\":\"%s\"}'
--- Get element data as JSON.
--
-- Anti-gravity generators have an <code>antigravity_generator</code> widget, which contains the following fields (bold
-- fields are visible when making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">antiGravityField</span></b> (<span class="type">float</span>) Field strength.</li>
--   <li><b><span class="parameter">antiGPower</span></b> (<span class="type">float</span>) Power as a fraction of
--     1.0.</li>
--   <li><b><span class="parameter">baseAltitude</span></b> (<span class="type">float</span>) Base altitude in
--     meters.</li>
--   <li><b><span class="parameter">showError</span></b> (<span class="type">boolean</span>) True if the error banner
--     should be shown, false otherwise.</li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>)
--     <code>antigravity_generator</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>antigravity_generator</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    return string.format(DATA_TEMPLATE, self.antiGravityPower, self.antiGravityField, self.baseAltitude, self.name,
        false, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Returns the field strength of the anti-gravitational field.
-- @treturn float The power of the anti-gravitational field in Es.
function M:getFieldStrength()
    return self.antiGravityField
end

--- Returns the current rate of compensation of the gravitational field.
-- @treturn float The current rate in percentage.
function M:getCompensationRate()
end

--- Returns the current power of the gravitational field.
-- @treturn float The current power in percentage.
function M:getFieldPower()
    return self.antiGravityPower
end

--- Returns the number of pulsors linked to the anti-gravity generator.
-- @treturn int The number of pulsors linked.
function M:getPulsorCount()
end

--- <b>Deprecated:</b> Sets the base altitude for the anti-gravity field.
--
-- This method is deprecated: setTargetAltitude should be used instead
-- @see setTargetAltitude
-- @tparam m altitude The desired altitude. It will be reached with a slow acceleration (not instantaneous).
function M:setBaseAltitude(altitude)
    M.deprecated("setBaseAltitude", "setTargetAltitude")
    return self:setTargetAltitude(altitude)
end

--- Sets the target altitude for the anti-gravity field. Cannot be called from @{system.EVENT_onFlush|system.onFlush}.
-- @tparam float altitude The target altitude in meters. It will be reached with a slow acceleration (not instantaneous).
function M:setTargetAltitude(altitude)
    altitude = math.max(AG_MIN_BASE_ALTITUDE, altitude)
    self.targetAltitude = altitude
end

--- Return the target altitude defined for the anti-gravitational field.
-- @treturn float The target altitude in meters.
function M:getTargetAltitude()
    return self.targetAltitude
end

--- Return the current base altitude for the anti-gravitational field.
--
-- Note: This is the altitude that the anti-gravity generator is currently trying to hold at. It will adjust slowly
-- to match the target altitude but will not instantly reflect the value set.
-- @treturn float The base altitude in meters.
function M:getBaseAltitude()
    return self.baseAltitude
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- no longer responds to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- Mock only, not in-game: Updates the base altitude to approach the target altitude at 4 m/s.
-- @tparam number seconds The number of seconds to move at 4 m/s.
function M:mockStepBaseAltitude(seconds)
    seconds = seconds or 1

    if self.baseAltitude < self.targetAltitude then
        self.baseAltitude = math.min(self.baseAltitude + AG_ALTITUDE_RATE * seconds, self.targetAltitude)
    elseif self.baseAltitude > self.targetAltitude then
        self.baseAltitude = math.max(self.baseAltitude - AG_ALTITUDE_RATE * seconds, self.targetAltitude)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.getFieldStrength = function() return self:getFieldStrength() end
    closure.getCompensationRate = function() return self:getCompensationRate() end
    closure.getFieldPower = function() return self:getFieldPower() end
    closure.getPulsorCount = function() return self:getPulsorCount() end
    closure.setBaseAltitude = function(altitude) return self:setBaseAltitude(altitude) end
    closure.setTargetAltitude = function(altitude) return self:setTargetAltitude(altitude) end
    closure.getTargetAltitude = function() return self:getTargetAltitude() end
    closure.getBaseAltitude = function() return self:getBaseAltitude() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M