--- Generates a protective shield around the space construct.
--
-- <p style="color:red;">Note: This is generated from patch notes and in-game codex and has not yet been tested
--   against the actual element. Accuracy not guaranteed.</p>
--
-- Element class: BaseShieldGeneratorUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module BaseShieldGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["base shield generator xl"] = {mass = 138000.0, maxHitPoints = 47250.0, itemId = 1430252067, maxShieldHitpoints = 450000.0, ventingMaxCooldown = 60.0}
local DEFAULT_ELEMENT = "base shield generator xl"

local M = MockElement:new()
M.elementClass = "BaseShieldGeneratorUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.shieldHitpoints = elementDefinition.maxShieldHitpoints
    o.maxShieldHitpoints = elementDefinition.maxShieldHitpoints

    o.plugIn = 0.0

    o.absorbedCallbacks = {}
    o.downCallbacks = {}
    o.restoredCallbacks = {}

    return o
end

--- Activate the shield.
function M:activate()
    self.state = true
end

--- Deactivate the shield.
function M:deactivate()
    self.state = false
end

--- Returns the activation state of the shield.
-- @treturn 0/1 1 when the shield is active, 0 otherwise.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

--- Returns the current hit points of the shield.
-- @treturn float The current hit points of the shield.
function M:getShieldHitpoints()
    return self.shieldHitpoints
end

--- Returns the maximal hit points of the shield.
-- @treturn float The maximal hit points of the shield.
function M:getMaxShieldHitpoints()
    return self.maxShieldHitpoints
end

--- Returns distribution of resistance pool over resistance types.
-- @treturn table Resistance to damage type {antimatter, electromagnetic, kinetic, thermic}.
function M:getResistances()
end

--- Distribute the resistance pool according to damage type.
-- @tparam float antimatter Antimatter damage resistance.
-- @tparam float electromagnetic Electromagnetic damage resistance.
-- @tparam float kinetic Kinetic damage resistance.
-- @tparam float thermic Thermic damage resistance.
-- @treturn 0/1 1 if resistance was distributed, 0 if an error occurred.
function M:setResistances(antimatter, electromagnetic, kinetic, thermic)
end

--- Returns time after which adjusting resistances is possible again.
-- @treturn float Remaining seconds of the resistance cooldown.
function M:getResistancesCooldown()
end

--- Returns maximal cooldown between adjusting resistances.
-- @treturn float Maximal seconds of the resistance cooldown.
function M:getResistancesMaxCooldown()
end

--- Returns total resistance pool that may be distributed.
-- @treturn float Total pool of resistances.
function M:getResistancesPool()
end

--- Returns the remaining amount of the resistance pool that can be distributed.
-- @treturn float Remaining resistance pool.
function M:getResistancesRemaining()
end

--- Returns ratio per damage type of recent weapon impacts after applying resistances.
-- @treturn table Stress ratio due to damage type {antimatter, electromagnetic, kinetic, thermic}.
function M:getStressRatio()
end

--- Returns ratio per damage type of recent weapon impacts without resistance.
-- @treturn table Stress ratio due to damage type {antimatter, electromagnetic, kinetic, thermic}.
function M:getStressRatioRaw()
end

--- Returns stress, that is the total hit points of recent weapon impacts after applying resistances.
-- @treturn float Total stress hit points due to recent weapon impacts.
function M:getStressHitpoints()
end

--- Returns stress, that is the total hit points of recent weapon impacts without resistances.
-- @treturn float Total stress hit points due to recent weapon impacts.
function M:getStressHitpointsRaw()
end

--- Returns whether the base shield is currently in lockdown.
-- @treturn 0/1 Whether the base shield is in lockdown.
function M:inLockdown()
end

--- Returns the remaining time of the base shield lockdown.
-- @treturn float Remaining lockdown time in seconds.
function M:getLockdownRemaining()
end

--- Returns the hour since midnight of the preferred lockdown exit.
-- @treturn 0-23 Preferred lockdown exit hour UTC.
function M:getLockdownExitTime()
end

--- Set hour since midnight for preferred lockdown exit.
-- @tparam 0-23 hour Preferred lockdown exit hour UTC.
-- @treturn 0/1 1 if lockdown exit was set, 0 if an error occurred.
function M:setLockdownExitTime(hour)
end

--- Event: Emitted when we started or stopped the shield generator.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam 0/1 active 1 if the element was activated, 0 otherwise.
function M.EVENT_onToggled(active)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the shield absorbed incoming damage.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onAbsorbed should be used instead.
-- @see EVENT_onAbsorbed
-- @tparam float hitpoints Hit points the shield lost.
-- @tparam float rawHitpoints Total damage without taking resistances into account.
function M.EVENT_absorbed(hitpoints, rawHitpoints)
    M.deprecated("EVENT_absorbed", "EVENT_onAbsorbed")
    M.EVENT_onAbsorbed(hitpoints, rawHitpoints)
end

--- Event: Emitted when the shield absorbed incoming damage.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam float hitpoints Hit points the shield lost.
-- @tparam float rawHitpoints Total damage without taking resistances into account.
function M.EVENT_onAbsorbed(hitpoints, rawHitpoints)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the shield hit points reached 0 due to damages.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onDown should be used instead.
-- @see EVENT_onDown
function M.EVENT_down()
    M.deprecated("EVENT_down", "EVENT_onDown")
    M.EVENT_onDown()
end

