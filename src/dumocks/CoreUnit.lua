--- This is the heart of your construct. It represents the construct and gives access to all construct-related
-- information.
--
-- Element class:
-- <ul>
--   <li>CoreUnitDynamic</li>
--   <li>CoreUnitStatic</li>
--   <li>CoreUnitSpace</li>
-- </ul>
--
-- Extends: @{Element}
-- @module CoreUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_DYNAMIC = "CoreUnitDynamic"
local CLASS_STATIC = "CoreUnitStatic"
local CLASS_SPACE = "CoreUnitSpace"

local elementDefinitions = {}
elementDefinitions["dynamic core unit xs"] = {mass = 70.89, maxHitPoints = 50.0, itemId = 183890713, class = CLASS_DYNAMIC}
elementDefinitions["dynamic core unit s"] = {mass = 375.97, maxHitPoints = 183.0, itemId = 183890525, class = CLASS_DYNAMIC}
elementDefinitions["dynamic core unit m"] = {mass = 1984.6, maxHitPoints = 1288.0, itemId = 1418170469, class = CLASS_DYNAMIC}
elementDefinitions["dynamic core unit l"] = {mass = 12141.47, maxHitPoints = 11541.0, itemId = 1417952990, class = CLASS_DYNAMIC}
elementDefinitions["space core unit xs"] = {mass = 38.99, maxHitPoints = 50.0, itemId = 3624942103, class = CLASS_SPACE}
elementDefinitions["space core unit s"] = {mass = 459.57, maxHitPoints = 183.0, itemId = 3624940909, class = CLASS_SPACE}
elementDefinitions["space core unit m"] = {mass = 3037.5395, maxHitPoints = 1288.0, itemId = 5904195, class = CLASS_SPACE}
elementDefinitions["space core unit l"] = {mass = 7684.51425, maxHitPoints = 11541.0, itemId = 5904544, class = CLASS_SPACE}
elementDefinitions["static core unit xs"] = {mass = 70.89, maxHitPoints = 50.0, itemId = 2738359963, class = CLASS_STATIC}
elementDefinitions["static core unit s"] = {mass = 360.18, maxHitPoints = 167.0, itemId = 2738359893, class = CLASS_STATIC}
elementDefinitions["static core unit m"] = {mass = 1926.91, maxHitPoints = 1184.0, itemId = 909184430, class = CLASS_STATIC}
elementDefinitions["static core unit l"] = {mass = 10066.3, maxHitPoints = 10710.0, itemId = 910155097, class = CLASS_STATIC}
local DEFAULT_ELEMENT = "dynamic core unit xs"

local MAX_STICKERS = 10
local FIRST_ARROW_STICKER_INDEX = 19
local FIRST_NUMBER_STICKER_INDEX = 9

local M = MockElement:new()
M.widgetType = "core"
M.helperId = "core"
M.remainingRestorations = 0
M.maxRestorations = 0

function M:new(o, id, elementName)
    id = id or 1
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.constructName = ""
    o.constructMass = 0 -- kg
    o.constructIMass = 0 -- kg*m2
    o.constructCrossSection = 0 -- m2
    o.constructWorldPos = {0, 0, 0} -- vec3
    o.constructId = 0
    o.worldAirFrictionAngularAcceleration = {0, 0, 0} -- vec3
    o.worldAirFrictionAcceleration = {0, 0, 0} -- vec3
    -- map: UID => {name="", type="", position={0,0,0}, rotation={0,0,0,0}, tags="", hp=0.0, maxHp=0.0, mass=0.0}
    o.elements = {}
    o.elements[id] = {
        name = o.name,
        -- type = string.match("%w+ %w+", elementDefinition), -- first two words of definition ("dynamic core")
        hp = o.hitPoints,
        position = {0, 0, 0},
    }
    o.altitude = 0 -- m
    o.gValue = 0 -- m/s2
    o.worldGravity = 0 -- m/s2
    o.worldVertical = 0 -- m/s2
    o.angularVelocity = 0 -- rad/s
    o.worldAngularVelocity = 0 -- rad/s
    o.angularAcceleration = 0 -- rad/s2
    o.worldAngularAcceleration = 0 -- rad/s2
    o.velocity = 0 -- m/s
    o.worldVelocity = {0, 0, 0} -- m/s
    o.acceleration = 0 -- m/s2
    o.worldAcceleration = 0 -- m/s2
    o.constructOrientationUp = {0, 0, 0} -- vec3
    o.constructOrientationRight = {0, 0, 0} -- vec3
    o.constructOrientationForward = {0, 0, 0} -- vec3
    o.constructWorldOrientationUp = {0, 0, 0} -- vec3
    o.constructWorldOrientationRight = {0, 0, 0} -- vec3
    o.constructWorldOrientationForward = {0, 0, 0} -- vec3
    o.currentStress = 0
    o.maxStress = 0

    o.stickers = {}

    o.pvpTimer = 0.0

    return o
end

local function formatFloat(float)
    if float == 0 then
        return "0.0"
    end
    return string.format("%.15f", float)
end

local DATA_TEMPLATE =
    '{"helperId":"%s","type":"%s","name":"%s","altitude":%f,"gravity":%s,"currentStress":%s,"maxStress":%s}'
--- Get element data as JSON.
--
-- Core units create a <code>core</code> widget, which is modified by the bold fields below when making custom use of
-- the widget. The data also supports a <code>core_stress</code> widget, which is documented in
-- @{system:createWidget|system}.
-- <ul>
--   <li><b><span class="parameter">altitude</span></b> (<span class="type">float</span>) Altitude in meters.</li>
--   <li><b><span class="parameter">gravity</span></b> (<span class="type">float</span>) Gravity in m/s<sup>2</sup>.</li>
--   <li><span class="parameter">currentStress</span> (<span class="type">float</span>) Current core stress.</li>
--   <li><span class="parameter">maxStress</span> (<span class="type">float</span>) Max core stress.</li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>core</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>core</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    local gString = formatFloat(self:getGravityIntensity())
    local cStressString = formatFloat(self.currentStress)
    local mStressString = formatFloat(self.maxStress)
    return string.format(DATA_TEMPLATE, self.helperId, self:getWidgetType(), self.name, self:getAltitude(), gString,
                            cStressString, mStressString)
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Spawns a number sticker in the 3D world, with coordinates relative to the construct.
-- @tparam int nb The number to display 0 to 9.
-- @tparam float x The x-coordinate in the construct in meters. 0 = center.
-- @tparam float y The y-coordinate in the construct in meters. 0 = center.
-- @tparam float z The z-coordinate in the construct in meters. 0 = center.
-- @tparam string orientation Orientation of the number. Possible values are "front", "side".
-- @treturn int An index that can be used later to delete or move the item. -1 if error or maxnumber (10) reached.
function M:spawnNumberSticker(nb, x, y, z, orientation)
    nb = tonumber(nb)
    if type(nb) ~= "number" or nb < 0 then
        nb = 0
    elseif nb > 9 then
        nb = 9
    end

    local nextIndex = -1
    for i = FIRST_NUMBER_STICKER_INDEX, 0, -1 do
        if not self.stickers[i] then
            nextIndex = i
            break
        end
    end

    if nextIndex ~= -1 then
        self.stickers[nextIndex] = {type = "number", x = x, y = y, z = z, value = nb, facing = orientation}
    end

    return nextIndex
