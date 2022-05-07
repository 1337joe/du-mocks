--- List local constructs and access their ID.
--
-- Element class:
-- <ul>
--   <li>RadarPvPAtmospheric</li>
--   <li>RadarPVPSpaceSmallGroup</li>
--   <li>RadarPVPSpaceMediumGroup</li>
--   <li>RadarPVPSpaceLargeGroup</li>
-- </ul>
--
-- Displayed widget fields:
-- <ul>
--   <li>constructsList</li>
--   <li>targetId</li>
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
elementDefinitions["atmospheric radar s"] = {mass = 486.72, maxHitPoints = 88.0, class = CLASS_ATMO, range = 10000.0, idRange = 2000.0}
elementDefinitions["atmospheric radar m"] = {mass = 11324.61, maxHitPoints = 698.0, class = CLASS_ATMO, range = 10000.0, idRange = 4000.0}
elementDefinitions["atmospheric radar l"] = {mass = 6636.8985, maxHitPoints = 12887.0, class = CLASS_ATMO, range = 10000.0, idRange = 8000.0}
elementDefinitions["space radar s"] = {mass = 486.72, maxHitPoints = 88.0, class = CLASS_SPACE .. SMALL_GROUP, range = 400000.0, idRange = 97500.0}
elementDefinitions["space radar m"] = {mass = 2348.45, maxHitPoints = 698.0, class = CLASS_SPACE .. MEDIUM_GROUP, range = 400000.0}
elementDefinitions["space radar l"] = {mass = 12492.16, maxHitPoints = 12887.0, class = CLASS_SPACE .. LARGE_GROUP, range = 400000.0}
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

    o.range = elementDefinition.range -- meters
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


local DATA_TEMPLATE = '{"helperId":"%s","type":"%s","name":"%s",'..
[["constructsList":[],
"currentTargetId":"%d",
"elementId":"%d",
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
        "scan":%d
    },
    "worksInAtmosphere":%s,
    "worksInSpace":%s
}
}]]
function M:getData()
    local targetId = 0
    local radarId = 123456789
    local worksInAtmosphere = self.elementClass == CLASS_ATMO
    local worksInSpace = self.elementClass == CLASS_SPACE
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, targetId, radarId,
                            self.range, worksInAtmosphere, worksInSpace)
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Returns 1 if the radar is not broken, works in the current environment and is not used by another control unit.
-- @treturn 0/1 1 if the radar is operational, 0 otherwise.
function M:isOperational()
end

--- Returns the scan range of the radar.
-- @treturn meter The scan range.
function M:getRange()
    return self.range
end

--- Returns ranges to identify a target based on its core size.
-- @treturn list { xsRange, sRange, mRange, lRange }
function M:getIdentifyRanges()
    return { 10000, 20000, 40000, 80000 }
end

--- <b>Deprecated:</b> Returns the list of construct IDs currently detection in the range.
--
-- This method is deprecated: getConstructIds should be used instead.
-- @see getConstructIds
-- @treturn list The list of construct IDs.
function M:getEntries()
    local message = "Warning: method getEntries is deprecated, use getConstructIds instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
    return self:getConstructIds()
end

--- Returns the list of construct IDs in the scan range.
-- @treturn list The list of scanned construct IDs.
function M:getConstructIds()
    local entries = {}
    for id,_ in pairs(self.entries) do
        table.insert(entries, id)
    end
    return entries
end

--- Returns the list of identified construct IDs.
-- @treturn list The list of identified construct IDs.
function M:getIdentifiedConstructIds()
end

--- Returns the ID of the target construct.
-- @treturn int The ID of the target construct.
function M:getTargetId()
end

--- Returns the distance to the given construct.
-- @tparam int id The ID of the construct.
-- @treturn float The distance between the current and target construct center.
function M:getConstructDistance(id)
end

--- Returns 1 if the given construct is identified.
-- @tparam int id The ID of the construct.
-- @treturn 1/0 1 if the construct is identified, 0 otherwise.
function M:isConstructIdentified(id)
end

--- Returns 1 if the given construct was abandoned.
-- @tparam int id The ID of the construct.
-- @treturn 1/0 1 if the construct has no owner, 0 otherwise.
function M:isConstructAbandoned(id)
end

--- Return the core size of the given construct.
-- @tparam int id The ID of the construct.
-- @treturn string XS, S, M, L
function M:getConstructCoreSize(id)
end

--- Returns the threat rate your construct is for the given construct.
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatTo(id)
end

--- Returns the threat rate the given construct is for your construct.
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatFrom(id)
end

--- Returns whether the target has an active transponder with matching tags.
-- @tparam int id The ID of the construct.
-- @treturn 1/0 1 if our construct and the target have active transponders with matching tags, 0 otherwise.
function M:hasMatchingTransponder(id)
    return 0
end

