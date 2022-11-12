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
-- Extends: @{Element}
-- @module RadarUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_ATMO = "RadarPvPAtmospheric"
local CLASS_SPACE = "RadarPVPSpace"
local SMALL_GROUP = "SmallGroup"
local MEDIUM_GROUP = "MediumGroup"
local LARGE_GROUP = "LargeGroup"

local elementDefinitions = {}
elementDefinitions["atmospheric radar s"] = {mass = 486.72, maxHitPoints = 88.0, itemId = 4213791403, class = CLASS_ATMO, range = 10000.0, lockRange = 2000.0}
elementDefinitions["atmospheric radar m"] = {mass = 11324.61, maxHitPoints = 698.0, itemId = 612626034, class = CLASS_ATMO, range = 10000.0, lockRange = 4000.0}
elementDefinitions["atmospheric radar l"] = {mass = 6636.8985, maxHitPoints = 12887.0, itemId = 3094514782, class = CLASS_ATMO, range = 10000.0, lockRange = 8000.0}
elementDefinitions["space radar s"] = {mass = 486.72, maxHitPoints = 88.0, itemId = 4118496992, class = CLASS_SPACE .. SMALL_GROUP, range = 400000.0, lockRange = 75000.0}
elementDefinitions["space radar m"] = {mass = 2348.45, maxHitPoints = 698.0, itemId = 3831485995, class = CLASS_SPACE .. MEDIUM_GROUP, range = 400000.0, lockRange = 150000.0}
elementDefinitions["space radar l"] = {mass = 12492.16, maxHitPoints = 12887.0, itemId = 2802863920, class = CLASS_SPACE .. LARGE_GROUP, range = 400000.0, lockRange = 300000.0}
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

    o.range = elementDefinition.range
    o.lockRange = elementDefinition.lockRange
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
    "sortMethod":0,
    "worksInEnvironment":false
},
"staticProperties":{
    "maxIdentifiedTargets":2,
    "ranges":%s,
    "worksInAtmosphere":%s,
    "worksInSpace":%s
}
}]]
local RANGES_TEMPLATE = [[{
    "identify128m":%f,
    "identify16m":%f,
    "identify32m":%f
    "identify64m":%f,
    "scan":%d
}]]
function M:getWidgetData()
    local targetId = 0
    local radarId = 123456789
    local ranges = self:getIdentifyRanges()
    local rangesString = string.format(RANGES_TEMPLATE, ranges[4], ranges[1], ranges[2], ranges[3], self.range)
    local worksInAtmosphere = self.elementClass == CLASS_ATMO
    local worksInSpace = self.elementClass == CLASS_SPACE
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, targetId, radarId,
                         rangesString, worksInAtmosphere, worksInSpace)
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- <b>Deprecated:</b> Returns 1 if the radar is not broken, works in the current environment and is not used by another control unit.
--
-- This method is deprecated: getOperationalState should be used instead
-- @see getOperationalState
-- @treturn 0/1 1 if the radar is operational, 0 otherwise.
function M:isOperational()
    M.deprecated("isOperational", "getOperationalState")
    if self:getOperationalState() == 1 then
        return 1
    end
    return 0
end

--- Returns 1 if the radar is not broken, works in the current environment and is not used by another control unit.
-- @treturn int 1 if the radar is operational, otherwise: 0 = broken, -1 = bad environment, -2 = obstructed,
--   -3 = already in use.
function M:getOperationalState()
    return 1
end

--- Returns the scan range of the radar.
-- @treturn float The scan range in meters.
function M:getRange()
    return self.range
end

--- Returns ranges to identify a target based on its core size.
-- @treturn list The list of float values for ranges in meters as { xsRange, sRange, mRange, lRange }.
function M:getIdentifyRanges()
    return {self.lockRange, self.lockRange, self.lockRange, self.lockRange}
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

--- Gets the sort method for construct data.
--
-- Possible sort methods:
-- <ul>
--   <li>1: Distance Ascending</li>
--   <li>2: Distance Descending</li>
--   <li>3: Size Ascending</li>
--   <li>4: Size Descending</li>
--   <li>5: Threat Ascending</li>
--   <li>6: Threat Descending</li>
-- </ul>
-- @treturn int The sort method.
function M:getSortMethod()
end

--- Sets the sort method for construct data.
--
-- Possible sort methods:
-- <ul>
--   <li>1: Distance Ascending</li>
--   <li>2: Distance Descending</li>
--   <li>3: Size Ascending</li>
--   <li>4: Size Descending</li>
--   <li>5: Threat Ascending</li>
--   <li>6: Threat Descending</li>
-- </ul>
-- @tparam int method The sort method.
-- @treturn 0/1 1 if the sort method was set successfully, 0 otherwise.
function M:setSortMethod(method)
    return 1