end


--- Returns the list of all the local IDs of the elements of this construct.
-- @treturn list The list of element local IDs.
function M:getElementIdList()
    local ids = {}
    for id,_ in pairs(self.elements) do
        table.insert(ids, id)
    end
    return ids
end

--- Returns the name of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn string The name of the element.
function M:getElementNameById(localId)
    if self.elements[localId] and self.elements[localId].name then
        return self.elements[localId].name
    end
    return ""
end

--- Returns the class of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn string The class of the element.
function M:getElementClassById(localId)
end

--- <b>Deprecated:</b> Type of the element, identified by its UID.
--
-- This method is deprecated: getElementDisplayNameById should be used instead.
-- @see getElementDisplayNameById
-- @tparam int uid The UID of the element.
-- @treturn string The type of the element.
function M:getElementTypeById(uid)
    M.deprecated("getElementTypeById", "getElementDisplayNameById")
    return self:getElementDisplayNameById(uid)
end

--- Returns the display name of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn string The display name of the element.
function M:getElementDisplayNameById(localId)
end

--- Returns the item ID of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn int The item ID of the element.
function M:getElementItemIdById(localId)
end

--- Returns the current level of hit points of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn float Current level of hit points of the element.
function M:getElementHitPointsById(localId)
    if self.elements[localId] and self.elements[localId].hp then
        return self.elements[localId].hp
    end
    return 0.0
end

--- Returns the maximum level of hit points of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn float The max level of hit points of the element.
function M:getElementMaxHitPointsById(localId)
    if self.elements[localId] and self.elements[localId].maxHp then
        return self.elements[localId].maxHp
    end
    return 0.0
end

--- Returns the mass of the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn float The mass of the element in kilograms.
function M:getElementMassById(localId)
    if self.elements[localId] and self.elements[localId].mass then
        return self.elements[localId].mass
    end
    return 0.0
end

--- Returns the position of the element, identified by its local ID, in construct local coordinates.
-- @tparam int localId The local ID of the element.
-- @treturn vec3 The position of the element in construct local coordinates.
function M:getElementPositionById(localId)
    if self.elements[localId] and self.elements[localId].position then
        return self.elements[localId].position
    end
    return {}
end

--- Returns the up direction vector of the element, identified by its local ID, in construct local coordinates.
-- @tparam int localId The local ID of the element.
-- @treturn vec3 The up direction vector of the element identified by its local ID, in construct local coordinates.
function M:getElementUpById(localId)
end

--- Returns the right direction vector of the element, identified by its local ID, in construct local coordinates.
-- @tparam int localId The local ID of the element.
-- @treturn vec3 The right direction vector of the element identified by its local ID, in construct local coordinates.
function M:getElementRightById(localId)
end

--- Returns the forward direction vector of the element, identified by its local ID, in construct local coordinates.
-- @tparam int localId The local ID of the element.
-- @treturn vec3 The forward direction vector of the element identified by its local ID, in construct local
--   coordinates.
function M:getElementForwardById(localId)
end

--- <b>Deprecated:</b> Status of the industry unit element, identified by its UID.
--
-- This method is deprecated: getElementIndustryInfoById should be used instead.
-- @see getElementIndustryInfoById
-- @tparam int uid The UID of the element.
-- @treturn json If the element is an industry unit, this returns a json (to be parsed with json.decode) with: state,
-- schematicId, stopRequested, unitsProduced, remainingTime, batchesRequested, batchesRemaining, maintainProductAmount,
-- currentProductAmount.
function M:getElementIndustryStatusById(uid)
    M.deprecated("getElementIndustryStatusById", "getElementIndustryInfoById")
end

--- Returns the information of the industry unit element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn table If the element is an industry unit, a table with fields {[integer] state, [bool] stopRequested,
--   [integer] schematicsRemaining, [integer] unitsProduced, [integer] remainingTime, [integer] batchesRequested,
--   [integer] batchesRemaining, [number] maintainProductAmount, [integer] currentProductAmount,
--   [table] currentProducts:{{[integer] id, [number] quantity},...}}
function M:getElementIndustryInfoById(localId)
end

--- Returns the list of tags associated to the element, identified by its local ID.
-- @tparam int localId The local ID of the element.
-- @treturn string The tags as JSON list.
function M:getElementTagsById(localId)
    if self.elements[localId] and self.elements[localId].tags then
        return self.elements[localId].tags
    end
    return {}
end

--- Returns the altitude above sea level, with respect to the closest planet (0 in space).
-- @treturn float The sea level altitude in meters.
function M:getAltitude()
    if self.elementClass == CLASS_SPACE then
        -- returns 0.0 for space construct
        return 0.0
    end
    return self.altitude
end

--- <b>Deprecated:</b> Local gravity intensity.
--
-- This method is deprecated: getGravityIntensity should be used instead.
-- @see getGravityIntensity
-- @treturn m/s2 The gravitation acceleration where the construct is located.
function M:g()
    M.deprecated("g", "getGravityIntensity")
    self:getGravityIntensity()
end

--- Returns the local gravity intensity.
-- @treturn float The gravitation acceleration where the construct is located in meters / second square.
function M:getGravityIntensity()
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns 0.0 for static and space construct
        return 0.0
    end
    return self.gValue
end

--- Returns the local gravity vector in world coordinates.
-- @treturn vec3 The local gravity field vector in world coordinates in m/s2.
function M:getWorldGravity()
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    -- sample dynamic value: {1.5739563655308,-9.33176430249,-2.8107843460705}
    return self.worldGravity
end

--- Returns the vertical unit vector along gravity, in world coordinates (0 in space).
-- @treturn vec3 The local vertical vector in world coordinates in meters.
function M:getWorldVertical()
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    -- sample dynamic value: {0.15943373305866,-0.94526001568521, -0.28471808426895}
    return self.worldVertical
