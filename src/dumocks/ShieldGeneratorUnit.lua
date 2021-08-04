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

    return o
end

local DATA_TEMPLATE = '{"elementId":%d,"helperId":"shield_generator","isActive":%s,"name":"%s [%d]","shieldHp":%f,' ..
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
    return string.format(DATA_TEMPLATE, generatorId, self.state, self.name, self:getId(), self.shieldHitPoints,
        self.maxShieldHitPoints, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Returns the current hit points of the shield.
-- @treturn float The current hit points of the shield.
function M:getShieldHitPoints()
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