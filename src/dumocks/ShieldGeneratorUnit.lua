--- Generates a protective shield around the construct.
--
-- Element class: ShieldGeneratorUnit
--
-- Extends: Element &gt; ElementWithState &gt; ElementWithToggle
-- @see Element
-- @see ElementWithState
-- @see ElementWithToggle
-- @module ShieldGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["shield generator xs"] = {mass = 670.0, maxHitPoints = 1400.0, maxShieldHitPoints = 300000.0}
elementDefinitions["shield generator s"] = {mass = 3300.0, maxHitPoints = 4500.0, maxShieldHitPoints = 1750000.0}
elementDefinitions["shield generator m"] = {mass = 17000.0, maxHitPoints = 6750.0, maxShieldHitPoints = 8000000.0}
elementDefinitions["shield generator l"] = {mass = 92000.0, maxHitPoints = 31500.0, maxShieldHitPoints = 25000000.0}
local DEFAULT_ELEMENT = "shield generator xs"

local M = MockElementWithToggle:new()
M.elementClass = "ShieldGeneratorUnit"
M.widgetType = "shield_generator"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.shieldHitPoints = elementDefinition.maxShieldHitPoints
    o.maxShieldHitPoints = elementDefinition.maxShieldHitPoints

    o.absorbedCallbacks = {}
    o.downCallbacks = {}
    o.restoredCallbacks = {}

    -- automatically call appropriate callbacks on state change, if disabled use mockTriggerCallback after state change
    o.autoCallback = true
    o.newState = o.state

    return o
end

-- Behavior override to allow for delayed state change.
function M:activate()
    self.newState = true
    if self.autoCallback then
        self:mockTriggerCallback()
    end
end

-- Behavior override to allow for delayed state change.
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

local DATA_TEMPLATE = '{"elementId":%d,"helperId":"shield_generator","isActive":%s,"name":"%s","shieldHp":%f,' ..
    '"shieldMaxHp":%f,"type":"%s"}'
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
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">elementId</span> (<span class="type">int</span>) The (globally unique?) id of the
--     shield generator element, may be related to linking the commands to the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>shield_generator</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>shield_generator</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getData()
    local generatorId = 123456789
    return string.format(DATA_TEMPLATE, generatorId, self.state, self.name, self.shieldHitPoints,
        self.maxShieldHitPoints, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Returns the current hit points of the shield.
-- @treturn float The current hit points of the shield.
function M:getShieldHitPoints()
    if not self.state then
        return 0
    end
    return self.shieldHitPoints
end

--- Returns the maximal hit points of the shield.
-- @treturn float The maximal hit points of the shield.
function M:getMaxShieldHitPoints()
    return self.maxShieldHitPoints
end

--- Event: Emitted when the shield absorbed incoming damage.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam float hitpoints Hit points the shield lost.
function M.EVENT_absorbed(hitpoints)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the shield hit points reached 0 due to damage or deactivation.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_down()
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the shield hit points were fully restored.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_restored()
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Register a handler for the in-game `absorbed(hitpoints)` event.
-- @tparam function callback The function to call when the shield comes up.
-- @tparam string The hit points to filter for or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_absorbed
function M:mockRegisterAbsorbed(callback, hitpoints)
    local index = #self.absorbedCallbacks + 1
    self.absorbedCallbacks[index] = {callback = callback, hitpoints = hitpoints}
    return index
end

--- Mock only, not in-game: Simulates the shield absorbing damage.
--
-- Note: The state updates to true before the event handlers are called.
-- @tparam int hitpoints The amount of damage to deal.
function M:mockDoAbsorbed(hitpoints)
    -- bail if deactivated
    if not self.state then
        return
    end

    -- TODO does the shield go down before calling absorbed or not?
    self.shieldHitPoints = math.max(0, self.shieldHitPoints - hitpoints)
    if self.shieldHitPoints == 0 then
        self.state = false
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.absorbedCallbacks) do
        -- filter on the receiver default channel and on message
        if (callback.hitpoints == "*" or callback.hitpoints == hitpoints) then
            local status,err = pcall(callback.callback, hitpoints)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
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
    for i,callback in pairs(self.downCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
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
    -- In other words, should this method set shieldHitPoints to max?
    -- state changes before calling handlers
    self.state = true

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.restoredCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Triggers the appropriate callback when the element state changes. Shields don't activate /
-- deactivate instantly, so this allows for a user-managed delay.
function M:mockTriggerCallback()
    if self.newState == self.state then
        return
    end

    if self.newState then
        self:mockDoRestored()
    else
        self:mockDoDown()
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)

    closure.getShieldHitPoints = function() return self:getShieldHitPoints() end
    closure.getMaxShieldHitPoints = function() return self:getMaxShieldHitPoints() end
    return closure
end

return M