end

--- Returns the id of the current close stellar body.
-- @treturn int The id of the current close stellar body.
function M:getCurrentPlanetId()
end

--- Returns the core's current stress, destroyed when reaching max stress.
-- @treturn float The stress the core absorbed.
function M:getCoreStress()
    return self.currentStress
end

--- Returns the maximal stress the core can bear before it gets destroyed.
-- @treturn float The maximal stress before destruction.
function M:getMaxCoreStress()
    return self.maxStress
end

--- Returns the core's current stress to max stress ratio.
-- @treturn float The stress ratio, between 0 for no stress and 1 for destruction.
function M:getCoreStressRatio()
    return self.currentStress / self.maxStress
end

--- Spawns an arrow sticker in the 3D world, with coordinates relative to the construct.
-- @tparam float x The x-coordinate in the construct in meters. 0 = center.
-- @tparam float y The y-coordinate in the construct in meters. 0 = center.
-- @tparam float z The z-coordinate in the construct in meters. 0 = center.
-- @tparam string orientation Orientation of the number. Possible values are "up" (+z), "down" (-z), "north" (-x),
--   "south" (+x), "east" (+y), "west" (-y).
-- @treturn int An index that can be used later to delete or move the item. -1 if error or maxnumber (10) reached.
function M:spawnArrowSticker(x, y, z, orientation)
    local nextIndex = -1
    for i = FIRST_ARROW_STICKER_INDEX, 10, -1 do
        if not self.stickers[i] then
            nextIndex = i
            break
        end
    end

    if nextIndex ~= -1 then
        self.stickers[nextIndex] = {type = "arrow", x = x, y = y, z = z, value = orientation}
    end

    return nextIndex
end

--- Delete the referenced sticker.
-- @tparam int index Index of the sticker to delete.
-- @treturn int 0 in case of success, -1 otherwise.
function M:deleteSticker(index)
    local success = self.stickers[index] ~= nil

    self.stickers[index] = nil

    if success then
        return 0
    end
    return -1
end

--- Move the referenced sticker.
-- @tparam int index Index of the sticker to move.
-- @tparam float x The x-coordinate in the construct in meters. 0 = center.
-- @tparam float y The y-coordinate in the construct in meters. 0 = center.
-- @tparam float z The z-coordinate in the construct in meters. 0 = center.
-- @treturn int 0 in case of success, -1 otherwise.
function M:moveSticker(index, x, y, z)
    if self.stickers[index] == nil then
        return -1
    end

    self.stickers[index].x = x
    self.stickers[index].y = y
    self.stickers[index].z = z
    return 0
end

--- Rotate the referenced sticker.
-- @tparam int index Index of the sticker to move.
-- @tparam float angle_x Rotation along the x-axis in degrees.
-- @tparam float angle_y Rotation along the y-axis in degrees.
-- @tparam float angle_z Rotation along the z-axis in degrees.
-- @treturn int 1 in case of success, 0 otherwise
function M:rotateSticker(index, angle_x, angle_y, angle_z)
    -- TODO implement something to mock this method
    return 0
end

--- <b>Deprecated:</b> Returns the name of the construct.
--
-- This method is deprecated: construct.getName should be used instead.
-- @see construct.getName
-- @treturn string The name of the construct.
function M:getConstructName()
    M.deprecated("getConstructName", "construct.getName")
    return self.constructName
end

--- <b>Deprecated:</b> Returns the mass of the construct.
--
-- Note: Only defined for dynamic cores.
--
-- This method is deprecated: construct.getMass should be used instead.
-- @see construct.getMass
-- @treturn kg The mass of the construct.
function M:getConstructMass()
    M.deprecated("getConstructMass", "construct.getMass")
    return self.constructMass
end

--- <b>Deprecated:</b> Returns the inertial mass of the construct, calculated as 1/3 of the trace of the inertial
-- tensor.
--
-- Note: Only defined for dynamic cores.
--
-- This method is deprecated: construct.getInertialMass should be used instead.
-- @see construct.getInertialMass
-- @treturn kg*m2 The inertial mass of the construct.
function M:getConstructIMass()
    M.deprecated("getConstructIMass", "construct.getInertialMass")
    return self.constructIMass
end

--- <b>Deprecated:</b> Returns the construct's cross sectional surface in the current direction of movement.
--
-- Note: Only defined for dynamic cores.
--
-- This method is deprecated: construct.getCrossSection should be used instead.
-- @see construct.getCrossSection
-- @treturn m2 The construct's surface exposed in the current direction of movement.
function M:getConstructCrossSection()
    M.deprecated("getConstructCrossSection", "construct.getCrossSection")
    return self.constructCrossSection
end

--- <b>Deprecated:</b> Returns the construct max kinematics parameters in both atmo and space range, in newtons. Kinematics parameters
-- designate here the maximal positive and negative base force the construct is capable of producing along the chosen
-- Axisvector, as defined by the core unit or the gyro unit, if active. In practice, this gives you an estimate of the
-- maximum thrust your ship is capable of producing in space or in atmosphere, as well as the max reverse thrust. These
-- are theoretical estimates and correspond with the addition of the maxThrustBase along the corresponding axis. It
-- might not reflect the accurate current max thrust capacity of your ship, which depends on various local conditions
-- (atmospheric density, orientation, obstruction, engine damage, etc). This is typically used in conjunction with the
-- control unit throttle to setup the desired forward acceleration.
--
-- Note: Only defined for dynamic cores.
--
-- This method is deprecated: construct.getMaxThrustAlongAxis should be used instead.
-- @see construct.getMaxThrustAlongAxis
-- @tparam csv taglist Comma (for union) or space (for intersection) separated list of tags. You can set tags directly
-- on the engines in the right-click menu.
-- @tparam vec3 CRefAxis Axis along which to compute the max force (in construct reference).
-- @treturn vec4,Newton The kinematics parameters in the order: atmoRange.FMaxPlus, atmoRange.FMaxMinus,
-- spaceRange.FMaxPlus, spaceRange.FMaxMinus
function M:getMaxKinematicsParametersAlongAxis(taglist, CRefAxis)
    M.deprecated("getMaxKinematicsParametersAlongAxis", "construct.getMaxThrustAlongAxis")
    -- TODO implement something to mock this method
end

--- <b>Deprecated:</b> Returns the world position of the construct.
--
-- This method is deprecated: construct.getWorldPosition should be used instead.
-- @see construct.getWorldPosition
-- @treturn vec3 The xyz world coordinates of the construct center position.
function M:getConstructWorldPos()
    M.deprecated("getConstructWorldPos", "construct.getWorldPosition")
    return self.constructWorldPos
