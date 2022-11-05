--- This class represents the player who is executing the control unit.
-- @module player
-- @alias M

-- define class fields
local M = {}

function M:new(o)
    -- define default instance fields
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.name = ""
    o.id = 1
    o.nanopackVolume = 0
    o.nanopackMaxVolume = 4000

    o.seated = false
    o.sprinting = false
    o.jetpackOn = false
    o.headlightOn = false
    o.frozen = false

    return o
end

--- Returns the player name.
-- @treturn string The player name.
function M:getName()
    return self.name
end

--- Returns the ID of the player.
-- @treturn int The ID of the player.
function M:getId()
    return self.id
end

--- Returns the player mass.
-- @treturn float The mass of the player .
function M:getMass()
    return 90.0
end

--- Returns the player's nanopack content mass.
-- @treturn float The player's nanopack content mass in kilograms.
function M:getNanopackMass()
end

--- Returns the player's nanopack content volume.
-- @treturn float THe player's nanopack content volume in liters.
function M:getNanopackVolume()
    return self.nanopackVolume
end

--- Returns the player's nanopack maximum volume.
-- @treturn float The player's nanopack maximum volume in liters.
function M:getNanopackMaxVolume()
    return self.nanopackMaxVolume
end

--- Returns the list of organization IDs of the player.
-- @treturn list The list of organization IDs.
function M:getOrgIds()
end

--- Returns the position of the player, in construct local coordinates.
-- @treturn vec3 The position in construct local coordinates.
function M:getPosition()
end

--- Returns the position of the player, in world coordinates.
-- @treturn vec3 The position in world coordinates.
function M:getWorldPosition()
end

--- Returns the position of the head of the player's character, in construct local coordinates.
-- @treturn vec3 The position of the head in construct local coordinates.
function M:getHeadPosition()
end

--- Returns the position of the head of the player's character, in world coordinates.
-- @treturn vec3 The position of the head in world coordinates.
function M:getWorldHeadPosition()
end

--- Returns the velocity vector of the player, in construct local coordinates.
-- @treturn vec3 The velocity vector in construct local coordinates.
function M:getVelocity()
end

--- Returns the velocity vector of the player, in world coordinates.
-- @treturn vec3 The velocity vector in world coordinates.
function M:getWorldVelocity()
end

--- Returns the absolute velocity vector of the player, in world coordinates.
-- @treturn vec3 The velocity absolute vector in world coordinates.
function M:getAbsoluteVelocity()
end

--- Returns the forward direction vector of the player, in construct local coordinates.
-- @treturn vec3 The forward direction vector in construct local coordinates.
function M:getForward()
end

--- Returns the right direction vector of the player, in construct local coordinates.
-- @treturn vec3 The right direction vector in construct local coordinates.
function M:getRight()
end

--- Returns the up direction vector of the player, in construct local coordinates.
-- @treturn vec3 The up direction vector in construct local coordinates.
function M:getUp()
end

--- Returns the forward direction vector of the player, in world coordinates.
-- @treturn vec3 The forward direction vector in world coordinates.
function M:getWorldForward()
end

--- Returns the right direction vector of the player, in world coordinates.
-- @treturn vec3 The right direction vector in world coordinates.
function M:getWorldRight()
end

--- Returns the up direction vector of the player, in world coordinates.
-- @treturn vec3 The up direction vector in world coordinates.
function M:getWorldUp()
end

--- Returns the id of the planet the player is located on.
-- @treturn int The ID of the planet, 0 if none.
function M:getPlanet()
end

--- Returns the identifier of the construct to which the player is parented.
-- @treturn The ID of the construct, 0 if none.
function M:getParent()
end

--- Checks if the player is seated.
-- @treturn 0/1 1 if the player is seated.
function M:isSeated()
    if self.seated then
        return 1
    end
    return 0
end

--- Returns the local ID of the seat on which the player is sitting.
-- @treturn The local ID of the seat, or 0 if not seated.
function M:getSeatId()
    return 0
end

--- Checks if the player is parented to the given construct.
-- @tparam int id The construct ID.
-- @treturn 0/1 1 if the player is parented to the given construct.
function M:isParentedTo(id)
    return 0
