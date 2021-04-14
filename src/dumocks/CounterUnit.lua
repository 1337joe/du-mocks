--- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received
-- on its IN plug.
--
-- Element Class: CounterUnit
--
-- Extends: Element
-- @see Element
-- @module CounterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["counter 2"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 2}
elementDefinitions["counter 3"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 3}
elementDefinitions["counter 5"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 5}
elementDefinitions["counter 7"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 7}
elementDefinitions["counter 10"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 10}
local DEFAULT_ELEMENT = "counter 2"

local M = MockElement:new()
M.elementClass = "CounterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.activeOut = 0 -- indexed at 0
    o.maxCount = elementDefinition.maxCount

    o.plugIn = 0.0

    return o
end

--- Returns the rank of the currently active OUT plug.
-- @return The index of the active plug.
function M:getCounterState()
    return self.activeOut % self.maxCount
end

--- Moves the counter one step further (equivalent to signal received on the IN plug).
function M:next()
    self.activeOut = (self.activeOut + 1) % self.maxCount
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @param plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        local value = tonumber(state)
        if type(value) ~= "number" then
            value = 0.0
        end

        if value ~= self.plugIn and value > 0.0 then
            self:next()
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

local OUT_SIGNAL_PATTERN = "OUT%-signal%-(%d+)"
--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"OUT-signal-&lt;i&gt;" where &lt;i&gt; is replaced by a number from 0 to the counter number minus 1 (so range of [0,4] for a 5 Counter).</li>
-- </ul>
-- @param plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    local plugIndex = tonumber(string.match(plug, OUT_SIGNAL_PATTERN))
    if plugIndex ~= nil and plugIndex >= 0 and plugIndex < self.maxCount then
        if plugIndex == self.activeOut then
            return 1.0
        else
            return 0.0
        end
    end
    return MockElement.getSignalOut(self, plug)
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getCounterState = function() return self:getCounterState() end
    closure.next = function() return self:next() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M