end

--- <b>Deprecated:</b> Returns the construct unique ID.
--
-- This method is deprecated: construct.getId should be used instead.
-- @see construct.getId
-- @treturn int The unique ID. Can be used with @{game_data_lua.database.getConstruct|database.getConstruct} to
--   retrieve info about the construct.
-- @see game_data_lua.database:getConstruct
function M:getConstructId()
    M.deprecated("getConstructId", "construct.getId")
    return self.constructId
end

--- <b>Deprecated:</b> Returns the acceleration torque generated by air resistance.
--
-- This method is deprecated: construct.getWorldAirFrictionAngularAcceleration should be used instead.
-- @see construct.getWorldAirFrictionAngularAcceleration
-- @treturn vec3 The xyz world acceleration torque generated by air resistance.
function M:getWorldAirFrictionAngularAcceleration()
    M.deprecated("getWorldAirFrictionAngularAcceleration", "construct.getWorldAirFrictionAngularAcceleration")
    return self.worldAirFrictionAngularAcceleration
end

--- <b>Deprecated:</b> Returns the acceleration generated by air resistance.
--
-- This method is deprecated: construct.getWorldAirFrictionAcceleration should be used instead.
-- @see construct.getWorldAirFrictionAcceleration
-- @treturn vec3 The xyz world acceleration generated by air resistance.
function M:getWorldAirFrictionAcceleration()
    M.deprecated("getWorldAirFrictionAcceleration", "construct.getWorldAirFrictionAcceleration")
    return self.worldAirFrictionAcceleration
end

--- <b>Deprecated:</b> Retrieves schematic details for the id provided as json.
--
-- This method is deprecated: system.getSchematic should be used instead.
-- @see system.getSchematic
-- @tparam int schematicId The id of the schematic to query, example: 1199082577 for Pure Aluminium refining.
-- @treturn jsonstr The schematic defails as a json object with fields: id, time, level, ingredients, products; where
-- ingredients and products are lists of json objects with fields: name, quantity, type
function M:getSchematicInfo(schematicId)
    M.deprecated("getSchematicInfo", "system.getSchematic")
end

--- <b>Deprecated:</b> The construct's angular velocity, in construct local coordinates.
--
-- This method is deprecated: construct.getAngularVelocity should be used instead.
-- @see construct.getAngularVelocity
-- @treturn rad/s Angular velocity vector, in construct local coordinates.
function M:getAngularVelocity()
    M.deprecated("getAngularVelocity", "construct.getAngularVelocity")
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    return self.angularVelocity
end

--- <b>Deprecated:</b> The constructs angular velocity, in world coordinates.
--
-- This method is deprecated: construct.getWorldAngularVelocity should be used instead.
-- @see construct.getWorldAngularVelocity
-- @treturn rad/s Angular velocity vector, in world coordinates.
function M:getWorldAngularVelocity()
    M.deprecated("getWorldAngularVelocity", "construct.getWorldAngularVelocity")
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    return self.worldAngularVelocity
end

--- <b>Deprecated:</b> The construct's angular acceleration, in construct local coordinates.
--
-- This method is deprecated: construct.getAngularAcceleration should be used instead.
-- @see construct.getAngularAcceleration
-- @treturn rad/s2 Angular acceleration vector, in construct local coordinates.
function M:getAngularAcceleration()
    M.deprecated("getAngularAcceleration", "construct.getAngularAcceleration")
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    return self.angularAcceleration
end

--- <b>Deprecated:</b> The construct's angular acceleration, in world coordinates.
--
-- This method is deprecated: construct.getWorldAngularAcceleration should be used instead.
-- @see construct.getWorldAngularAcceleration
-- @treturn rad/s2 Angular acceleration vector, in world coordinates.
function M:getWorldAngularAcceleration()
    M.deprecated("getWorldAngularAcceleration", "construct.getWorldAngularAcceleration")
    if self.elementClass ~= CLASS_DYNAMIC then
        -- returns {0.0, 0.0, 0.0} for static and space construct
        return {0.0, 0.0, 0.0}
    end
    return self.worldAngularAcceleration
end

--- <b>Deprecated:</b> The construct's linear velocity, relative to its parent, in construct local coordinates.
--
-- This method is deprecated: construct.getVelocity should be used instead.
-- @see construct.getVelocity
-- @treturn m/s Relative linear velocity vector, in construct local coordinates.
function M:getVelocity()
    M.deprecated("getVelocity", "construct.getVelocity")
    return self.velocity
end

--- <b>Deprecated:</b> The construct's linear velocity, relative to its parent, in world coordinates.
--
-- This method is deprecated: construct.getWorldVelocity should be used instead.
-- @see construct.getWorldVelocity
-- @treturn m/s Relative linear velocity vector, in world coordinates.
function M:getWorldVelocity()
    M.deprecated("getWorldVelocity", "construct.getWorldVelocity")
    return self.worldVelocity
end

--- <b>Deprecated:</b> The construct's absolute linear velocity, in construct local coordinates.
--
-- This method is deprecated: construct.getAbsoluteVelocity should be used instead.
-- @see construct.getAbsoluteVelocity
-- @treturn m/s Absolute linear velocity vector, in construct local coordinates.
function M:getAbsoluteVelocity()
    M.deprecated("getAbsoluteVelocity", "construct.getAbsoluteVelocity")
end

--- <b>Deprecated:</b> The construct's absolute linear velocity, in world coordinates.
--
-- This method is deprecated: construct.getWorldAbsoluteVelocity should be used instead.
-- @see construct.getWorldAbsoluteVelocity
-- @treturn m/s Absolute linear velocity vector, in world coordinates.
function M:getWorldAbsoluteVelocity()
    M.deprecated("getWorldAbsoluteVelocity", "construct.getWorldAbsoluteVelocity")
end

--- <b>Deprecated:</b> The construct's linear acceleration, in world coordinates.
--
-- This method is deprecated: construct.getWorldAcceleration should be used instead.
-- @see construct.getWorldAcceleration
-- @treturn m/s2 Linear acceleration vector, in world coordinates.
function M:getWorldAcceleration()
    M.deprecated("getConstructName", "construct.getWorldAcceleration")
    return self.getWorldAcceleration
end

