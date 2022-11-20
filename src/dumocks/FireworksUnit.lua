--- A unit capable to launch fireworks that are stored in the attached container.
--
-- Element class: FireworksUnit
--
-- Extends: @{Element}
-- @module FireworksUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["fireworks launcher s"] = {mass = 78.12, maxHitPoints = 50.0, itemId = 3882559017}
local DEFAULT_ELEMENT = "fireworks launcher s"

local M = MockElement:new()
M.elementClass = "FireworksUnit"

local DEFAULT_DELAY = 4.0 -- seconds
local MINIMUM_DELAY = 2.0
local MAXIMUM_DELAY = 5.0
local DEFAULT_SPEED = 100.0 -- m/s
local MINIMUM_SPEED = 50.0
local MAXIMUM_SPEED = 200.0
local DEFAULT_TYPE = 1
local DEFAULT_COLOR = 1

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.explosionDelay = DEFAULT_DELAY
    o.launchSpeed = DEFAULT_SPEED
    o.type = DEFAULT_TYPE
    o.color = DEFAULT_COLOR

    o.plugIn = 0

    return o
end

--- <b>Deprecated:</b> Fire the firework.
--
-- This method is deprecated: fire should be used instead
-- @see fire
function M:activate()
    M.deprecated("activate", "fire")
    M:fire()
end

--- Fire the firework.
function M:fire()
end

--- Set the delay before the launched firework explodes.
-- @tparam float delay The delay before explosion in seconds (minimum 2, maximum 5).
function M:setExplosionDelay(delay)
    delay = tonumber(delay)
    if type(delay) == "number" then
        if delay < MINIMUM_DELAY then
            self.explosionDelay = MINIMUM_DELAY
        elseif delay > MAXIMUM_DELAY then
            self.explosionDelay = MAXIMUM_DELAY
        else
            self.explosionDelay = delay
        end
    else
        self.explosionDelay = MINIMUM_DELAY
    end
end

--- Returns the delay before the launched firework explodes.
-- @treturn float The delay before explosion in seconds.
function M:getExplosionDelay()
    return self.explosionDelay
end

--- Set the speed at which the firework will be launched (impacts its altitude, depending on the local gravity).
-- @tparam float speed The launch speed in m/s (minimum 50, maximum 200).
function M:setLaunchSpeed(speed)
    speed = tonumber(speed)
    if type(speed) == "number" then
        if speed < MINIMUM_SPEED then
            self.launchSpeed = MINIMUM_SPEED
        elseif speed > MAXIMUM_SPEED then
            self.launchSpeed = MAXIMUM_SPEED
        else
            self.launchSpeed = speed
        end
    else
        self.launchSpeed = MINIMUM_SPEED
    end
end

--- Returns the speed at which the firework will be launched.
-- @treturn float The launch speed in m/s.
function M:getLaunchSpeed()
    return self.launchSpeed
end

--- Set the type of launched firework (will affect which firework is picked in the attached container).
-- @tparam int type The type index of the firework (Ball = 1, Ring = 2, Palmtree = 3, Shower = 4).
function M:setType(type)
    type = tonumber(type)
    if _G.type(type) == "number" then
        if type % 1 ~= 0 then
            self.type = DEFAULT_TYPE
        elseif type < 1 then
            self.type = 1
        elseif type > 4 then
            self.type = 4
        else
            self.type = type
        end
    else
        self.type = DEFAULT_TYPE
    end
end

--- Returns the type of launched firework.
-- @treturn int The type index of the firework (Ball = 1, Ring = 2, Palmtree = 3, Shower = 4).
function M:getType()
    return self.type
end

--- Set the color of the launched firework (will affect which firework is picked in the attached container).
-- @tparam int color The color index of the firework (Blue = 1, Gold = 2, Green = 3, Purple = 4, Red = 5, Silver = 6).
function M:setColor(color)
    color = tonumber(color)
    if type(color) == "number" then
        if color % 1 ~= 0 then
            self.color = DEFAULT_COLOR
        elseif color < 1 then
            self.color = 1
        elseif color > 6 then
            self.color = 6
        else
            self.color = color
        end
    else
        self.color = DEFAULT_COLOR
    end
end

--- Returns the color of the launched firework.
-- @treturn int The color index of the firework (Blue = 1, Gold = 2, Green = 3, Purple = 4, Red = 5, Silver = 6).
function M:getColor()
    return self.color
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- no longer responds to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- Event: Emitted when a firework has just been fired.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onFired()
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.fire = function() return self:fire() end
    closure.setExplosionDelay = function(delay) return self:setExplosionDelay(delay) end
    closure.getExplosionDelay = function() return self:getExplosionDelay() end
    closure.setLaunchSpeed = function(speed) return self:setLaunchSpeed(speed) end
    closure.getLaunchSpeed = function() return self:getLaunchSpeed() end
    closure.setType = function(type) return self:setType(type) end
    closure.getType = function() return self:getType() end
    closure.setColor = function(color) return self:setColor(color) end
    closure.getColor = function() return self:getColor() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M