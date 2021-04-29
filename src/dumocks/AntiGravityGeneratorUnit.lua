--- Generates graviton condensates to power anti-gravity pulsors.
--
-- Element class: AntiGravityGeneratorUnit
--
-- Extends: Element &gt; ElementWithState &gt; ElementWithToggle
-- @see Element
-- @see ElementWithState
-- @see ElementWithToggle
-- @module AntiGravityGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["anti-gravity generator s"] = {mass = 27134.86, maxHitPoints = 43117.0}
elementDefinitions["anti-gravity generator m"] = {mass = 137716.32, maxHitPoints = 304568.0}
-- elementDefinitions["anti-gravity generator l"] = {mass = , maxHitPoints = }
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

local DATA_TEMPLATE = '{"antiGPower":%.17f,"antiGravityField":%.16f,"baseAltitude\":%f,\"helperId\":\"antigravity_generator'..
    '\",\"name\":\"%s [%d]\",\"showError\":false,\"type\":\"%s\"}'
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
function M:getData()
    return string.format(DATA_TEMPLATE, self.antiGravityPower, self.antiGravityField, self.baseAltitude, self.name, self:getId(), self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Sets the base altitude for the anti-gravity field.
-- @tparam m altitude The desired altitude. It will be reached with a slow acceleration (not instantaneous).
function M:setBaseAltitude(altitude)
    altitude = math.max(AG_MIN_BASE_ALTITUDE, altitude)
    self.targetAltitude = altitude
end

--- Return the base altitude for the anti-gravity field.
--
-- Note: This is the altitude that the anti-gravity generator is currently trying to hold at. It will adjust slowly
-- to match the altitude provided to setBaseAltitude but will not instantly reflect the value set.
-- @treturn m The base altitude.
function M:getBaseAltitude()
    return self.baseAltitude
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (has no actual effect on agg state when modified this way).</li>
-- </ul>
-- @param plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        local value = tonumber(state)
        if type(value) ~= "number" then
            value = 0.0
        end

        -- expected behavior, but in fact nothing happens in-game
        if value > 0.0 then
            -- self:activate()
        else
            -- self:deactivate()
        end

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
    closure.setBaseAltitude = function(altitude) return self:setBaseAltitude(altitude) end
    closure.getBaseAltitude = function() return self:getBaseAltitude() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M