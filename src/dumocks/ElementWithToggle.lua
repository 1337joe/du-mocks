--- Abstract class to define elements with activate, deactivate, toggle, and getState method.
--
-- Extends: Element &gt; ElementWithState
--
-- Extended by:
-- <ul>
--   <li>AntiGravityGeneratorUnit</li>
--   <li>DoorUnit</li>
--   <li>EngineUnit</li>
--   <li>ForceFieldUnit</li>
--   <li>GyroUnit</li>
--   <li>LandingGearUnit</li>
--   <li>LaserEmitterUnit</li>
--   <li>LightUnit</li>
--   <li>ManualSwitchUnit</li>
--   <li>ScreenUnit</li>
--   <li>ShieldGeneratorUnit</li>
-- </ul>
-- @see Element
-- @see ElementWithState
-- @see AntiGravityGeneratorUnit
-- @see DoorUnit
-- @see EngineUnit
-- @see ForceFieldUnit
-- @see GyroUnit
-- @see LandingGearUnit
-- @see LaserEmitterUnit
-- @see LightUnit
-- @see ManualSwitchUnit
-- @see TransponderUnit
-- @see ScreenUnit
-- @see ShieldGeneratorUnit
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

--- Switches the element on/open.
function M:activate()
    self.state = true
end

--- Switches the element off/open.
function M:deactivate()
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