--- A door that can be opened or closed.
-- @module DoorUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["reinforced sliding door"] = {mass = 4197.11, maxHitPoints = 969.0}
-- TODO others
local DEFAULT_ELEMENT = "reinforced sliding door"

local M = MockElement:new()
M.elementClass = "DoorUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Open the door.
function M:activate()
    self.state = true
end

--- Close the door.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the door.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the door.
-- @return 1 when the door is opened, 0 otherwise.
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