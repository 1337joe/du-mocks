--- Construct represents your construct. It gives access to the properties of your constructions and to the events
-- linked to them, which can be used in your scripts.
-- @module construct
-- @alias M

-- define class fields
local M = {}

function M:new(o)
    -- define default instance fields
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.name = ""
    o.id = 0
    o.owner = { id = 0, isOrganization = false }
    o.creator = { id = 0, isOrganization = false }

    o.pvpTimer = 0.0

    return o
end

--- Returns the name of the construct.
-- @treturn string The construct name.
function M:getName()
    return self.name
end

--- Returns the construct unique ID.
-- @treturn int The unique ID.
function M:getId()
    return self.id
end

--- Returns the owner entity.
-- @treturn table The owner entity table with fields {[int] id, [bool] isOrganization} describing the owner. Use
-- system.getPlayerName(id) and system.getOrganization(id) to retrieve info about it.
-- @see system.getPlayerName
-- @see system.getOrganization
function M:getOwner()
    return self.owner
end

--- Returns the creator entity.
-- @treturn table The creator entity table with fields {[int] id, [bool] isOrganization} describing the owner. Use
-- system.getPlayerName(id) and system.getOrganization(id) to retrieve info about it.
-- @see system.getPlayerName
-- @see system.getOrganization
function M:getCreator()
    return self.creator
end

--- Checks if the construct is currently warping.
-- @treturn 0/1 1 if the construct is currently warping.
function M:isWarping()
    return 0
end

--- Returns the current warp state.
-- @treturn int The current warp state index (Idle = 1, Engage = 2, Align = 3, Spool = 4, Accelerate = 5, Cruise = 6,
--   Decelerate = 7, Stopping = 8, Disengage = 9)
function M:getWarpState()
    return 1
end

--- Checks if the construct is in the PvP zone.
-- @treturn 0/1 1 if the construct is in the PVP zone.
function M:isInPvPZone()
end

--- Returns the distance between the construct and the nearest safe zone.
-- @treturn float The distance to the nearest safe zone border in meters. Positive value if the construct is outside of any safe zone.
function M:getDistanceToSafeZone()
end

--- Returns the current construct PvP timer state.
-- @treturn float The remaining time of the PvP timer, or 0.0 if elapsed.
function M:getPvPTimer()
    return self.pvpTimer
end

--- Returns the mass of the construct.
-- @treturn float The mass of the construct in kilograms.
function M:getMass()
end

--- Returns the inertial mass of the construct, calculated as 1/3 of the trace of the inertial tensor.
-- @treturn float The inertial mass of the construct in kilograms * meters square.
function M:getInertialMass()
end

--- Returns the inertial tensor of the construct.
-- @treturn mat The inertial tensor of the construct in kilograms * meters square.
function M:getInertialTensor()
end

--- Returns the position of the center of mass of the construct, in local construct coordinates.
-- @treturn vec3 The position of the center of mass of the construct in local construct coordinates.
function M:getCenterOfMass()
end

--- Returns the position of the center of mass of the construct, in world coordinates.
-- @treturn vec3 The position of the center of mass of the construct in world coordinates.
function M:getWorldCenterOfMass()
end

--- Returns the construct's cross sectional surface in the current direction of movement.
-- @treturn float The construct's surface exposed in the current direction of movement in meters square.
function M:getCrossSection()
end

--- Returns the size of the building zone of the construct.
-- @treturn vec3 The building zone size in meters.
function M:getSize()
end

--- Returns the size of the bounding box of the construct.
-- @treturn vec3 The bounding box size in meters.
function M:getBoundingBoxSize()
end

--- Returns the position of the center of the bounding box of the construct in local construct coordinates.
-- @treturn vec3 The dimensions of the position of the center of the bounding box of the construct in local construct
--   coordinates.
function M:getBoundingBoxCenter()
end

--- Returns the max speed along current moving direction.
-- @treturn float The max speed along current moving direction in m/s.
function M:getMaxSpeed()
end

--- Returns the max angular speed.
-- @treturn float The max angular speed in rad/s.
function M:getMaxAngularSpeed()
end

--- Returns the max speed per axis.
-- @treturn table The max speed along axes {x, -x, y, -y, z, -z} in m/s.
function M:getMaxSpeedPerAxis()
end