--- <b>Deprecated:</b> The construct's linear acceleration, in construct local coordinates.
--
-- This method is deprecated: construct.getAcceleration should be used instead.
-- @see construct.getAcceleration
-- @treturn m/s2 Linear acceleration vector, in construct local coordinates.
function M:getAcceleration()
    M.deprecated("getAcceleration", "construct.getAcceleration")
    return self.acceleration
end

--- <b>Deprecated:</b> Returns the uid of the current active orientation unit (core unit or gyro unit).
--
-- This method is deprecated: construct.getOrientationUnitId should be used instead.
-- @see construct.getOrientationUnitId
-- @treturn int Uid of the current active orientation unit (core unit or gyro unit).
function M:getOrientationUnitId()
    M.deprecated("getOrientationUnitId", "construct.getOrientationUnitId")
end

--- <b>Deprecated:</b> Returns the up direction vector of the active orientation unit, in construct local coordinates.
--
-- This method is deprecated: construct.getOrientationUp should be used instead.
-- @see construct.getOrientationUp
-- @treturn vec3 Up direction vector of the active orientation unit, in construct local coordinates.
function M:getConstructOrientationUp()
    M.deprecated("getConstructOrientationUp", "construct.getOrientationUp")
    return self.constructOrientationUp
end

--- <b>Deprecated:</b> Returns the right direction vector of the active orientation unit, in construct local coordinates.
--
-- This method is deprecated: construct.getOrientationRight should be used instead.
-- @see construct.getOrientationRight
-- @treturn vec3 Right direction vector of the active orientation unit, in construct local coordinates.
function M:getConstructOrientationRight()
    M.deprecated("getConstructOrientationRight", "construct.getOrientationRight")
    return self.constructOrientationRight
end

--- <b>Deprecated:</b> Returns the forward direction vector of the active orientation unit, in construct local coordinates.
--
-- This method is deprecated: construct.getOrientationForward should be used instead.
-- @see construct.getOrientationForward
-- @treturn vec3 Forward direction vector of the active orientation unit, in construct local coordinates.
function M:getConstructOrientationForward()
    M.deprecated("getConstructOrientationForward", "construct.getOrientationForward")
    return self.constructOrientationForward
end

--- <b>Deprecated:</b> Returns the up direction vector of the active orientation unit, in world coordinates.
--
-- This method is deprecated: construct.getWorldOrientationUp should be used instead.
-- @see construct.getWorldOrientationUp
-- @treturn vec3 Up direction vector of the active orientation unit, in world coordinates.
function M:getConstructWorldOrientationUp()
    M.deprecated("getConstructWorldOrientationUp", "construct.getWorldOrientationUp")
    return self.constructWorldOrientationUp
end

--- <b>Deprecated:</b> Returns the right direction vector of the active orientation unit, in world coordinates.
--
-- This method is deprecated: construct.getWorldOrientationRight should be used instead.
-- @see construct.getWorldOrientationRight
-- @treturn vec3 Right direction vector of the active orientation unit, in world coordinates.
function M:getConstructWorldOrientationRight()
    M.deprecated("getConstructWorldOrientationRight", "construct.getWorldOrientationRight")
    return self.constructWorldOrientationRight
end

--- <b>Deprecated:</b> Returns the forward direction vector of the active orientation unit, in world coordinates.
--
-- This method is deprecated: construct.getWorldOrientationForward should be used instead.
-- @see construct.getWorldOrientationForward
-- @treturn vec3 Forward direction vector of the active orientation unit, in world coordinates.
function M:getConstructWorldOrientationForward()
    M.deprecated("getConstructWorldOrientationForward", "construct.getWorldOrientationForward")
    return self.constructWorldOrientationForward
end

--- <b>Deprecated:</b> Returns the up direction vector of the construct, in world coordinates.
--
-- This method is deprecated: construct.getWorldUp should be used instead.
-- @see construct.getWorldUp
-- @treturn vec3 Up direction vector of the construct, in world coordinates.
function M:getConstructWorldUp()
    M.deprecated("getConstructWorldUp", "construct.getWorldUp")
end

--- <b>Deprecated:</b> Returns the right direction vector of the construct, in world coordinates.
--
-- This method is deprecated: construct.getWorldRight should be used instead.
-- @see construct.getWorldRight
-- @treturn vec3 Right direction vector of the construct, in world coordinates.
function M:getConstructWorldRight()
    M.deprecated("getConstructWorldRight", "construct.getWorldRight")
end

--- <b>Deprecated:</b> Returns the Forward direction vector of the construct, in world coordinates.
--
-- This method is deprecated: construct.getWorldForward should be used instead.
-- @see construct.getWorldForward
-- @treturn vec3 Forward direction vector of the construct, in world coordinates.
function M:getConstructWorldForward()
    M.deprecated("getConstructWorldForward", "construct.getWorldForward")
end

--- <b>Deprecated:</b> The construct's current state of the PvP timer.
--
-- This method is deprecated: construct.getPvPTimer should be used instead.
-- @see construct.getPvPTimer
-- @treturn float Positive remaining time of the PvP timer, or 0.0 if elapsed.
function M:getPvPTimer()
    M.deprecated("getPvPTimer", "construct.getPvPTimer")
    return self.pvpTimer
end

--- <b>Deprecated:</b> Returns the list of player or surrogate ids on board the construct.
--
-- This method is deprecated: construct.getPlayersOnBoard should be used instead.
-- @see construct.getPlayersOnBoard
-- @treturn list List of Players IDs.
function M:getPlayersOnBoard()
    M.deprecated("getPlayersOnBoard", "construct.getPlayersOnBoard")
end

--- <b>Deprecated:</b> Returns the list of player ids on board the construct inside a VR Station.
--
-- This method is deprecated: construct.getPlayersOnBoardInVRStation should be used instead.
-- @see construct.getPlayersOnBoardInVRStation
-- @treturn list List of Players IDs.
function M:getPlayersOnBoardInVRStation()
    M.deprecated("getPlayersOnBoardInVRStation", "construct.getPlayersOnBoardInVRStation")
end

--- <b>Deprecated:</b> Returns the list of ids of constructs docked to the construct.
--
-- This method is deprecated: construct.getDockedConstructs should be used instead.
-- @see construct.getDockedConstructs
-- @treturn list List of Construct IDs.
function M:getDockedConstructs()
    M.deprecated("getDockedConstructs", "construct.getDockedConstructs")
end

--- <b>Deprecated:</b> Returns True if the given player or surrogate is boarded to the construct.
--
-- This method is deprecated: construct.isPlayerBoarded should be used instead.
-- @see construct.isPlayerBoarded
-- @tparam int pid The player id.
-- @treturn 0/1 1 if the given player is boarded to the construct, 0 otherwise.
function M:isPlayerBoarded(pid)
    M.deprecated("isPlayerBoarded", "construct.isPlayerBoarded")
    return 0
