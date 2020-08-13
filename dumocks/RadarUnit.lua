--- List local constructs and access their ID.
-- @module RadarUnit
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

    o.range = 0 -- meters
    -- map: id => {
        -- ownerId=0,
        -- name="",
        -- size={0,0,0},
        -- type="dynamic",
        -- worldPos={0,0,0},
        -- worldVel={0,0,0},
        -- worldAccel={0,0,0},
        -- pos={0,0,0},
        -- vel={0,0,0},
        -- accel={0,0,0},
    -- }
    o.entries = {}
    o.enterCallbacks = {}
    o.leaveCallbacks = {}

    return o
end

--- Returns the current range of the radar.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Returns the list of construct IDs currently detection in the range.
-- @treturn list The list of construct IDs, can be used with database.getConstruct to retrieve info about each
-- construct.
function M:getEntries()
    local entries = {}
    for id,_ in pairs(self.entries) do
        table.insert(entries, id)
    end
    return entries
end

--- Return the player id of the owner of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn int The player ID of the owner. Use database.getPlayer(ID) to retrieve info about it.
function M:getConstructOwner(id)
    if self.entries[id] then
        return self.entries[id].ownerId
    end
    return nil
end

--- Return the size of the bounding box of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The size of the construct in xyz-coordinates.
function M:getConstructSize(id)
    if self.entries[id] then
        return self.entries[id].size
    end
    return nil
end

--- Return the type of the given construct.
-- @tparam int id The ID of the construct.
-- @treturn string The type of the construct,; can be 'static' or 'dynamic'.
function M:getConstructType(id)
    if self.entries[id] then
        return self.entries[id].type
    end
    return nil
end

--- Return the world coordinates of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct.
function M:getConstructWorldPos(id)
    if self.entries[id] then
        return self.entries[id].worldPos
    end
    return nil
end

--- Return the world coordinates of the given construct's speed, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct's velocity relative to absolute space.
function M:getConstructWorldVelocity(id)
    if self.entries[id] then
        return self.entries[id].worldVel
    end
    return nil
end

--- Return the world coordinates of the given construct's acceleration, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct's acceleration relative to absolute space.
function M:getConstructWorldAcceleration(id)
    if self.entries[id] then
        return self.entries[id].worldAccel
    end
    return nil
end

--- Return the radar local coordinates of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz radar local coordinates of the construct.
function M:getConstructPos(id)
    if self.entries[id] then
        return self.entries[id].pos
    end
    return nil
end

--- Return the radar local coordinates of the given construct's speed, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz radar local coordinates of the construct's velocity relative to absolute space.
function M:getConstructVelocity(id)
    if self.entries[id] then
        return self.entries[id].vel
    end
    return nil
end

--- Return the radar local coordinates of the acceleration of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz radar local coordinates of the construct's acceleration relative to absolute space.
function M:getConstructAcceleration(id)
    if self.entries[id] then
        return self.entries[id].accel
    end
    return nil
end

--- Return the name of the given construct, if defined.
-- @tparam int id the ID of the construct.
-- @treturn string The name of the construct.
function M:getConstructAcceleration(id)
    if self.entries[id] then
        return self.entries[id].name
    end
    return nil
end

--- Event: Emitted when a construct enters the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id ID of the construct; can be used with database.getConstruct to retrieve info about it.
function M.EVENT_enter(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterEnter")
end

--- Event: Emitted when a construct leaves the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id ID of the construct; can be used with database.getConstruct to retrieve info about it.
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

--- Mock only, not in-game: Simulates a construct entering the radar range.
-- @tparam int id The ID of the construct that entered.
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

--- Mock only, not in-game: Simulates a construct leaving the radar range.
-- @tparam int id The ID of the construct that left.
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
    closure.range = function() return self:getRange() end
    closure.getEntries = function() return self:getEntries() end
    closure.getConstructOwner = function(id) return self:getConstructOwner(id) end
    closure.getConstructSize = function(id) return self:getConstructSize(id) end
    closure.getConstructType = function(id) return self:getConstructType(id) end
    closure.getConstructWorldPos = function(id) return self:getConstructWorldPos(id) end
    closure.getConstructWorldVelocity = function(id) return self:getConstructWorldVelocity(id) end
    closure.getConstructWorldAcceleration = function(id) return self:getConstructWorldAcceleration(id) end
    closure.getConstructPos = function(id) return self:getConstructPos(id) end
    closure.getConstructVelocity = function(id) return self:getConstructVelocity(id) end
    closure.getConstructAcceleration = function(id) return self:getConstructAcceleration(id) end
    closure.getConstructName = function(id) return self:getConstructName(id) end
    return closure
end

return M