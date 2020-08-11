--- Laser detector unit.
-- Detec the hit of a laser.
-- @module MockLaserDetectorUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {}
elementDefinitions["laser receiver"] = {mass = 9.93, maxHitPoints = 50.0}
-- TODO infrared laser receiver?
local DEFAULT_ELEMENT = "laser receiver"

local M = MockElement:new()
M.elementClass = "LaserDetectorUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false
    o.hitCallbacks = {}
    o.releaseCallbacks = {}

    return o
end

--- Returns the activation state of the laser detector.
-- @return 0 if the detector has no laser pointed to it, 1 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Mock only, not in-game: Register a handler for the in-game `laserHit()` event.
--
-- Event: `laserHit()`
--
-- A laser has just hit the detector.
-- @tparam function callback The function to call when the laser hits.
-- @treturn int The index of the callback.
function M:mockRegisterLaserHit(callback)
    local index = #self.hitCallbacks + 1
    self.hitCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the laser hitting the detector. Calling this while the detector is already
-- deactivated is invalid and will have no effect.
--
-- Note: the state updates to true <em>before</em> the event handlers are called, which is different behavior to
-- releasing the laser.
function M:mockDoPressed()
    -- bail if already activated
    if self.state then
        return
    end

    -- state changes before calling handlers
    self.state = true

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.hitCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `released()` event.
--
-- Event: `released()`
--
-- All lasers have stopped hitting the detector.
-- @tparam function callback The function to call when the lasers stop hitting.
-- @treturn int The index of the callback.
function M:mockRegisterReleased(callback)
    local index = #self.releaseCallbacks + 1
    self.releaseCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the laser stopping hitting the detector. Calling this while the detector is
-- already deactivated is invalid and will have no effect.
--
-- Note: the state updates to true <em>after</em> the event handlers are called, which is different behavior to
-- a laser hitting.
function M:mockDoReleased()
    -- bail if already deactivated
    if not self.state then
        return
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.releaseCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- state changes after calling handlers
    self.state = true

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see MockElement:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getState = function() return self:getState() end
    return closure
end

return M