end

--- <b>Deprecated:</b> Returns True if the given player is boarded to the construct inside a VR Station.
--
-- This method is deprecated: construct.isPlayerBoardedInVRStation should be used instead.
-- @see construct.isPlayerBoardedInVRStation
-- @tparam int pid The player id.
-- @treturn 0/1 1 if the given player is boarded to the construct, 0 otherwise.
function M:isPlayerBoardedInVRStation(pid)
    M.deprecated("isPlayerBoardedInVRStation", "construct.isPlayerBoardedInVRStation")
    return 0
end

--- <b>Deprecated:</b> Returns True if the given construct is docked to the construct.
--
-- This method is deprecated: construct.isConstructDocked should be used instead.
-- @see construct.isConstructDocked
-- @tparam int cid The construct id.
-- @treturn 0/1 1 if the given construct is docked to the construct, 0 otherwise.
function M:isConstructDocked(cid)
    M.deprecated("isConstructDocked", "construct.isConstructDocked")
    return 0
end

--- <b>Deprecated:</b> Sends a request to unboard a player or surrogate with the given id.
--
-- This method is deprecated: construct.forceDeboard should be used instead.
-- @see construct.forceDeboard
-- @tparam int pid The player id.
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:forceDeboard(pid)
    M.deprecated("forceDeboard", "construct.forceDeboard")
end

--- <b>Deprecated:</b> Sends a request to interrupt the surrogate session of a player with the given id.
--
-- This method is deprecated: construct.forceInterruptVRSession should be used instead.
-- @see construct.forceInterruptVRSession
-- @tparam int pid The player id.
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:forceInterruptVRSession(pid)
    M.deprecated("forceInterruptVRSession", "construct.forceInterruptVRSession")
end

--- <b>Deprecated:</b> Sends a request to undock a construct with the given id.
--
-- This method is deprecated: construct.forceUndock should be used instead.
-- @see construct.forceUndock
-- @tparam int cid The construct id.
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:forceUndock(cid)
    M.deprecated("forceUndock", "construct.forceUndock")
end

--- <b>Deprecated:</b> Returns the mass of the given player or surrogate if it is on board the construct.
--
-- This method is deprecated: construct.getBoardedPlayerMass should be used instead.
-- @see construct.getBoardedPlayerMass
-- @tparam int pid The player id.
-- @treturn float The mass of the player.
function M:getBoardedPlayerMass(pid)
    M.deprecated("getBoardedPlayerMass", "construct.getBoardedPlayerMass")
end

--- <b>Deprecated:</b> Returns the mass of the given player if in VR station on board the construct.
--
-- This method is deprecated: construct.getBoardedInVRStationAvatarMass should be used instead.
-- @see construct.getBoardedInVRStationAvatarMass
-- @tparam int pid The player id.
-- @treturn float The mass of the player.
function M:getBoardedInVRStationAvatarMass(pid)
    M.deprecated("getBoardedInVRStationAvatarMass", "construct.getBoardedInVRStationAvatarMass")
end

--- <b>Deprecated:</b> Returns the mass of the given construct if it is docked to the construct.
--
-- This method is deprecated: construct.getDockedConstructMass should be used instead.
-- @see construct.getDockedConstructMass
-- @tparam int cid The construct id.
-- @treturn The mass of the construct.
function M:getDockedConstructMass(cid)
    M.deprecated("getDockedConstructMass", "construct.getDockedConstructMass")
end

--- <b>Deprecated:</b> Returns the id of the parent construct of our active construct.
--
-- This method is deprecated: construct.getParent should be used instead.
-- @see construct.getParent
-- @treturn int The parent id.
function M:getParent()
    M.deprecated("getParent", "construct.getParent")
end

--- <b>Deprecated:</b> Returns the list of ids of nearby constructs, on which the construct can dock.
--
-- This method is deprecated: construct.getCloseParents should be used instead.
-- @see construct.getCloseParents
-- @treturn list List of ids of nearby constructs.
function M:getCloseParents()
    M.deprecated("getCloseParents", "construct.getCloseParents")
end

--- <b>Deprecated:</b> Returns the id of the nearest construct, on which the construct can dock.
--
-- This method is deprecated: construct.getClosestParent should be used instead.
-- @see construct.getClosestParent
-- @treturn int The id of the nearest construct.
function M:getClosestParent()
    M.deprecated("getClosestParent", "construct.getClosestParent")
end

--- <b>Deprecated:</b> Sends a request to dock to the given construct. Limited to piloting controllers.
--
-- This method is deprecated: construct.dock should be used instead.
-- @see construct.dock
-- @tparam int pid The parent id.
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:dock(pid)
    M.deprecated("dock", "construct.dock")
end

--- <b>Deprecated:</b> Sends a request to undock the construct. Limited to piloting controllers.
--
-- This method is deprecated: construct.undock should be used instead.
-- @see construct.undock
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:undock()
    M.deprecated("undock", "construct.undock")
end

--- <b>Deprecated:</b> Sets the docking mode.
--
-- This method is deprecated: construct.setDockingMode should be used instead.
-- @see construct.setDockingMode
-- @tparam int mode 0: Manual, 1: Automatic, 2: Semi-automatic
-- @treturn 0/1 1 if the operation is a success, 0 otherwise.
function M:setDockingMode(mode)
    M.deprecated("setDockingMode", "construct.setDockingMode")
end

--- <b>Deprecated:</b> Returns the current docking mode.
--
-- This method is deprecated: construct.getDockingMode should be used instead.
-- @see construct.getDockingMode
-- @treturn int 0: Manual, 1: Automatic, 2: Semi-automatic
function M:getDockingMode()
    M.deprecated("getDockingMode", "construct.getDockingMode")
end

--- <b>Deprecated:</b> Returns the position of the construct's parent when docked in local coordinates.
--
-- This method is deprecated: construct.getParentPosition should be used instead.
-- @see construct.getParentPosition
-- @treturn vec3 The position of the construct's parent in local coordinates.
function M:getParentPosition()
    M.deprecated("getParentPosition", "construct.getParentPosition")
end

--- <b>Deprecated:</b> Returns the position of the construct's parent when docked in world coordinates.
--
-- This method is deprecated: construct.getParentWorldPosition should be used instead.
-- @see construct.getParentWorldPosition
-- @treturn vec3 The position of the construct's parent in world coordinates.
function M:getParentWorldPosition()
    M.deprecated("getParentWorldPosition", "construct.getParentWorldPosition")
