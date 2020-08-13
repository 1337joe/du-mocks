--- A unit capable to launch fireworks that are stored in the attached container.
-- @module FireworksUnit
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

    o.explosionDelay = 5 -- seconds
    o.launchSpeed = 200 -- m/s
    o.type = 0
    o.color = 0

    return o
end

--- Fire the firework.
function M:activate()
    -- TODO add callback to support monitoring when this is called
end

--- Set the delay before the launched fireworks explodes. Max=5s.
-- @tparam second t The delay before explosion.
function M:setExplosionDelay(t)
    -- TODO add bounds checking
    self.explosionDelay = t
end

--- Set the speed at which the firework will be launched (impacts its altitude, depending on the local gravity).
-- Max=200m/s.
-- @tparam m/s v The launch speed.
function M:setLaunchSpeed(v)
    -- TODO add bounds checking
    self.launchSpeed = v
end

--- Set the type of launched firework (will affect which firework is picked in the attached container).
-- @tparam int type 0=BALL, 1=PALMTREE, 2=RING, 3=SHOWER.
function M:setType(type)
    -- TODO check values
    self.type = type
end

--- Set the color of the launched firework (will affect which firework is picked in the attached container).
-- @tparam int color 0=BLUE, 1=GOLD, 2=GREEN, 3=PURPLE, 4=RED, 5=SILVER
function M:setColor(color)
    -- TODO check values
    self.color = color
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.setExplosionDelay = function(t) return self:setExplosionDelay(t) end
    closure.setLaunchSpeed = function(v) return self:setLaunchSpeed(v) end
    closure.setType = function(type) return self:setType(type) end
    closure.setColor = function(color) return self:setColor(color) end
    return closure
end

return M