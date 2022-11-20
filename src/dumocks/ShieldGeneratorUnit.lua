--- Generates a protective shield around the construct.
--
-- Element class:
-- <ul>
--   <li>ShieldGeneratorExtraSmallGroup</li>
--   <li>ShieldGeneratorSmallGroup</li>
--   <li>ShieldGeneratorMediumGroup</li>
--   <li>ShieldGeneratorLargeGroup</li>
-- </ul>
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module ShieldGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local CLASS = "ShieldGenerator"
local EXTRA_SMALL_GROUP = "ExtraSmallGroup"
local SMALL_GROUP = "SmallGroup"
local MEDIUM_GROUP = "MediumGroup"
local LARGE_GROUP = "LargeGroup"

local elementDefinitions = {}
elementDefinitions["shield generator xs"] = {mass = 670.0, maxHitPoints = 1400.0, itemId = 2882830295, class = CLASS .. EXTRA_SMALL_GROUP, maxShieldHitpoints = 450000.0, ventingMaxCooldown = 60.0}
elementDefinitions["shield generator s"] = {mass = 5000.0, maxHitPoints = 4500.0, itemId = 3696387320, class = CLASS .. SMALL_GROUP, maxShieldHitpoints = 1750000.0, ventingMaxCooldown = 120.0}
elementDefinitions["shield generator m"] = {mass = 30000.0, maxHitPoints = 6750.0, itemId = 254923774, class = CLASS .. MEDIUM_GROUP, maxShieldHitpoints = 5000000.0, ventingMaxCooldown = 240.0}
elementDefinitions["shield generator l"] = {mass = 125000.0, maxHitPoints = 31500.0, itemId = 2034818941, class = CLASS .. LARGE_GROUP, maxShieldHitpoints = 10000000.0, ventingMaxCooldown = 480.0}
local DEFAULT_ELEMENT = "shield generator xs"

local M = MockElementWithToggle:new()
M.widgetType = "shield_generator"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class
    o.shieldHitpoints = elementDefinition.maxShieldHitpoints
    o.maxShieldHitpoints = elementDefinition.maxShieldHitpoints

    o.venting = false
    o.ventingCooldown = 0
    o.ventingMaxCooldown = elementDefinition.ventingMaxCooldown

    o.plugIn = 0.0

    o.toggledCallbacks = {}
    o.absorbedCallbacks = {}
    o.downCallbacks = {}
    o.restoredCallbacks = {}

    -- automatically call appropriate callbacks on state change, if disabled use mockTriggerCallback after state change
    o.autoCallback = true
    o.newState = o.state

    return o
end

--- Activate the shield.
function M:activate()
    self.newState = true
    if self.autoCallback then
        self:mockTriggerCallback()
    end
end

--- Deactivate the shield.
function M:deactivate()
    self.newState = false
    if self.autoCallback then
        self:mockTriggerCallback()
    end
end

-- Behavior override to allow for delayed state change.
function M:toggle()
    self.newState = not self.state
    if self.autoCallback then
        self:mockTriggerCallback()
    end
end

--- Returns the activation state of the shield.
-- @treturn 0/1 1 when the shield is active, 0 otherwise.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

local DATA_TEMPLATE = '{"elementId":%d,"helperId":"shield_generator","isActive":%s,"isVenting":%s,' ..
                      '"ventingCooldown":%f,"ventingMaxCooldown":%f,"ventingStartHp":%f,"ventingTargetHp":%f,' ..
                      '"resistances":{%s},"name":"%s","shieldHp":%f,"shieldMaxHp":%f,"type":"%s"}'
