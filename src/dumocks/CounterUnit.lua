--- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received
-- on its IN plug.
--
-- Element class: CounterUnit
--
-- Extends: @{Element}
-- @module CounterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["2 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888062905, maxCount = 2}
elementDefinitions["3 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888062906, maxCount = 3}
elementDefinitions["5 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888062908, maxCount = 5}
elementDefinitions["7 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888062910, maxCount = 7}
elementDefinitions["10 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888063487, maxCount = 10}
local DEFAULT_ELEMENT = "2 counter xs"

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

--- <b>Deprecated:</b> Returns the rank of the currently active OUT plug.
--
-- This method is deprecated: getIndex should be used instead
-- @see getIndex
-- @return The index of the active plug.
function M:getCounterState()
    M.deprecated("getCounterState", "getIndex")
    return self:getIndex()
end

--- Returns the index of the current active output plug.
-- @treturn int The index of the active plug (1-indexed, so a 2 counter can return 1 or 2).
function M:getIndex()
    return self.activeOut % self.maxCount + 1
end

--- Returns the maximum index of the counter.
-- @treturn int The maximum index (0-indexed, so a 2 counter returns 1).
function M:getMaxIndex()
    return self.maxCount - 1 -- 0-indexed
end

--- <b>Deprecated:</b> Moves the counter one step further (equivalent to signal received on the IN plug).
--
-- This method is deprecated: nextIndex should be used instead
-- @see nextIndex
function M:next()
    M.deprecated("next", "nextIndex")
    self:nextIndex()
end

--- Moves the next counter index.
function M:nextIndex()
    self.activeOut = (self.activeOut + 1) % self.maxCount
end

--- Sets the counter index.
-- @tparam int index The index of the plug to activate (1-indexed, so valid inputs for a 2 counter are 1 and 2).
function M:setIndex(index)
    index = index - 1 -- shift to 0-indexed
    if index >= self.maxCount then
        index = self.maxCount - 1
    elseif index < 0 then
        index = 0
    end
    self.activeOut = index
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

local OUT_SIGNAL_PATTERN = "OUT%-signal%-(%d+)"
--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"OUT-signal-&lt;i&gt;" where &lt;i&gt; is replaced by a number from 0 to the counter number minus 1 (so range of [0,4] for a 5 Counter).</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
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
    closure.getIndex = function() return self:getIndex() end
    closure.getMaxIndex = function() return self:getMaxIndex() end
    closure.next = function() return self:next() end
    closure.nextIndex = function() return self:nextIndex() end
    closure.setIndex = function(index) return self:setIndex(index) end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M