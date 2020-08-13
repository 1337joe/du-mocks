--- Detect the intrusion of any player inside the effect zone.
-- @module DetectionZoneUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
-- TODO
local DEFAULT_ELEMENT = ""

local M = MockElement:new()
M.elementClass = "???Unit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.enterCallbacks = {}
    o.leaveCallbacks = {}

    return o
end

--- Event: A player just entered the zone
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the player. Use database.getPlayer(ID).name to retrieve its name.
function M.EVENT_enter(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterEnter")
end

--- Event: A player just left the zone.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the player. Use database.getPlayer(ID).name to retrieve its name.
function M.EVENT_leave(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterLeave")
end

--- Mock only, not in-game: Register a handler for the in-game `enter(id)` event.
-- @tparam function callback The function to call when the a player enters.
-- @treturn int The index of the callback.
-- @see EVENT_enter
function M:mockRegisterEnter(callback)
    local index = #self.enterCallbacks + 1
    self.enterCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates a user entering the detection zone.
-- @tparam int id The ID of the player who entered.
function M:mockDoEnter(id)

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.enterCallbacks) do
        local status,err = pcall(callback, id)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `leave(id)` event.
-- @tparam function callback The function to call when the tile is released.
-- @treturn int The index of the callback.
-- @see EVENT_leave
function M:mockRegisterLeave(callback)
    local index = #self.leaveCallbacks + 1
    self.leaveCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates a player leaving the detection zone.
-- @tparam int id The ID of the player who left.
function M:mockDoLeave(id)
    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.leaveCallbacks) do
        local status, err = pcall(callback, id)
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
    local closure = MockElement.mockGetClosure(self)
    -- no additional methods
    return closure
end

return M