end

--- <b>Deprecated:</b> Returns the construct's parent forward direction vector, in local coordinates.
--
-- This method is deprecated: construct.getParentForward should be used instead.
-- @see construct.getParentForward
-- @treturn vec3 The construct's parent forward direction vector, in local coordinates.
function M:getParentForward()
    M.deprecated("getParentForward", "construct.getParentForward")
end

--- <b>Deprecated:</b> Returns the construct's parent up direction vector, in local coordinates.
--
-- This method is deprecated: construct.getParentUp should be used instead.
-- @see construct.getParentUp
-- @treturn vec3 The construct's parent up direction vector, in local coordinates.
function M:getParentUp()
    M.deprecated("getParentUp", "construct.getParentUp")
end

--- <b>Deprecated:</b> Returns the construct's parent right direction vector, in local coordinates.
--
-- This method is deprecated: construct.getParentRight should be used instead.
-- @see construct.getParentRight
-- @treturn vec3 The construct's parent right direction vector, in local coordinates.
function M:getParentRight()
    M.deprecated("getParentRight", "construct.getParentRight")
end

--- <b>Deprecated:</b> Returns the construct's parent forward direction vector, in world coordinates.
--
-- This method is deprecated: construct.getParentWorldForward should be used instead.
-- @see construct.getParentWorldForward
-- @treturn vec3 The construct's parent forward direction vector, in world coordinates.
function M:getParentWorldForward()
    M.deprecated("getParentWorldForward", "construct.getParentWorldForward")
end

--- <b>Deprecated:</b> Returns the construct's parent up direction vector, in world coordinates.
--
-- This method is deprecated: construct.getParentWorldUp should be used instead.
-- @see construct.getParentWorldUp
-- @treturn vec3 The construct's parent up direction vector, in world coordinates.
function M:getParentWorldUp()
    M.deprecated("getParentWorldUp", "construct.getParentWorldUp")
end

--- <b>Deprecated:</b> Returns the construct's parent right direction vector, in world coordinates.
--
-- This method is deprecated: construct.getParentWorldRight should be used instead.
-- @see construct.getParentWorldRight
-- @treturn vec3 The construct's parent right direction vector, in world coordinates.
function M:getParentWorldRight()
    M.deprecated("getParentWorldRight", "construct.getParentWorldRight")
end

--- <b>Deprecated:</b> Returns max speed along current moving direction.
--
-- This method is deprecated: construct.getMaxSpeed should be used instead.
-- @see construct.getMaxSpeed
-- @treturn float Max speed along current moving direction.
function M:getMaxSpeed()
    M.deprecated("getMaxSpeed", "construct.getMaxSpeed")
end

--- <b>Deprecated:</b> Returns max angular speed.
--
-- This method is deprecated: construct.getMaxAngularSpeed should be used instead.
-- @see construct.getMaxAngularSpeed
-- @treturn float Max angular speed.
function M:getMaxAngularSpeed()
    M.deprecated("getMaxAngularSpeed", "construct.getMaxAngularSpeed")
end

--- <b>Deprecated:</b> Returns max speed per axis.
--
-- This method is deprecated: construct.getMaxSpeedPerAxis should be used instead.
-- @see construct.getMaxSpeedPerAxis
-- @treturn table Max speed along axes {x, -x, y, -y, z, -z}.
function M:getMaxSpeedPerAxis()
    M.deprecated("getMaxSpeedPerAxis", "construct.getMaxSpeedPerAxis")
end

