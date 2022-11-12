--- Detect the hit of a laser.
--
-- Element class: LaserDetectorUnit
--
-- Extends: @{Element} &gt; @{ElementWithState}
-- @module LaserDetectorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithState = require "dumocks.ElementWithState"

local elementDefinitions = {}
elementDefinitions["laser receiver xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 783555860}
elementDefinitions["infrared laser receiver xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 2153998731}
local DEFAULT_ELEMENT = "laser receiver xs"

local M = MockElementWithState:new()
M.elementClass = "LaserDetectorUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithState:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.hitCallbacks = {}
    o.releaseCallbacks = {}

    return o
end

--- Checks if any laser is hitting the detector.
-- @treturn 0/1 1 if a laser is hitting the detector.
function M:isHit()
    if self.state then
        return 1
    end
    return 0
end

--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"out" for the out signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    if plug == "out" then
        if self.state then
            return 1.0
        else
            return 0.0
        end
    end
    return MockElement.getSignalOut(self, plug)
end

--- <b>Deprecated:</b> Event: A laser has just hit the detector.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onHit should be used instead.
-- @see EVENT_onHit
function M.EVENT_laserHit()
    M.deprecated("EVENT_laserHit", "EVENT_onHit")
    M.EVENT_onHit()
end

--- Event: Emitted when a laser hit the detector.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onHit()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterLaserHit")
end

--- <b>Deprecated:</b> Event: All lasers have stopped hitting the detector.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onLoss should be used instead.
-- @see EVENT_onLoss
function M.EVENT_laserRelease()
    M.deprecated("EVENT_laserRelease", "EVENT_onLoss")
    M.EVENT_onLoss()
end

--- Event: Emitted when all lasers stop hitting the detector.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onLoss()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterLaserRelease")
end

--- Mock only, not in-game: Register a handler for the in-game `laserHit()` event.
-- @tparam function callback The function to call when the laser hits.
-- @treturn int The index of the callback.
-- @see EVENT_laserHit
function M:mockRegisterLaserHit(callback)
    local index = #self.hitCallbacks + 1
    self.hitCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the laser hitting the detector. Calling this while the detector is already
-- deactivated is invalid and will have no effect.
--
-- Note: currently fires three times when a laser activates it. Release does not.
function M:mockDoLaserHit()
    -- bail if already activated
    if self.state then
        return
    end

    -- state changes before calling handlers
    self.state = true

    local errors = ""

    -- for some reason in-game it triple reports
    for i = 1,3 do

        -- call callbacks in order, saving exceptions until end
        for i,callback in pairs(self.hitCallbacks) do
            local status,err = pcall(callback)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end

    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `laserRelease()` event.
-- @tparam function callback The function to call when the lasers stop hitting.
-- @treturn int The index of the callback.
-- @see EVENT_laserRelease
function M:mockRegisterLaserRelease(callback)
    local index = #self.releaseCallbacks + 1
    self.releaseCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the laser stopping hitting the detector. Calling this while the detector is
-- already deactivated is invalid and will have no effect.
function M:mockDoLaserRelease()
    -- bail if already deactivated
    if not self.state then
        return
    end

    -- state changes before calling handlers
    self.state = false

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.releaseCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithState.mockGetClosure(self)
    closure.isHit = function() return self:isHit() end

    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M