end

--- Returns the list of identified construct IDs.
-- @treturn list The list of identified construct IDs.
function M:getIdentifiedConstructIds()
end

--- Returns a list of constructs in a given range according to the sort method.
-- @tparam int offset Offset from the first entry.
-- @tparam int size Total entries to return following the offset, 0 to return all entries.
-- @treturn list The list of constructs.
function M:getConstructs(offset, size)
    return {}
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

--- Returns the core size of the given construct.
-- @tparam int id The ID of the construct.
-- @treturn string The core size name; can be: XS, S, M, L
function M:getConstructCoreSize(id)
end

--- <b>Deprecated:</b> Returns the threat rate your construct is for the given construct.
--
-- This method is deprecated: getThreatRateTo should be used instead
-- @see getThreatRateTo
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatTo(id)
    M.deprecated("getThreatTo", "getThreatRateTo")
    return self:getThreatRateTo(id)
end

--- Returns the threat rate your construct is for the given construct.
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatRateTo(id)
end

--- <b>Deprecated:</b> Returns the threat rate the given construct is for your construct.
--
-- This method is deprecated: getThreatRateFrom should be used instead
-- @see getThreatRateFrom
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatFrom(id)
    M.deprecated("getThreatFrom", "getThreatRateFrom")
    return self:getThreatRateFrom(id)
end

--- Returns the threat rate the given construct is for your construct.
-- @tparam int id The ID of the construct.
-- @treturn string none, identified, threatened_identified, threatened, attacked
function M:getThreatRateFrom(id)
end

--- Returns whether the target has an active transponder with matching tags.
-- @tparam int id The ID of the construct.
-- @treturn 1/0 1 if our construct and the target have active transponders with matching tags, 0 otherwise.
function M:hasMatchingTransponder(id)
    return 0
end

--- <b>Deprecated:</b> Returns a table with id of the owner entities (player or organization) of the given construct,
-- if in range and if active transponder tags match.
--
-- This method is deprecated: getConstructOwnerEntity should be used instead
-- @see getConstructOwnerEntity
-- @tparam int id The ID of the construct.
-- @treturn table A table { playerId: pID, organizationId: oID } describing the owner. Use 
--   @{system:getPlayerName|system.getPlayerName(pID)} and
--   @{system:getOrganizationName|system.getOrganizationName(oID)} to retrieve info about it.
-- @see system:getPlayerName
-- @see system:getOrganizationName
function M:getConstructOwner(id)
    M.deprecated("getConstructOwner", "getConstructOwnerEntity")
    return self:getConstructOwnerEntity(id)
end

--- Returns a table with id of the owner entity (player or organization) of the given construct, if in range and if
-- active transponder tags match for owned dynamic constructs.
-- @tparam int id the ID of the construct.
-- @treturn table A table with fields {[int] id, [bool] isOrganization} descriving the owner. Use
--   @{system:getPlayerName} and @{system:getOrganization} to retrieve info about it.
function M:getConstructOwnerEntity(id)
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

--- <b>Deprecated:</b> Return the type of the given construct.
--
-- This method is deprecated: getConstructKind should be used instead
-- @see getConstructKind
-- @tparam int id The ID of the construct.
-- @treturn string The type of the construct,: can be 'static', 'space' or 'dynamic'.
function M:getConstructType(id)
    M.deprecated("getConstructType", "getConstructKind")
    if self.entries[id] then
        return self.entries[id].type
    end
    return nil
end

--- Returns the kind of the given construct.
--
-- Possible kinds:
-- <ul>
--   <li>1: Universe</li>
--   <li>2: Planet</li>
--   <li>3: Asteroid</li>
--   <li>4: Static</li>
--   <li>5: Dynamic</li>
--   <li>6: Space</li>
--   <li>7: Alien</li>
-- </ul>
-- @tparam int id the ID of the construct.
-- @treturn int The kind index of the construct.
function M:getConstructKind(id)
end

--- Returns the position of the given construct in construct local coordinates, if the active transponder tags match
-- for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz local coordinates relative to the construct center.
function M:getConstructPos(id)
    if self.entries[id] then
        return self.entries[id].pos
    end
    return nil
end

--- Returns the position of the given construct in world coordinates, if in range and if the active transponder tags
-- match for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct center.
function M:getConstructWorldPos(id)
end

--- Returns the velocity vector of the given construct in construct local coordinates, if identified and if the active
-- transponder tags match for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz local coordinates of the construct velocity.
function M:getConstructVelocity(id)
end