--- Returns the construct max kinematics parameters in both atmo and space range, in newtons. Kinematics parameters
-- designate here the maximal positive and negative base force the construct is capable of producing along the chosen
-- CRefAxis. In practice, this gives you an estimate of the maximum thrust your ship is capable of producing in space
-- or in atmosphere, as well as the max reverse thrust. These are theoretical estimates and correspond with the
-- addition of the max thrust along the corresponding axis. It might not reflect the accurate current max thrust
-- capacity of your ship, which depends on various local conditions (velocity, atmospheric density, orientation,
-- obstruction, engine damage, etc). This is typically used in conjunction with the control unit throttle to setup the
-- desired forward acceleration.
-- @tparam string taglist Comma (for union) or space (for intersection) separated list of tags. You can set tags directly
-- on the engines in the right-click menu.
-- @tparam vec3 CRefAxis Axis along which to compute the max force in construct local coordinates.
-- @treturn vec4,Newton The kinematics parameters in newtons in the order: atmoRange.FMaxPlus, atmoRange.FMaxMinus,
-- spaceRange.FMaxPlus, spaceRange.FMaxMinus
function M:getMaxThrustAlongAxis(taglist, CRefAxis)
end

--- Returns the current braking force genrated by construct brakes.
-- @treturn float The current braking force in newtons.
function M:getCurrentBrake()
end

--- Returns the maximum brake force that can currently be generated by the construct brakes.
-- @treturn float The maximum braking force in newtons.
function M:getMaxBrake()
end

--- Returns the world position of the construct.
-- @treturn vec3 The xyz world coordinates of the construct center position in meters.
function M:getWorldPosition()
end

--- The construct's linear velocity, relative to its parent, in construct local coordinates.
-- @treturn vec3 Relative linear velocity vector, in construct local coordinates in m/s.
function M:getVelocity()
end

--- The construct's linear velocity, relative to its parent, in world coordinates.
-- @treturn vec3 Relative linear velocity vector, in world coordinates in m/s.
function M:getWorldVelocity()
end

--- The construct's absolute linear velocity, in construct local coordinates.
-- @treturn vec3 Absolute linear velocity vector, in construct local coordinates in m/s.
function M:getAbsoluteVelocity()
end

--- The construct's absolute linear velocity, in world coordinates.
-- @treturn vec3 Absolute linear velocity vector, in world coordinates in m/s.
function M:getWorldAbsoluteVelocity()
end

--- The construct's linear acceleration, in construct local coordinates.
-- @treturn vec3 Linear acceleration vector, in construct local coordinates in m/s2.
function M:getAcceleration()
    return self.acceleration
end

--- The construct's linear acceleration, in world coordinates.
-- @treturn vec3 Linear acceleration vector, in world coordinates in m/s2.
function M:getWorldAcceleration()
    return self.worldAcceleration
end

--- The construct's angular velocity, in construct local coordinates.
-- @treturn vec3 Angular velocity vector, in construct local coordinates in rad/s.
function M:getAngularVelocity()
end

--- The constructs angular velocity, in world coordinates.
-- @treturn vec3 Angular velocity vector, in world coordinates in rad/s.
function M:getWorldAngularVelocity()
end

--- The construct's angular acceleration, in construct local coordinates.
-- @treturn vec3 Angular acceleration vector, in construct local coordinates in rad/s2.
function M:getAngularAcceleration()
end

--- The construct's angular acceleration, in world coordinates.
-- @treturn vec3 Angular acceleration vector, in world coordinates in rad/s2.
function M:getWorldAngularAcceleration()
end

--- Returns the acceleration generated by air resistance.
-- @treturn vec3 The xyz world acceleration generated by air resistance.
function M:getWorldAirFrictionAcceleration()
end

--- Returns the acceleration torque generated by air resistance.
-- @treturn vec3 The xyz world acceleration torque generated by air resistance.
function M:getWorldAirFrictionAngularAcceleration()
end

--- Returns the speed at which your construct will suffer damage due to friction with the air.
-- @treturn float The construct speed to get damages due to friction in m/s.
function M:getFrictionBurnSpeed()
end

--- Returns the forward vector of the construct coordinates system.
-- @treturn vec3 The forward vector of the construct coordinates system. It's a static value equal to (0, 1, 0).
function M:getForward()
    return {0, 1, 0}
end

--- Returns the right vector of the construct coordinates system.
-- @treturn vec3 The right vector of the construct coordinates system. It's a static value equal to (1, 0, 0).
function M:getRight()
    return {1, 0, 0}
end

