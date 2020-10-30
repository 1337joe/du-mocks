--- Displays a static screen.
-- @module SignUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["sign xs"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["sign s"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["sign m"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["sign l"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["vertical sign xs"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["vertical sign m"] = {mass = 18.67, maxHitPoints = 50.0}
elementDefinitions["vertical sign l"] = {mass = 18.67, maxHitPoints = 50.0}

local DEFAULT_ELEMENT = "sign xs"

local M = MockElement:new()
M.elementClass = "ScreenSignUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false

    return o
end

--- Switches the screen on.
function M:activate()
    self.state = true
end

--- Switches the screen off.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the screen.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of the screen.
-- @return 1 when the screen is on, 0 otherwise.
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