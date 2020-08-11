--- Laser emitter unit.
-- Emits a laser ray that can be use to detect the passage of a player or on a laser detector unit.
-- @module MockLaserEmitterUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {}
elementDefinitions["laser emitter"] = {mass = 7.47, maxHitPoints = 50.0}
-- TODO infrared laser emitter?
local DEFAULT_ELEMENT = "laser emitter"

local M = MockElement:new()
M.elementClass = "LaserEmitterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Start the laser.
function M:activate()
    self.state = true
end

--- Stop the laser.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the laser.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the laser.
-- @return 1 when the laser is activated, 0 otherwise.
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