--- Returns the up vector of the construct coordinates system.
-- @treturn vec3 The up vector of the construct coordinates system. It's a static value equal to (0, 0, 1).
function M:getUp()
    return {0, 0, 1}
end

--- Returns the forward direction of the construct, in world coordinates.
-- @treturn vec3 The forward direction vector of the construct, in world coordinates.
function M:getWorldForward()
end

--- Returns the right direction of the construct, in world coordinates.
-- @treturn vec3 The right direction vector of the construct, in world coordinates.
function M:getWorldRight()
end

--- Returns the up direction of the construct, in world coordinates.
-- @treturn vec3 The up direction vector of the construct, in world coordinates.
function M:getWorldUp()
end

--- Returns the local ID of the current active orientation unit (core unit or gyro unit).
-- @treturn int The local ID of the current active orientation unit (core unit or gyro unit).
function M:getOrientationUnitId()
end

--- Returns the forward direction vector of the active orientation unit, in construct local coordinates.
-- @treturn vec3 Forward direction vector of the active orientation unit, in construct local coordinates.
function M:getOrientationForward()
end

--- Returns the right direction vector of the active orientation unit, in construct local coordinates.
-- @treturn vec3 Right direction vector of the active orientation unit, in construct local coordinates.
function M:getOrientationRight()
end

--- Returns the up direction vector of the active orientation unit, in construct local coordinates.
-- @treturn vec3 Up direction vector of the active orientation unit, in construct local coordinates.
function M:getOrientationUp()
end

--- Returns the forward direction vector of the active orientation unit, in world coordinates.
-- @treturn vec3 Forward direction vector of the active orientation unit, in world coordinates.
function M:getWorldOrientationForward()
end

--- Returns the right direction vector of the active orientation unit, in world coordinates.
-- @treturn vec3 Right direction vector of the active orientation unit, in world coordinates.
function M:getWorldOrientationRight()
end

--- Returns the up direction vector of the active orientation unit, in world coordinates.
-- @treturn vec3 Up direction vector of the active orientation unit, in world coordinates.
function M:getWorldOrientationUp()
end

--- Returns the ID of the parent construct of our active construct.
-- @treturn int The parent ID.
function M:getParent()
end

--- Returns the ID of the nearest construct on which the construct can dock.
-- @treturn int The ID of the nearest construct.
function M:getClosestParent()
end

--- Returns the list of IDs of nearby constructs, on which the construct can dock.
-- @treturn list List of IDs of nearby constructs.
function M:getCloseParents()
end

--- Returns the position of the construct's parent when docked in local coordinates.
-- @treturn vec3 The position of the constructs parent in local coordinates.
function M:getParentPosition()
end

--- Returns the position of the construct's parent when docked in world coordinates.
-- @treturn vec3 The position of the constructs parent in world coordinates.
function M:getParentWorldPosition()
end

--- Returns the construct's parent forward direction vector, in construct local coordinates.
-- @treturn vec3 The construct's parent forward direction vector, in construct local coordinates.
function M:getParentForward()
end

--- Returns the construct's parent right direction vector, in construct local coordinates.
-- @treturn vec3 The construct's parent right direction vector, in construct local coordinates.
function M:getParentRight()
end

--- Returns the construct's parent up direction vector, in construct local coordinates.
-- @treturn vec3 The construct's parent up direction vector, in construct local coordinates.
function M:getParentUp()
end

--- Returns the construct's parent forward direction vector, in world coordinates.
-- @treturn vec3 The construct's parent forward direction vector, in world coordinates.
function M:getParentWorldForward()
end

--- Returns the construct's parent right direction vector, in world coordinates.
-- @treturn vec3 The construct's parent right direction vector, in world coordinates.
function M:getParentWorldRight()
end

--- Returns the construct's parent up direction vector, in world coordinates.
-- @treturn vec3 The construct's parent up direction vector, in world coordinates.
function M:getParentWorldUp()
end

--- Returns the list of player IDs on board the construct.
-- @treturn list The list of player IDs on board.
function M:getPlayersOnBoard()
end

--- Returns the list of player IDs on board the construct inside a VR station.
-- @treturn list The list of player IDs.
function M:getPlayersOnBoardInVRStation()
end

--- Checks if the given player is on board in the construct.
-- @tparam int id The player ID.
-- @treturn 0/1 1 if the given player is on board.
function M:isPlayerBoarded(id)
end