--- Returns the velocity vector of the given construct in world coordinates, if identified and if the active
-- transponder tags match for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn vec3 The xyz world coordinates of the construct velocity.
function M:getConstructWorldVelocity(id)
end

--- Returns the mass of the given construct, if identified for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn float the mass of the construct in kilograms.
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

--- Returns a list of working elements on the given construction, if identified for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn table A table {[float] weapons, [float] radars, [float] antiGravity], [float] atmoEngines,
--   [float] spaceEngines, [float] rocketEngines} with values between 0.0 and 1.0. Exceptionally antiGravity and
--   rocketEngines are always 1.0 if present, even if broken.
function M:getConstructInfos(id)
end

--- Returns the speed of the given construct, if identified for owned dynamic constructs.
-- @tparam int id the ID of the construct.
-- @treturn float The speed of the construct relative to the universe in meters per second.
function M:getConstructSpeed(id)
end

--- Returns the angular speed of the given construct to your construct, if identified for owned dynamic constructs.
-- @tparam int id The ID of the construct.
-- @treturn float The angular speed of the construct relative to your construct in radians per second.
function M:getConstructAngularSpeed(id)
end

--- Returns the radial speed of the given construct to your construct, if identified for owned dynamic constructs.
-- @tparam int id The id of the construct.
-- @treturn float The radial speed of the construct relative to your construct in meters per second.
function M:getConstructRadialSpeed(id)
end

--- <b>Deprecated:</b> Event: Emitted when a construct enters the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onEnter should be used instead.
-- @see EVENT_onEnter
-- @tparam int id ID of the construct; can be used with @{game_data_lua.database.getConstruct|database.getConstruct} to
--   retrieve info about it.
-- @see game_data_lua.database.getConstruct
function M.EVENT_enter(id)
    M.deprecated("EVENT_enter", "EVENT_onEnter")
    M.EVENT_onEnter(id)
end

--- Event: Emitted when a construct enters the scan range of the radar.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the construct.
function M.EVENT_onEnter(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterEnter")
end

--- <b>Deprecated:</b> Event: Emitted when a construct leaves the range of the radar unit.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onLeave should be used instead.
-- @see EVENT_onLeave
-- @tparam int id ID of the construct; can be used with @{game_data_lua.database.getConstruct|database.getConstruct} to
--   retrieve info about it.
-- @see game_data_lua.database.getConstruct
function M.EVENT_leave(id)
    M.deprecated("EVENT_leave", "EVENT_onLeave")
    M.EVENT_onLeave(id)
end

--- Event: Emitted when a construct leaves the range of the radar.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the construct.
function M.EVENT_onLeave(id)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterLeave")
end

--- Event: Emitted when a construct is identified.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the construct.
function M.EVENT_onIdentified(id)
    assert(false, "This is implemented for documentation purposes.")
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
    closure.getOperationalState = function() return self:getOperationalState() end
    closure.getRange = function() return self:getRange() end
    closure.getIdentifyRanges = function() return self:getIdentifyRanges() end
    closure.getConstructIds = function() return self:getConstructIds() end
    closure.getSortMethod = function() return self:getSortMethod() end
    closure.setSortMethod = function(method) return self:setSortMethod(method) end
    closure.getIdentifiedConstructIds = function() return self:getIdentifiedConstructIds() end
    closure.getConstructs = function(offset, size) return self:getConstructs(offset, size) end
    closure.getTargetId = function() return self:getTargetId() end
    closure.getConstructDistance = function(id) return self:getConstructDistance(id) end
    closure.isConstructIdentified = function(id) return self:isConstructIdentified(id) end
    closure.isConstructAbandoned = function(id) return self:isConstructAbandoned(id) end
    closure.getConstructCoreSize = function(id) return self:getConstructCoreSize(id) end
    closure.getThreatTo = function(id) return self:getThreatTo(id) end
    closure.getThreatRateTo = function(id) return self:getThreatRateTo(id) end
    closure.getThreatFrom = function(id) return self:getThreatFrom(id) end
    closure.getThreatRateFrom = function(id) return self:getThreatRateFrom(id) end
    closure.hasMatchingTransponder = function(id) return self:hasMatchingTransponder(id) end
    closure.getConstructOwner = function(id) return self:getConstructOwner(id) end
    closure.getConstructOwnerEntity = function(id) return self:getConstructOwnerEntity(id) end
    closure.getConstructSize = function(id) return self:getConstructSize(id) end
    closure.getConstructType = function(id) return self:getConstructType(id) end
    closure.getConstructKind = function(id) return self:getConstructKind(id) end
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