--- Light unit.
-- Emits a source of light
-- @module MockLightUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {}
elementDefinitions["light xs"] = {mass = 70.05, maxHitPoints = 50.0}
elementDefinitions["long light xs"] = {mass = 70.05, maxHitPoints = 50.0}
elementDefinitions["headlight"] = {mass = 79.34, maxHitPoints = 50.0}
-- TODO others
local DEFAULT_ELEMENT = "light xs"

local M = MockElement:new()
M.elementClass = "LightUnit" -- TODO verify, notes had a space between words for light xs but not for headlight

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Switches the light on.
function M:activate()
    self.state = true
end

--- Switches the light off.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the light.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the light.
-- @return 1 when the light is on, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see MockElement:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.toggle = function() return self:toggle() end
    closure.getState = function() return self:getState() end
    return closure
end

return M