--- Returns 1 if the given player is boarded to the construct inside a VR station.
-- @tparam int id The player ID.
-- @treturn 0/1 1 if the given player is boarded to the construct.
function M:isPlayerBoardedInVRStation(id)
end

--- Returns the mass of the given player or surrogate if it is on board the construct.
-- @tparam int id The player ID.
-- @treturn float The mass of the player.
function M:getBoardedPlayerMass(id)
end

--- Returns the mass of the given player if in VR station on board the construct.
-- @tparam int id The player ID.
-- @treturn float The mass of the player.
function M:getBoardedInVRStationAvatarMass(id)
end

--- Returns the list of IDs of constructs docked to the construct.
-- @treturn list The list of IDs of docked constructs.
function M:getDockedConstructs()
end

--- Checks if the given construct is docked to the construct.
-- @tparam int id The construct ID.
-- @treturn 0/1 1 if the given construct is docked.
function M:isConstructDocked(id)
end

--- Returns the mass of the given construct if it is docked to the construct.
-- @tparam int id The construct ID.
-- @treturn float The mass of the construct.
function M:getDockedConstructMass(id)
end

--- Sets the docking mode.
-- @tparam int mode The docking mode (Manual = 1, Automatic = 2, Semi-automatic = 3).
-- @treturn 0/1 1 if the operation is a success.
function M:setDockingMode(mode)
end

--- Returns the current docking mode.
-- @treturn int The docking mode (Manual = 1, Automatic = 2, Semi-automatic = 3).
function M:getDockingMode()
end

--- Sends a request to dock to the given construct. Limited to piloting controllers.
-- @tparam int id The parent construct ID.
-- @treturn 0/1 1 if the operation is a success.
function M:dock(id)
end

--- Sends a request to undock the construct. Limited to piloting controllers.
-- @treturn 0/1 1 if the operation is a success.
function M:undock()
end

--- Sends a request to deboard a player or surrogate with the given ID.
-- @tparam int id The player ID.
-- @treturn 0/1 1 if the operation is a success.
function M:forceDeboard(id)
end

--- Sends a request to undock a construct with the given ID.
-- @tparam int id The construct ID.
-- @treturn 0/1 1 if the operation is a success.
function M:forceUndock(id)
end

--- Sends a request to interrupt the surrogate session of a player with the given ID.
-- @tparam int id The player ID.
-- @treturn 0/1 1 if the operation is a success.
function M:forceInterruptVRSession(id)
end

--- Unknown use.
function M:load()
end

