--- Gyro unit.
-- A general kinematic unit to obtain information about the ship orientation, velocity, and acceleration.
-- @module GyroUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
-- TODO
local DEFAULT_ELEMENT = ""

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false
    o.localUp = {0, 0, 0}
    o.localForward = {0, 0, 0}
    o.localRight = {0, 0, 0}
    o.worldUp = {0, 0, 0}
    o.worldForward = {0, 0, 0}
    o.worldRight = {0, 0, 0}
    o.pitch = 0 -- deg
    o.roll = 0 -- deg

    return o
end

--- Selects this gyro as the main gyro used for ship orientation.
function M:activate()
    self.state = true
end

--- Deselects this gyro as the main gyro used for ship orientation, using the core unit instead.
function M:deactivate()
    self.state = false
end

--- Toggle the activation state of the gyro.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the gyro.
-- @return 1 when the gyro is used for ship orientation, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- The up vector of the gyro unit, in construct local coordinates.
-- @return Normalized up vector of the gyro unit, in construct local coordinates.
function M:localUp()
    return self.localUp
end

--- The forward vector of the gyro unit, in construct local coordinates.
-- @return Normalized forward vector of the gyro unit, in construct local coordinates.
function M:localForward()
    return self.localForward
end

--- The right vector of the gyro unit, in construct local coordinates.
-- @return Normalized right vector of the gyro unit, in construct local coordinates.
function M:localRight()
    return self.localRight
end

--- The up vector of the gyro unit, in world coordinates.
-- @return Normalized up vector of the gyro unit, in world coordinates.
function M:worldUp()
    return self.worldUp
end

--- The forward vector of the gyro unit, in world coordinates.
-- @return Normalized forward vector of the gyro unit, in world coordinates.
function M:worldForward()
    return self.worldForward
end

--- The right vector of the gyro unit, in world coordinates.
-- @return Normalized right vector of the gyro unit, in world coordinates.
function M:worldRight()
    return self.worldRight
end

--- The pitch value relative to the gyro orientation and the local gravity.
-- @treturn deg The pitch angle in degrees, relative to the gyro orientation and the local gravity.
function M:getPitch()
    return self.pitch
end

--- The roll value relative to the gyro orientation and the local gravity.
-- @treturn deg The roll angle in degrees, relative to the gyro orientation and the local gravity.
function M:getRoll()
    return self.roll
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
    closure.localUp = function() return self:localUp() end
    closure.localForward = function() return self:localForward() end
    closure.localRight = function() return self:localRight() end
    closure.worldUp = function() return self:worldUp() end
    closure.worldForward = function() return self:worldForward() end
    closure.worldRight = function() return self:worldRight() end
    closure.getPitch = function() return self:getPitch() end
    closure.getRoll = function() return self:getRoll() end
    return closure
end

return M