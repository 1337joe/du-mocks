--- Generates graviton condensates to power anti-gravity pulsors.
-- @module AntiGravityGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
local DEFAULT_ELEMENT = ""

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false
    o.targetAltitude = 1000 -- m

    return o
end

--- Start the anti-g generator.
function M:activate()
    self.state = true
end

--- Stop the anti-g generator.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the anti-g generator.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of activation of the anti-g generator.
-- @return 1 when the anti-g generator is started, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Sets the base altitude for the anti-gravity field.
-- @tparam m altitude The desired altitude. It will be reached with a slow acceleration (not instantaneous).
function M:setBaseAltitude(altitude)
    self.targetAltitude = altitude
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