--- Event: Emitted when the shield hit points reached 0 due to damages.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onDown()
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the shield hit points were fully restored.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onRestored should be used instead.
-- @see EVENT_onRestored
function M.EVENT_restored()
    M.deprecated("EVENT_restored", "EVENT_onRestored")
    M.EVENT_onRestored()
end

--- Event: Emitted when the shield hit points were fully restored.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onRestored()
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the shield enters lockdown.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onEnterLockdown should be used instead.
-- @see EVENT_onEnterLockdown
function M.EVENT_enterLockdown()
    M.deprecated("EVENT_enterLockdown", "EVENT_onEnterLockdown")
    M.EVENT_onEnterLockdown()
end

--- Event: Emitted when the shield enters lockdown.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onEnterLockdown()
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the shield exits the lockdown.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onLeaveLockdown should be used instead.
-- @see EVENT_onLeaveLockdown
function M.EVENT_leaveLockdown()
    M.deprecated("EVENT_leaveLockdown", "EVENT_onLeaveLockdown")
    M.EVENT_onLeaveLockdown()
end

--- Event: Emitted when the shield exits the lockdown.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onLeaveLockdown()
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Register a handler for the in-game `absorbed(hitpoints, rawHitpoints)` event.
-- @tparam function callback The function to call when the shield absorbs damage.
-- @tparam string hitpoints The hit points to filter for or "*" for all.
-- @tparam string rawHitpoints The raw hit points to filter for or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_absorbed
function M:mockRegisterAbsorbed(callback, hitpoints, rawHitpoints)
    local index = #self.absorbedCallbacks + 1
    self.absorbedCallbacks[index] = {
        callback = callback,
        hitpoints = hitpoints,
        rawHitpoints = rawHitpoints
    }
    return index
end

--- Mock only, not in-game: Simulates the shield absorbing damage.
--
-- Note: The state updates to true before the event handlers are called.
-- @tparam int hitpoints The amount of damage to deal.
-- @tparam int rawHitpoints The amount of damage to deal before taking resistances into account.
function M:mockDoAbsorbed(hitpoints, rawHitpoints)
    -- bail if deactivated
    if not self.state then
        return
    end

    -- TODO does the shield go down before calling absorbed or not?
    self.shieldHitpoints = math.max(0, self.shieldHitpoints - hitpoints)
    if self.shieldHitpoints == 0 then
        self.state = false
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.absorbedCallbacks) do
        -- filter on the absorbed hitpoints/raw hitpoints
        if (callback.hitpoints == "*" or callback.hitpoints == hitpoints) and
                (callback.rawHitpoints == "*" or callback.rawHitpoints == rawHitpoints) then
            local status, err = pcall(callback.callback, hitpoints, rawHitpoints)
            if not status then
                errors = errors .. "\nError while running callback " .. i .. ": " .. err
            end
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:" .. errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `down()` event.
-- @tparam function callback The function to call when the shield goes down.
-- @treturn int The index of the callback.
-- @see EVENT_down
function M:mockRegisterDown(callback)
    local index = #self.downCallbacks + 1
    self.downCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the shield going down, either from damage or deactivation.
--
-- Note: The state updates to false before the event handlers are called.
function M:mockDoDown()
    -- bail if already deactivated
    if not self.state then
        return
    end

    -- state changes before calling handlers
    self.state = false

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.downCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors .. "\nError while running callback " .. i .. ": " .. err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:" .. errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `restored()` event.
-- @tparam function callback The function to call when the shield comes up.
-- @treturn int The index of the callback.
-- @see EVENT_restored
function M:mockRegisterRestored(callback)
    local index = #self.restoredCallbacks + 1
    self.restoredCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the shield becoming active.
--
-- Note: The state updates to true before the event handlers are called.
function M:mockDoRestored()
    -- bail if already activated
    if self.state then
        return
    end

    -- TODO does this only fire when shield is restored to max or also when shield is turned on while damaged?
    -- In other words, should this method set shieldHitpoints to max?
    -- state changes before calling handlers
    self.state = true

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.restoredCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors .. "\nError while running callback " .. i .. ": " .. err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:" .. errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)

    closure.getShieldHitpoints = function() return self:getShieldHitpoints() end
    closure.getMaxShieldHitpoints = function() return self:getMaxShieldHitpoints() end
    closure.getResistances = function() return self:getResistances() end
    closure.setResistances = function(antimatter, electromagnetic, kinetic, thermic) return self:setResistances(antimatter, electromagnetic, kinetic, thermic) end
    closure.getResistancesCooldown = function() return self:getResistancesCooldown() end
    closure.getResistancesMaxCooldown = function() return self:getResistancesMaxCooldown() end
    closure.getResistancesPool = function() return self:getResistancesPool() end
    closure.getResistancesRemaining = function() return self:getResistancesRemaining() end
    closure.inLockdown = function() return self:inLockdown() end
    closure.getLockdownRemaining = function() return self:getLockdownRemaining() end
    closure.getLockdownExitTime = function() return self:getLockdownExitTime() end
    closure.setLockdownExitTime = function(hour) return self:setLockdownExitTime(hour) end
    closure.getStressRatio = function() return self:getStressRatio() end
    closure.getStressRatioRaw = function() return self:getStressRatioRaw() end
    closure.getStressHitpoints = function() return self:getStressHitpoints() end
    closure.getStressHitpointsRaw = function() return self:getStressHitpointsRaw() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M