end

--- Checks if the player is currently sprinting.
-- @treturn 0/1 1 if the player is sprinting.
function M:isSprinting()
    if self.sprinting then
        return 1
    end
    return 0
end

--- Checks if the player's jetpack is on.
-- @treturn 0/1 1 if the player's jetpack is on.
function M:isJetpackOn()
    if self.jetpackOn then
        return 1
    end
    return 0
end

--- Returns the state of the headlight of the player.
-- @treturn 0/1 1 if the player has his headlight on.
function M:isHeadlightOn()
    if self.headlightOn then
        return 1
    end
    return 0
end

--- Set the state of the headlight of the player.
-- @tparam bool state True to turn on the headlight.
function M:setHeadlightOn(state)
    -- accepts 1 or true, as well as anything parseable as a whole number besides 0
    local numberState = tonumber(state)
    self.headlightOn = (state == true) or (numberState and numberState ~= 0 and numberState % 1 == 0) or false
end

--- Freezes the player movements, liberating the associated movement keys to be used by the script.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit, vs. via a plug signal).
-- @tparam bool state 1 to freeze the character, 0 to unfreeze the character.
function M:freeze(state)
    -- accepts 1 or true, as well as anything parseable as a whole number besides 0
    local numberState = tonumber(state)
    self.frozen = (state == true) or (numberState and numberState ~= 0 and numberState % 1 == 0) or false
end

--- Checks if the player movements are frozen.
-- @tparam 0/1 1 if the player is frozen, 0 otherwise.
function M:isFrozen()
    if self.frozen then
        return 1
    end
    return 0
end

--- Checks if the player has DRM authorization to the control unit.
-- @treturn 0/1 1 if the player has DRM authorization on the control unit.
function M:hasDRMAutorization()
    return 1
end

--- Unknown use.
function M:load()
end

--- Event: Emitted when the player parent changes.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int oldId The previous parent construct ID.
-- @tparam int newId The new parent construct ID.
function M.EVENT_onParentChanged(oldId, newId)
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.getName = function() return self:getName() end
    closure.getId = function() return self:getId() end
    closure.getMass = function() return self:getMass() end
    closure.getNanopackMass = function() return self:getNanopackMass() end
    closure.getNanopackVolume = function() return self:getNanopackVolume() end
    closure.getNanopackMaxVolume = function() return self:getNanopackMaxVolume() end
    closure.getOrgIds = function() return self:getOrgIds() end
    closure.getPosition = function() return self:getPosition() end
    closure.getWorldPosition = function() return self:getWorldPosition() end
    closure.getHeadPosition = function() return self:getHeadPosition() end
    closure.getWorldHeadPosition = function() return self:getWorldHeadPosition() end
    closure.getVelocity = function() return self:getVelocity() end
    closure.getWorldVelocity = function() return self:getWorldVelocity() end
    closure.getAbsoluteVelocity = function() return self:getAbsoluteVelocity() end
    closure.getForward = function() return self:getForward() end
    closure.getRight = function() return self:getRight() end
    closure.getUp = function() return self:getUp() end
    closure.getWorldForward = function() return self:getWorldForward() end
    closure.getWorldRight = function() return self:getWorldRight() end
    closure.getWorldUp = function() return self:getWorldUp() end
    closure.getPlanet = function() return self:getPlanet() end
    closure.getParent = function() return self:getParent() end
    closure.isSeated = function() return self:isSeated() end
    closure.getSeatId = function() return self:getSeatId() end
    closure.isParentedTo = function(id) return self:isParentedTo(id) end
    closure.isSprinting = function() return self:isSprinting() end
    closure.isJetpackOn = function() return self:isJetpackOn() end
    closure.isHeadlightOn = function() return self:isHeadlightOn() end
    closure.setHeadlightOn = function(state) return self:setHeadlightOn(state) end
    closure.freeze = function(state) return self:freeze(state) end
    closure.isFrozen = function() return self:isFrozen() end
    closure.hasDRMAutorization = function() return self:hasDRMAutorization() end
    closure.load = function() return self:load() end
    return closure
end

return M