local RESISTANCE_TEMPLATE = '{"%s":{"stress":%f,"value":%f}'
--- Get element data as JSON.
--
-- Shield generators have a <code>shield_generator</code> widget, which contains the following fields (bold fields are
-- visible when making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">shieldHp</span></b> (<span class="type">float</span>) Shield hit points.</li>
--   <li><b><span class="parameter">shieldMaxHp</span></b> (<span class="type">float</span>) Max shield hit points.
--     </li>
--   <li><b><span class="parameter">isActive</span></b> (<span class="type">boolean</span>) True if the shield is
--     active, false otherwise.</li>
--   <li><b><span class="parameter">isVenting</span></b> (<span class="type">boolean</span>) True if the shield is
--     venting, false otherwise.</li>
--   <li><b><span class="parameter">ventingCooldown</span></b> (<span class="type">float</span>) Remaining cooldown
--     before venting is possible in seconds.</li>
--   <li><span class="parameter">ventingMaxCooldown</span> (<span class="type">float</span>) Max cooldown before
--     venting is possible once venting stops.</li>
--   <li><b><span class="parameter">ventingStartHp</span></b> (<span class="type">float</span>) Shield hit points when
--     venting started, used to calculate percent done with venting.</li>
--   <li><b><span class="parameter">ventingTargetHp</span></b> (<span class="type">float</span>) Shield hit points when
--     venting will stop, used to calculate percent done with venting.</li>
--   <li><b><span class="parameter">resistances</span></b> (<span class="type">float</span>) List of resistance
--     parameters for each of: antimatter, electromagnetic, kinetic, thermic
--     <ul>
--       <li><b><span class="parameter">stress</span></b> (<span class="type">float</span>) Percentage to fill the
--         stress meter, &le; 0.01 = 0 bars, &le; .26 = 1 bar, &le; .51 = 2 bars, &gt; .51 = 3 bars.</li>
--       <li><b><span class="parameter">value</span></b> (<span class="type">float</span>) Percentage value to show
--         next to resistance stress meter, 0.01 will show as 1%.</li>
--     </ul></li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">elementId</span> (<span class="type">int</span>) The (globally unique?) id of the
--     shield generator element, may be related to linking the commands to the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>shield_generator</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>shield_generator</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    local generatorId = 123456789
    local ventingStartHp = 0.0
    local ventingTargetHp = self.maxShieldHitpoints
    local resistances = {
        string.format(RESISTANCE_TEMPLATE, "antimatter", 0.0, 0.0),
        string.format(RESISTANCE_TEMPLATE, "electromagnetic", 0.0, 0.0),
        string.format(RESISTANCE_TEMPLATE, "kinetic", 0.0, 0.0),
        string.format(RESISTANCE_TEMPLATE, "thermic", 0.0, 0.0)
    }
    local resistancesString = table.concat(resistances, ",")
    return string.format(DATA_TEMPLATE, generatorId, self.state, self.venting, self.ventingCooldown,
        self.ventingMaxCooldown, ventingStartHp, ventingTargetHp, resistancesString, self.name, self.shieldHitpoints,
        self.maxShieldHitpoints, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Returns the current hit points of the shield.
-- @treturn float The current hit points of the shield.
function M:getShieldHitpoints()
    if not self.state then
        return 0
    end
    return self.shieldHitpoints
end

--- Returns the maximal hit points of the shield.
-- @treturn float The maximal hit points of the shield.
function M:getMaxShieldHitpoints()
    return self.maxShieldHitpoints
end

--- Activate shield venting to restore hit points.
-- @treturn 0/1 1 if venting started, 0 if an error occurred.
function M:startVenting()
    if self.ventingCooldown > 0 then
        return 0
    end

    self.venting = true

    return 1
end

--- Stop shield venting.
-- @treturn 0/1 1 if venting stopped, 0 if an error occurred.
function M:stopVenting()
    if self.venting == false then
        return 0
    end
    self.venting = false
    self.ventingCooldown = self.ventingMaxCooldown

    return 1
end

-- TODO add mock venting step function to increase health based on time elapsed while venting

--- Check whether venting is in progress.
-- @treturn 0/1 1 if venting is ongoing, 0 otherwise.
function M:isVenting()
    if self.venting then
        return 1
    end
    return 0
end

--- Returns time after which venting is possible again.
-- @treturn float Remaining seconds of the venting cooldown.
function M:getVentingCooldown()
    return self.ventingCooldown
end

--- Returns maximal cooldown between venting.
-- @treturn float Maximal seconds of the venting cooldown.
function M:getVentingMaxCooldown()
    return self.ventingMaxCooldown
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


--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- no longer responds to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- <b>Deprecated:</b> Event: Emitted when we started or stopped the shield generator.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onToggled should be used instead.
-- @see EVENT_onToggled
-- @tparam 0/1 active 1 if the element was activated, 0 otherwise.
function M.EVENT_toggled(active)
    M.deprecated("EVENT_toggled", "EVENT_onToggled")
    M.EVENT_onToggled(active)
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

--- <b>Deprecated:</b> Event: Emitted when venting started, stopped or restored some hitpoints.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onVenting should be used instead.
-- @see EVENT_onVenting
-- @tparam 0/1 active 1 when venting is active, 0 otherwise.
-- @tparam float restoredHitpoints Hitpoints restored since last venting step.
function M.EVENT_venting(active, restoredHitpoints)
    M.deprecated("EVENT_venting", "EVENT_onVenting")
    M.EVENT_onVenting(active, restoredHitpoints)
end

--- Event: Emitted when venting started, stopped or restored some hitpoints.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam 0/1 active 1 when venting is active, 0 otherwise.
-- @tparam float restoredHitpoints Hitpoints restored since last venting step.
function M.EVENT_onVenting(active, restoredHitpoints)
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

--- Mock only, not in-game: Register a handler for the in-game `onToggled(active)` event.
-- @tparam function callback The function to call when the shield state changes.
-- @tparam string active The state to filter for or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_toggled
function M:mockRegisterToggled(callback, active)
    local index = #self.toggledCallbacks + 1
    self.toggledCallbacks[index] = {
        callback = callback,
        active = active
    }
    return index
end

--- Mock only, not in-game: Simulates the shield changing state.
--
-- Note: The state updates before the event handlers are called.
-- @tparam 0/1 active The new state, 0 for off, 1 for on.
function M:mockDoToggled(active)
    -- bail if already in desired state
    if self.state == (active == 1) then
        return
    end

    self.state = (active == 1)

    -- call callbacks in order, saving exceptions until end
    local activeString = tostring(active) -- in case registered with string argument, following "*" pattern
    local errors = ""
    for i, callback in pairs(self.toggledCallbacks) do
        -- filter on active
        if (callback.active == "*" or callback.active == active or callback.active == activeString) then
            local status, err = pcall(callback.callback, active)
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

--- Mock only, not in-game: Register a handler for the in-game `onAbsorbed(hitpoints, rawHitpoints)` event.
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

--- Mock only, not in-game: Register a handler for the in-game `onDown()` event.
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

--- Mock only, not in-game: Register a handler for the in-game `onRestored()` event.
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

--- Mock only, not in-game: Triggers the appropriate callback when the element state changes. Shields don't activate /
-- deactivate instantly, so this allows for a user-managed delay.
function M:mockTriggerCallback()
    if self.newState == self.state then
        return
    end

    if self.newState then
        self:mockDoToggled(1)
    else
        self:mockDoToggled(0)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.getShieldHitpoints = function() return self:getShieldHitpoints() end
    closure.getMaxShieldHitpoints = function() return self:getMaxShieldHitpoints() end
    closure.startVenting = function() return self:startVenting() end
    closure.stopVenting = function() return self:stopVenting() end
    closure.isVenting = function() return self:isVenting() end
    closure.getVentingCooldown = function() return self:getVentingCooldown() end
    closure.getVentingMaxCooldown = function() return self:getVentingMaxCooldown() end
    closure.getResistances = function() return self:getResistances() end
    closure.setResistances = function(antimatter, electromagnetic, kinetic, thermic) return self:setResistances(antimatter, electromagnetic, kinetic, thermic) end
    closure.getResistancesCooldown = function() return self:getResistancesCooldown() end
    closure.getResistancesMaxCooldown = function() return self:getResistancesMaxCooldown() end
    closure.getResistancesPool = function() return self:getResistancesPool() end
    closure.getResistancesRemaining = function() return self:getResistancesRemaining() end
    closure.getStressRatio = function() return self:getStressRatio() end
    closure.getStressRatioRaw = function() return self:getStressRatioRaw() end
    closure.getStressHitpoints = function() return self:getStressHitpoints() end
    closure.getStressHitpointsRaw = function() return self:getStressHitpointsRaw() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M
