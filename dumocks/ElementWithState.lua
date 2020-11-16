--- Abstract class to define elements with a getState method.
--
-- Element class: <none>
--
-- Extends: Element &gt; ElementWithState
--
-- Extended by:
-- <ul>
--   <li>ElementWithToggle</li>
-- </ul>
--
-- @see Element
-- @see ElementWithToggle
-- @module ElementWithState
-- @alias M

local MockElement = require "dumocks.Element"

local M = MockElement:new()

function M:new(o, id, elementDefinition)
    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Returns the activation state of the element.
-- @return 1 when the element is on, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getState = function() return self:getState() end
    return closure
end

return M