--- Event: Emitted when core unit stress changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam float stress Difference to previous stress value.
function M.EVENT_onStressChanged(stress)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the PvP timer started or elapsed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: construct.EVENT_onPvPTimer should be used instead.
-- @see construct.EVENT_onPvPTimer
-- @tparam boolean active True if the timer started.
function M.EVENT_pvpTimer(active)
    M.deprecated("EVENT_pvpTimer", "construct.EVENT_onPvPTimer")
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when a player boards the construct.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: construct.EVENT_onPlayerBoarded should be used instead.
-- @see construct.EVENT_onPlayerBoarded
-- @tparam int pid The id of the boarding player.
function M.EVENT_playerBoarded(pid)
    M.deprecated("EVENT_playerBoarded", "construct.EVENT_onPlayerBoarded")
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when another construct docks this construct.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: construct.EVENT_onConstructDocked should be used instead.
-- @see construct.EVENT_onConstructDocked
-- @tparam int cid The id of the docking construct.
function M.EVENT_constructDocked(cid)
    M.deprecated("EVENT_constructDocked", "construct.EVENT_onConstructDocked")
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the construct becomes docked.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: construct.EVENT_onDocked should be used instead.
-- @see construct.EVENT_onDocked
-- @tparam int cid The parent id.
function M.EVENT_docked(cid)
    M.deprecated("EVENT_docked", "construct.EVENT_onDocked")
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the construct is undocked.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: construct.EVENT_onUndocked should be used instead.
-- @see construct.EVENT_onUndocked
-- @tparam int cid The old parent id.
function M.EVENT_undocked(cid)
    M.deprecated("EVENT_undocked", "construct.EVENT_onUndocked")
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when core unit stress changed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onStressChanged should be used instead.
-- @see EVENT_onStressChanged
-- @tparam float stress Difference to previous stress value.
function M.EVENT_stressChanged(stress)
    M.deprecated("EVENT_stressChanged", "EVENT_onStressChanged")
    M.EVENT_onStressChanged(stress)
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getConstructName = function() return self:getConstructName() end
    if self.elementClass == CLASS_DYNAMIC then
        closure.getConstructMass = function() return self:getConstructMass() end
        closure.getConstructIMass = function() return self:getConstructIMass() end
        closure.getConstructCrossSection = function() return self:getConstructCrossSection() end
        closure.getMaxKinematicsParametersAlongAxis = function(taglist, CRefAxis)
            return self:getMaxKinematicsParametersAlongAxis(taglist, CRefAxis)
        end
    end
    closure.getConstructWorldPos = function() return self:getConstructWorldPos() end
    closure.getConstructId = function() return self:getConstructId() end
    closure.getWorldAirFrictionAngularAcceleration = function() return self:getWorldAirFrictionAngularAcceleration() end
    closure.getWorldAirFrictionAcceleration = function() return self:getWorldAirFrictionAcceleration() end
    closure.getElementIdList = function() return self:getElementIdList() end
    closure.getElementNameById = function(uid) return self:getElementNameById(uid) end
    closure.getElementDisplayNameById = function(localId) return self:getElementDisplayNameById(localId) end
    closure.getElementClassById = function(localId) return self:getElementClassById(localId) end
    closure.getElementTypeById = function(uid) return self:getElementTypeById(uid) end
    closure.getElementItemIdById = function(localId) return self:getElementItemIdById(localId) end
    closure.getElementHitPointsById = function(uid) return self:getElementHitPointsById(uid) end
    closure.getElementMaxHitPointsById = function(uid) return self:getElementMaxHitPointsById(uid) end
    closure.getElementMassById = function(uid) return self:getElementMassById(uid) end
    closure.getElementPositionById = function(uid) return self:getElementPositionById(uid) end
    closure.getElementUpById = function(uid) return self:getElementUpById(uid) end
    closure.getElementRightById = function(uid) return self:getElementRightById(uid) end
    closure.getElementForwardById = function(uid) return self:getElementForwardById(uid) end
    closure.getElementTagsById = function(uid) return self:getElementTagsById(uid) end
    closure.getElementIndustryStatusById = function(localId) return self:getElementIndustryStatusById(localId) end
    closure.getElementIndustryInfoById = function(localId) return self:getElementIndustryInfoById(localId) end
    closure.getAltitude = function() return self:getAltitude() end
    closure.g = function() return self:g() end
    closure.getGravityIntensity = function() return self:getGravityIntensity() end
    closure.getWorldGravity = function() return self:getWorldGravity() end
    closure.getWorldVertical = function() return self:getWorldVertical() end
    closure.getAngularVelocity = function() return self:getAngularVelocity() end
    closure.getWorldAngularVelocity = function() return self:getWorldAngularVelocity() end
    closure.getAngularAcceleration = function() return self:getAngularAcceleration() end
    closure.getWorldAngularAcceleration = function() return self:getWorldAngularAcceleration() end
    closure.getVelocity = function() return self:getVelocity() end
    closure.getWorldVelocity = function() return self:getWorldVelocity() end
    closure.getAbsoluteVelocity = function() return self:getAbsoluteVelocity() end
    closure.getWorldAbsoluteVelocity = function() return self:getWorldAbsoluteVelocity() end
    closure.getWorldAcceleration = function() return self:getWorldAcceleration() end
    closure.getAcceleration = function() return self:getAcceleration() end
    closure.getOrientationUnitId = function() return self:getOrientationUnitId() end
    closure.getConstructOrientationUp = function() return self:getConstructOrientationUp() end
    closure.getConstructOrientationRight = function() return self:getConstructOrientationRight() end
    closure.getConstructOrientationForward = function() return self:getConstructOrientationForward() end
    closure.getConstructWorldOrientationUp = function() return self:getConstructWorldOrientationUp() end
    closure.getConstructWorldOrientationRight = function() return self:getConstructWorldOrientationRight() end
    closure.getConstructWorldOrientationForward = function() return self:getConstructWorldOrientationForward() end
    closure.getConstructWorldUp = function() return self:getConstructWorldUp() end
    closure.getConstructWorldRight = function() return self:getConstructWorldRight() end
    closure.getConstructWorldForward = function() return self:getConstructWorldForward() end
    closure.getSchematicInfo = function(schematicId) return self:getSchematicInfo(schematicId) end
    closure.getPvPTimer = function() return self:getPvPTimer() end
    closure.getPlayersOnBoard = function() return self:getPlayersOnBoard() end
    closure.getPlayersOnBoardInVRStation = function() return self:getPlayersOnBoardInVRStation() end
    closure.getDockedConstructs = function() return self:getDockedConstructs() end
    closure.isPlayerBoarded = function(pid) return self:isPlayerBoarded(pid) end
    closure.isPlayerBoardedInVRStation = function(pid) return self:isPlayerBoardedInVRStation(pid) end
    closure.isConstructDocked = function(cid) return self:isConstructDocked(cid) end
    closure.forceDeboard = function(pid) return self:forceDeboard(pid) end
    closure.forceInterruptVRSession = function(pid) return self:forceInterruptVRSession(pid) end
    closure.forceUndock = function(cid) return self:forceUndock(cid) end
    closure.getBoardedPlayerMass = function(pid) return self:getBoardedPlayerMass(pid) end
    closure.getBoardedInVRStationAvatarMass = function(pid) return self:getBoardedInVRStationAvatarMass(pid) end
    closure.getDockedConstructMass = function(cid) return self:getDockedConstructMass(cid) end
    closure.getParent = function() return self:getParent() end
    closure.getCurrentPlanetId = function() return self:getCurrentPlanetId() end
    closure.getCloseParents = function() return self:getCloseParents() end
    closure.getClosestParent = function() return self:getClosestParent() end
    closure.dock = function(pid) return self:dock(pid) end
    closure.undock = function() return self:undock() end
    closure.setDockingMode = function(mode) return self:setDockingMode(mode) end
    closure.getDockingMode = function() return self:getDockingMode() end
    closure.getParentPosition = function() return self:getParentPosition() end
    closure.getParentWorldPosition = function() return self:getParentWorldPosition() end
    closure.getParentForward = function() return self:getParentForward() end
    closure.getParentUp = function() return self:getParentUp() end
    closure.getParentRight = function() return self:getParentRight() end
    closure.getParentWorldForward = function() return self:getParentWorldForward() end
    closure.getParentWorldUp = function() return self:getParentWorldUp() end
    closure.getParentWorldRight = function() return self:getParentWorldRight() end
    closure.getCoreStress = function() return self:getCoreStress() end
    closure.getMaxCoreStress = function() return self:getMaxCoreStress() end
    closure.getCoreStressRatio = function() return self:getCoreStressRatio() end
    closure.getMaxSpeed = function() return self:getMaxSpeed() end
    closure.getMaxAngularSpeed = function() return self:getMaxAngularSpeed() end
    closure.getMaxSpeedPerAxis = function() return self:getMaxSpeedPerAxis() end
    closure.spawnNumberSticker = function(nb, x, y, z, orientation)
        return self:spawnNumberSticker(nb, x, y, z, orientation)
    end
    closure.spawnArrowSticker = function(x, y, z, orientation) return self:spawnArrowSticker(x, y, z, orientation) end
    closure.deleteSticker = function(index) return self:deleteSticker(index) end
    closure.moveSticker = function(index, x, y, z) return self:moveSticker(index, x, y, z) end
    closure.rotateSticker = function(index, angle_x, angle_y, angle_z)
        return self:rotateSticker(index, angle_x, angle_y, angle_z)
    end
    return closure
end

return M