--- Returns a table with id of the owner entities (player or organization) of the given construct, if in range and if
-- active transponder tags match.
-- @tparam int id The ID of the construct.
-- @treturn table A table { playerId: pID, organizationId: oID } describing the owner. Use 
--   @{system:getPlayerName|system.getPlayerName(pID)} and
--   @{system:getOrganizationName|system.getOrganizationName(oID)} to retrieve info about it.
-- @see system:getPlayerName
-- @see system:getOrganizationName
function M:getConstructOwner(id)
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
-- @treturn string The type of the construct,: can be 'static', 'space' or 'dynamic'.
function M:getConstructType(id)
    if self.entries[id] then
        return self.entries[id].type
    end
    return nil
end

--- Returns the position of the given construct in construct local coordinates, if the active transponder tags match.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz local coordinates relative to the construct center.
function M:getConstructPos(id)
    if self.entries[id] then
        return self.entries[id].pos
    end
    return nil
end

--- Returns the position of the given construct in world coordinates, if in range and if the active transponder tags
-- match.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct center.
function M:getConstructWorldPos(id)
end

--- Returns the velocity vector of the given construct in construct local coordinates, if identified and if the active
-- transponder tags match.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz local coordinates of the construct velocity.
function M:getConstructVelocity(id)
end

--- Returns the velocity vector of the given construct in world coordinates, if identified and if the active
-- transponder tags match.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct velocity.
function M:getConstructWorldVelocity(id)
end

--- Returns the mass of the given construct, if identified.
-- @tparam int id The ID of the construct.
-- @treturn float the mass of the construct.
function M:getConstructMass(id)
end

--- Return the name of the given construct, if defined.
-- @tparam int id The ID of the construct.
-- @treturn string The name of the construct.
function M:getConstructName(id)
    if self.entries[id] then
        return self.entries[id].name
    end
    return nil
end

--- Returns a list of working elements on the given construction, if identified.
-- @tparam int id The ID of the construct.
-- @treturn table A table { weapons: f, radars: f, antiGravity: f, atmoEngines: f, spaceEngines: f, rocketEngines: f }
--   with values 0.0-1.0. Exceptionally antiGravity and rocketEngines are always 1.0 if present, even if broken.
function M:getConstructInfos(id)
end

--- Returns the speed of the given construct, if identified.
-- @tparam int id the ID of the construct.
-- @treturn float The speed of the construct relative to the universe.
function M:getConstructSpeed(id)
end

--- Returns the angular speed of the given construct to your construct, if identified.
-- @tparam int id The ID of the construct.
-- @treturn float The angular speed of the construct relative to your construct.
function M:getConstructAngularSpeed(id)
end

--- Returns the radial speed of the given construct to your construct, if identified.
-- @tparam int id The id of the construct.
-- @treturn float The radial speed of the construct relative to your construct.
function M:getConstructRadialSpeed(id)
end

--- Event: Emitted when a construct enters the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id ID of the construct; can be used with @{game_data_lua.database.getConstruct|database.getConstruct} to
--   retrieve info about it.
-- @see game_data_lua.database.getConstruct
function M.EVENT_enter(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterEnter")
end

--- Event: Emitted when a construct leaves the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id ID of the construct; can be used with @{game_data_lua.database.getConstruct|database.getConstruct} to
--   retrieve info about it.
-- @see game_data_lua.database.getConstruct
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
    closure.isOperational = function() return self:isOperational() end
    closure.getRange = function() return self:getRange() end
    closure.getIdentifyRanges = function() return self:getIdentifyRanges() end
    closure.getEntries = function() return self:getEntries() end
    closure.getConstructIds = function() return self:getConstructIds() end
    closure.getIdentifiedConstructIds = function() return self:getIdentifiedConstructIds() end
    closure.getTargetId = function() return self:getTargetId() end
    closure.getConstructDistance = function(id) return self:getConstructDistance(id) end
    closure.isConstructIdentified = function(id) return self:isConstructIdentified(id) end
    closure.isConstructAbandoned = function(id) return self:isConstructAbandoned(id) end
    closure.getConstructCoreSize = function(id) return self:getConstructCoreSize(id) end
    closure.getThreatTo = function(id) return self:getThreatTo(id) end
    closure.getThreatFrom = function(id) return self:getThreatFrom(id) end
    closure.hasMatchingTransponder = function(id) return self:hasMatchingTransponder(id) end
    closure.getConstructOwner = function(id) return self:getConstructOwner(id) end
    closure.getConstructSize = function(id) return self:getConstructSize(id) end
    closure.getConstructType = function(id) return self:getConstructType(id) end
    closure.getConstructPos = function(id) return self:getConstructPos(id) end
    closure.getConstructWorldPos = function(id) return self:getConstructWorldPos(id) end
    closure.getConstructVelocity = function(id) return self:getConstructVelocity(id) end
    closure.getConstructWorldVelocity = function(id) return self:getConstructWorldVelocity(id) end
    closure.getConstructMass = function(id) return self:getConstructMass(id) end
    closure.getConstructName = function(id) return self:getConstructName(id) end
    closure.getConstructInfos = function(id) return self:getConstructInfos(id) end
    closure.getConstructSpeed = function(id) return self:getConstructSpeed(id) end
    closure.getConstructAngularSpeed = function(id) return self:getConstructAngularSpeed(id) end
    closure.getConstructRadialSpeed = function(id) return self:getConstructRadialSpeed(id) end
    return closure
end

return M