--- Event: Emitted when the construct becomes docked.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The parent ID.
function M.EVENT_onDocked(id)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the construct is undocked.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The previous parent ID.
function M.EVENT_onUndocked(id)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when a player or surrogate boards the construct.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the boarding player.
function M.EVENT_onPlayerBoarded(id)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when a player enters a VR station.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the VR player.
function M.EVENT_onVRStationEntered(id)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when another construct docks to this construct.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The ID of the docking construct.
function M.EVENT_onConstructDocked(id)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the PvP timer started or elapsed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam 0/1 active 1 if the timer started, 0 when the timer elapsed.
function M.EVENT_onPvPTimer(active)
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.getName = function() return self:getName() end
    closure.getId = function() return self:getId() end
    closure.getOwner = function() return self:getOwner() end
    closure.getCreator = function() return self:getCreator() end
    closure.isWarping = function() return self:isWarping() end
    closure.getWarpState = function() return self:getWarpState() end
    closure.isInPvPZone = function() return self:isInPvPZone() end
    closure.getDistanceToSafeZone = function() return self:getDistanceToSafeZone() end
    closure.getPvPTimer = function() return self:getPvPTimer() end
    closure.getMass = function() return self:getMass() end
    closure.getInertialMass = function() return self:getInertialMass() end
    closure.getInertialTensor = function() return self:getInertialTensor() end
    closure.getCenterOfMass = function() return self:getCenterOfMass() end
    closure.getWorldCenterOfMass = function() return self:getWorldCenterOfMass() end
    closure.getCrossSection = function() return self:getCrossSection() end
    closure.getSize = function() return self:getSize() end
    closure.getBoundingBoxSize = function() return self:getBoundingBoxSize() end
    closure.getBoundingBoxCenter = function() return self:getBoundingBoxCenter() end
    closure.getMaxSpeed = function() return self:getMaxSpeed() end
    closure.getMaxAngularSpeed = function() return self:getMaxAngularSpeed() end
    closure.getMaxSpeedPerAxis = function() return self:getMaxSpeedPerAxis() end
    closure.getMaxThrustAlongAxis = function() return self:getMaxThrustAlongAxis() end
    closure.getCurrentBrake = function() return self:getCurrentBrake() end
    closure.getMaxBrake = function() return self:getMaxBrake() end
    closure.getWorldPosition = function() return self:getWorldPosition() end
    closure.getVelocity = function() return self:getVelocity() end
    closure.getWorldVelocity = function() return self:getWorldVelocity() end
    closure.getAbsoluteVelocity = function() return self:getAbsoluteVelocity() end
    closure.getWorldAbsoluteVelocity = function() return self:getWorldAbsoluteVelocity() end
    closure.getAcceleration = function() return self:getAcceleration() end
    closure.getWorldAcceleration = function() return self:getWorldAcceleration() end
    closure.getAngularVelocity = function() return self:getAngularVelocity() end
    closure.getWorldAngularVelocity = function() return self:getWorldAngularVelocity() end
    closure.getAngularAcceleration = function() return self:getAngularAcceleration() end
    closure.getWorldAngularAcceleration = function() return self:getWorldAngularAcceleration() end
    closure.getWorldAirFrictionAcceleration = function() return self:getWorldAirFrictionAcceleration() end
    closure.getWorldAirFrictionAngularAcceleration = function() return self:getWorldAirFrictionAngularAcceleration() end
    closure.getFrictionBurnSpeed = function() return self:getFrictionBurnSpeed() end
    closure.getForward = function() return self:getForward() end
    closure.getRight = function() return self:getRight() end
    closure.getUp = function() return self:getUp() end
    closure.getWorldForward = function() return self:getWorldForward() end
    closure.getWorldRight = function() return self:getWorldRight() end
    closure.getWorldUp = function() return self:getWorldUp() end
    closure.getOrientationUnitId = function() return self:getOrientationUnitId() end
    closure.getOrientationForward = function() return self:getOrientationForward() end
    closure.getOrientationRight = function() return self:getOrientationRight() end
    closure.getOrientationUp = function() return self:getOrientationUp() end
    closure.getWorldOrientationForward = function() return self:getWorldOrientationForward() end
    closure.getWorldOrientationRight = function() return self:getWorldOrientationRight() end
    closure.getWorldOrientationUp = function() return self:getWorldOrientationUp() end
    closure.getParent = function() return self:getParent() end
    closure.getClosestParent = function() return self:getClosestParent() end
    closure.getCloseParents = function() return self:getCloseParents() end
    closure.getParentPosition = function() return self:getParentPosition() end
    closure.getParentWorldPosition = function() return self:getParentWorldPosition() end
    closure.getParentForward = function() return self:getParentForward() end
    closure.getParentRight = function() return self:getParentRight() end
    closure.getParentUp = function() return self:getParentUp() end
    closure.getParentWorldForward = function() return self:getParentWorldForward() end
    closure.getParentWorldRight = function() return self:getParentWorldRight() end
    closure.getParentWorldUp = function() return self:getParentWorldUp() end
    closure.getPlayersOnBoard = function() return self:getPlayersOnBoard() end
    closure.getPlayersOnBoardInVRStation = function() return self:getPlayersOnBoardInVRStation() end
    closure.isPlayerBoarded = function(id) return self:isPlayerBoarded(id) end
    closure.isPlayerBoardedInVRStation = function(id) return self:isPlayerBoardedInVRStation(id) end
    closure.getBoardedPlayerMass = function(id) return self:getBoardedPlayerMass(id) end
    closure.getBoardedInVRStationAvatarMass = function(id) return self:getBoardedInVRStationAvatarMass(id) end
    closure.getDockedConstructs = function() return self:getDockedConstructs() end
    closure.isConstructDocked = function(id) return self:isConstructDocked(id) end
    closure.getDockedConstructMass = function(id) return self:getDockedConstructMass(id) end
    closure.setDockingMode = function(mode) return self:setDockingMode(mode) end
    closure.getDockingMode = function() return self:getDockingMode() end
    closure.dock = function(id) return self:dock(id) end
    closure.undock = function() return self:undock() end
    closure.forceDeboard = function(id) return self:forceDeboard(id) end
    closure.forceUndock = function(id) return self:forceUndock(id) end
    closure.forceInterruptVRSession = function(id) return self:forceInterruptVRSession(id) end
    closure.load = function() return self:load() end
    return closure
end

return M
