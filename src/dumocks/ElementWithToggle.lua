--- Abstract class to define elements with activate, deactivate, toggle, and getState method.
--
-- Extends: @{Element} &gt; @{ElementWithState}
--
-- Extended by:
-- <ul>
--   <li>@{AntiGravityGeneratorUnit}</li>
--   <li>@{BaseShieldGeneratorUnit}</li>
--   <li>@{DoorUnit}</li>
--   <li>@{EngineUnit}</li>
--   <li>@{ForceFieldUnit}</li>
--   <li>@{GyroUnit}</li>
--   <li>@{LandingGearUnit}</li>
--   <li>@{LaserEmitterUnit}</li>
--   <li>@{LightUnit}</li>
--   <li>@{ManualSwitchUnit}</li>
--   <li>@{ScreenUnit}</li>
--   <li>@{ShieldGeneratorUnit}</li>
--   <li>@{TransponderUnit}</li>
-- </ul>
-- @see Element
-- @see ElementWithState
-- @module ElementWithToggle
-- @alias M

local MockElementWithState = require "dumocks.ElementWithState"

local M = MockElementWithState:new()

function M:new(o, id, elementDefinition)
    o = o or MockElementWithState:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    return o
end

--- <b>Deprecated:</b> Switches the element on/open.
--
-- This method is deprecated: element-specific methods should be used instead.
function M:activate()
    M.deprecated("activate")
    self.state = true
end

--- <b>Deprecated:</b> Switches the element off/open.
--
-- This method is deprecated: element-specific methods should be used instead.
function M:deactivate()
    M.deprecated("deactivate")
    self.state = false
end

--- Toggle the state of the element.
function M:toggle()
    self.state = not self.state
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithState.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.toggle = function() return self:toggle() end
    return closure
end

return M