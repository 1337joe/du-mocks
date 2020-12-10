--- List local constructs and access their ID.
--
-- Element class:
-- <ul>
--   <li>RadarPvPAtmosphericSmallGroup</li>
--   <li>RadarPVPSpaceSmallGroup</li>
--   <li>RadarPvPAtmospheric: Medium and Large</li>
--   <li>RadarPVPSpaceMediumGroup</li>
--   <li>RadarPVPSpaceLargeGroup</li>
-- </ul>
--
-- Displayed widget fields:
-- <ul>
--   <li>constructsList</li>
--   <li>elementId</li>
--   <li>properties</li>
--   <li>staticProperties</li>
-- </ul>
--
-- Extends: Element
-- @see Element
-- @module RadarUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_ATMO = "RadarPvPAtmospheric"
local CLASS_SPACE = "RadarPVPSpace"
local SMALL_GROUP = "SmallGroup"
local MEDIUM_GROUP = "MediumGroup"
local LARGE_GROUP = "LargeGroup"

local elementDefinitions = {}
elementDefinitions["atmospheric radar s"] = {mass = 486.72, maxHitPoints = 88.0, class = CLASS_ATMO .. SMALL_GROUP}
elementDefinitions["atmospheric radar m"] = {mass = 11324.61, maxHitPoints = 698.0, class = CLASS_ATMO}
elementDefinitions["atmospheric radar l"] = {mass = 6636.8985, maxHitPoints = 12887.0, class = CLASS_ATMO}
elementDefinitions["space radar s"] = {mass = 486.72, maxHitPoints = 88.0, class = CLASS_SPACE .. SMALL_GROUP}
elementDefinitions["space radar m"] = {mass = 2348.45, maxHitPoints = 698.0, class = CLASS_SPACE .. MEDIUM_GROUP}
elementDefinitions["space radar l"] = {mass = 12492.16, maxHitPoints = 12887.0, class = CLASS_SPACE .. LARGE_GROUP}
local DEFAULT_ELEMENT = "atmospheric radar s"

local M = MockElement:new()
M.widgetType = "radar"
M.helperId = "radar"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

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


local DATA_TEMPLATE = '{"helperId":"%s","type":"%s","name":"%s [%d]",'..
[["constructsList":[],"elementId":"%d",
"properties":{
    "broken":false,
    "errorMessage":"Jammed by atmosphere",
    "identifiedConstructs":[],
    "identifyConstructs":{},
    "radarStatus":1,
    "selectedConstruct":"0",
    "worksInEnvironment":false
},
"staticProperties":{
    "maxIdentifiedTargets":2,
    "ranges":{
        "identify128m":80000,
        "identify16m":10000,
        "identify32m":20000,
        "identify64m":40000,
        "scan":400000
    },
    "worksInAtmosphere":%s,
    "worksInSpace":%s
}
}]]
function M:getData()
    local radarId = 123456789
    local worksInAtmosphere = self.elementClass == CLASS_ATMO
    local worksInSpace = self.elementClass == CLASS_SPACE
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, self:getId(),
                            radarId, worksInAtmosphere, worksInSpace)
end

-- Override default with realistic patten to id.
function M:getDataId()
    if self.elementClass == CLASS_ITEM then
        return MockElement:getDataId()
    end
    return "e123456"
end

--- Returns the current range of the radar.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Returns the list of construct IDs currently detection in the range.
-- @treturn list The list of construct IDs.
-- construct.
function M:getEntries()
    local entries = {}
    for id,_ in pairs(self.entries) do
        table.insert(entries, id)
    end
    return entries
end

--- Returns whether the target has an active transponder with matching tags.
-- @treturn bool 1 if our construct and the target have active transponders with matching tags and 0 otherwise.
function M:hasMatchingTransponder(id)
    return false
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
-- @treturn string The type of the construct,: can be 'static' or 'dynamic'.
function M:getConstructType(id)
    if self.entries[id] then
        return self.entries[id].type
    end
    return nil
end

--- Return the radar local coordinates of the given construct, if in range and if active transponder tags match.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz radar local coordinates of the construct.
function M:getConstructPos(id)
    if self.entries[id] then
        return self.entries[id].pos
    end
    return nil
end

--- Return the name of the given construct, if in range.
-- @tparam int id The ID of the construct.
-- @treturn string The name of the construct.
function M:getConstructName(id)
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
    closure.getRange = function() return self:getRange() end
    closure.getEntries = function() return self:getEntries() end
    closure.hasMatchingTransponder = function() return self:hasMatchingTransponder() end
    closure.getConstructSize = function(id) return self:getConstructSize(id) end
    closure.getConstructType = function(id) return self:getConstructType(id) end
    closure.getConstructPos = function(id) return self:getConstructPos(id) end
    closure.getConstructName = function(id) return self:getConstructName(id) end
    return closure
end

return M