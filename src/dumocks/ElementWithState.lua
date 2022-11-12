--- Abstract class to define elements with a getState method.
--
-- Element class: <none>
--
-- Extends: @{Element}
--
-- Extended by:
-- <ul>
--   <li>@{ElementWithToggle}</li>
--   <li>@{LaserDetectorUnit}</li>
--   <li>@{ManualButtonUnit}</li>
--   <li>@{PressureTileUnit}</li>
-- </ul>
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

--- <b>Deprecated:</b> Returns the activation state of the element.
--
-- This method is deprecated: element-specific methods should be used instead.
-- @treturn 0/1 1 when the element is on, 0 otherwise.
function M:getState()
    M.deprecated("getState")
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