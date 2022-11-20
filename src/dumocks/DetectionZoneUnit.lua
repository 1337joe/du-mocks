--- Detect the intrusion of any player inside the effect zone.
--
-- Element class: DetectionZoneUnit
--
-- Extends: @{Element}
-- @module DetectionZoneUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["detection zone xs"] = {mass = 7.79, maxHitPoints = 50.0, itemId = 485151209, radius = 2.0}
elementDefinitions["detection zone s"] = {mass = 7.79, maxHitPoints = 50.0, itemId = 485149228, radius = 4.0}
elementDefinitions["detection zone m"] = {mass = 7.79, maxHitPoints = 50.0, itemId = 485149481, radius = 8.0}
elementDefinitions["detection zone l"] = {mass = 7.79, maxHitPoints = 50.0, itemId = 4241228057, radius = 16.0}
local DEFAULT_ELEMENT = "detection zone s"

local M = MockElement:new()
M.elementClass = "DetectionZoneUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.radius = elementDefinition.radius
    o.players = {}

    o.enterCallbacks = {}
    o.leaveCallbacks = {}

    o.plugOut = 0.0

    return o
end

--- Returns the detection zone radius.
-- @treturn float The detection zone radius.
function M:getRadius()
    return self.radius
end

--- Returns the list of IDs of the players in the detection zone. Updates after events fire, so won't be correct in
-- event handling.
-- @treturn list The list of player IDs.
function M:getPlayers()
    return self.players
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
        -- clamp to valid values
        local value = tonumber(self.plugOut)
        if value ~= 0.0 then
            return 1.0
        else
            return 0.0
        end
    end
    return MockElement.getSignalOut(self, plug)
end

--- <b>Deprecated:</b> Event: A player just entered the zone.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onEnter should be used instead.
-- @see EVENT_onEnter
-- @tparam int id The ID of the player. Use @{game_data_lua.database.getPlayer|database.getPlayer}.name to retrieve its
--   name.
-- @see game_data_lua.database.getPlayer
function M.EVENT_enter(id)
    M.deprecated("EVENT_enter", "EVENT_onEnter")
    M.EVENT_onEnter()
end

--- Event: Emitted when a player enters the detection zone.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the player. Use @{system.getPlayerName|system.getPlayerName(id)} to retrieve its name.
function M.EVENT_onEnter(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterEnter")
end

--- <b>Deprecated:</b> Event: A player just left the zone.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onLeave should be used instead.
-- @see EVENT_onLeave
-- @tparam int id The ID of the player. Use database.getPlayer(ID).name to retrieve its name.
function M.EVENT_leave(id)
    M.deprecated("EVENT_leave", "EVENT_onLeave")
    M.EVENT_onLeave()
end

--- Emitted when a player leaves the detection zone.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the player. Use @{system.getPlayerName|system.getPlayerName(id)} to retrieve its name.
function M.EVENT_onLeave(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterLeave")
end

--- Mock only, not in-game: Register a handler for the in-game `enter(id)` event.
-- @tparam function callback The function to call when the a player enters.
-- @tparam string filter The id to filter on, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_enter
function M:mockRegisterEnter(callback, filter)
    filter = filter or "*"

    local index = #self.enterCallbacks + 1
    self.enterCallbacks[index] = {callback = callback, filter = filter}
    return index
end

--- Mock only, not in-game: Simulates a user entering the detection zone.
-- @tparam int id The ID of the player who entered.
function M:mockDoEnter(id)
    self.plugOut = 1.0

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.enterCallbacks) do
        if callback.filter == "*" or callback.filter == tostring(id) then
            local status, err = pcall(callback.callback, id)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- players updates after event fires
    self.players[#self.players + 1] = id

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `leave(id)` event.
-- @tparam function callback The function to call when a player leaves.
-- @tparam string filter The id to filter on, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_leave
function M:mockRegisterLeave(callback, filter)
    filter = filter or "*"

    local index = #self.leaveCallbacks + 1
    self.leaveCallbacks[index] = {callback = callback, filter = filter}
    return index
end

--- Mock only, not in-game: Simulates a player leaving the detection zone.
--
-- Note: This does not set plugOut to 0.0 because it can't track if everyone has left. Do this manually if it's relevant.
-- @tparam int id The ID of the player who left.
function M:mockDoLeave(id)
    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.leaveCallbacks) do
        if callback.filter == "*" or callback.filter == tostring(id) then
            local status, err = pcall(callback.callback, id)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- players updates after event fires
    local newPlayers = {}
    for _, player in pairs(self.players) do
        if player ~= id then
            newPlayers[#newPlayers + 1] = player
        end
    end
    self.players = newPlayers

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
    closure.getRadius = function() return self:getRadius() end
    closure.getPlayers = function() return self:getPlayers() end

    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M