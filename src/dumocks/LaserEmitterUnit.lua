--- Laser emitter unit.
-- Emits a laser ray that can be use to detect the passage of a player or on a laser detector unit.
--
-- Element class: LaserEmitterUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module LaserEmitterUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["laser emitter xs"] = {mass = 7.47, maxHitPoints = 50.0, itemId = 1784722190}
elementDefinitions["infrared laser emitter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 609676854}
local DEFAULT_ELEMENT = "laser emitter xs"

local M = MockElementWithToggle:new()
M.elementClass = "LaserEmitterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.plugIn = 0.0

    return o
end

--- Activates the laser emitter.
function M:activate()
    self.state = true
end

--- Deactivates the laser emitter.
function M:deactivate()
    self.state = false
end

--- Checks if the laser emitter is active.
-- @treturn 0/1 1 if the laser emitter is active.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
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

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M