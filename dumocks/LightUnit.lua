--- Emits a source of light
--
-- Element class: LightUnit
--
-- Extends: Element &gt; ElementWithState &gt; ElementWithToggle
-- @see Element
-- @see ElementWithState
-- @see ElementWithToggle
-- @module LightUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["square light xs"] = {mass = 70.05, maxHitPoints = 50.0}
elementDefinitions["square light s"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["square light m"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["square light l"] = {mass = 79.34, maxHitPoints = 57.0}
elementDefinitions["long light xs"] = {mass = 70.05, maxHitPoints = 50.0}
elementDefinitions["long light s"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["long light m"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["long light l"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["vertical light xs"] = {mass = 70.05, maxHitPoints = 50.0}
elementDefinitions["vertical light s"] = {mass = 79.34, maxHitPoints = 50.0}
elementDefinitions["vertical light m"] = {mass = 79.34, maxHitPoints = 62.0}
elementDefinitions["vertical light l"] = {mass = 371.80, maxHitPoints = 499.0}
elementDefinitions["headlight"] = {mass = 79.34, maxHitPoints = 50.0}
local DEFAULT_ELEMENT = "square light xs"

local M = MockElementWithToggle:new()
M.elementClass = "LightUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.plugIn = 0.0

    return o
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (has no actual effect on light state when modified this way).</li>
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

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M