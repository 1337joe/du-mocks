--- A landing gear that can be opened or closed.
-- @module LandingGearUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["landing gear xs"] = {mass = 49.88, maxHitPoints = 63.0}
elementDefinitions["landing gear s"] = {mass = 258.76, maxHitPoints = 1045.0}
elementDefinitions["landing gear m"] = {mass = 1460.65, maxHitPoints = 9939.0}
local DEFAULT_ELEMENT = "landing gear s"

local M = MockElement:new()
M.elementClass = "LandingGearUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Open the landing gear.
function M:activate()
    self.state = true
end

--- Close the landing gear.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the gear.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the landing gear.
-- @return 1 when the landing gear is opened, 0 otherwise.
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