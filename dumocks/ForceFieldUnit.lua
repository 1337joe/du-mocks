--- A forcefield to create an uncrossable energy barrier
-- @module ForceFieldUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["force field xs"] = {mass = 110.62, maxHitPoints = 50.0}
elementDefinitions["force field s"] = {mass = 110.62, maxHitPoints = 50.0}
elementDefinitions["force field m"] = {mass = 110.62, maxHitPoints = 50.0}
elementDefinitions["force field l"] = {mass = 110.62, maxHitPoints = 50.0}
local DEFAULT_ELEMENT = "force field xs"

local M = MockElement:new()
M.elementClass = "ForceFieldUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Activate the field.
function M:activate()
    self.state = true
end

--- Deactivate the field.
function M:deactivate()
    self.state = false
end

--- Toggle the state.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the field.
-- @return 1 when the field is active, 0 otherwise.
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
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.toggle = function() return self:toggle() end
    closure.getState = function() return self:getState() end
    return closure
end

return M