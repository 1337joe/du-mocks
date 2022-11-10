--- A general kinematic unit to obtain information about the ship orientation, velocity, and acceleration.
--
-- Element class: GyroUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module GyroUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["gyroscope xs"] = {mass = 104.41, maxHitPoints = 50, itemId = 2585415184}
local DEFAULT_ELEMENT = "gyroscope xs"

local M = MockElementWithToggle:new()
M.elementClass = "GyroUnit"
M.widgetType = "gyro"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.pitch = 0 -- deg
    o.roll = 0 -- deg

    -- only activateable when on a dynamic core, this allows for testing on a static core if needed for some reason
    o.dynamicCore = true

    return o
end

--- Sets this gyro as the main gyro used for ship orientation.
--
-- Note: Has no effect when called on a static core.
function M:activate()
    self.state = self.dynamicCore == true
end

--- Deselects this gyro as the main gyro used for ship orientation, using the core unit instead.
function M:deactivate()
    self.state = false
end

--- Toggle the activation state of the gyro.
--
-- Note: Has no effect when called on a static core.
function M:toggle()
    self.state = self.dynamicCore == true and not self.state
end

--- Returns the activation state of the gyro.
-- @treturn 0/1 1 when the gyro is the active ship orientation, 0 otherwise.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

local DATA_TEMPLATE = '{\"helperId\":\"gyro\",\"name\":\"%s\","pitch":%.17f,"roll":%.16f,\"type\":\"%s\"}'
--- Get element data as JSON.
--
-- Gyroscopes have a <code>gyro</code> widget, which contains the following fields (bold fields are visible when making
-- custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">pitch</span></b> (<span class="type">float</span>) Pitch angle in degrees.</li>
--   <li><b><span class="parameter">roll</span></b> (<span class="type">float</span>) Roll angle in degrees.</li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>gyro</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>gyro</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    return string.format(DATA_TEMPLATE, self.name, self.pitch, self.roll, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- <b>Deprecated:</b> The up vector of the gyro unit, in construct local coordinates.
--
-- This method is deprecated: Element.getUp should be used instead
-- @see Element.getUp
-- @return Normalized up vector of the gyro unit, in construct local coordinates.
function M:localUp()
    M.deprecated("localUp", "Element.getUp")
    return self:getUp()
end

--- <b>Deprecated:</b> The forward vector of the gyro unit, in construct local coordinates.
--
-- This method is deprecated: Element.getForward should be used instead
-- @see Element.getForward
-- @return Normalized forward vector of the gyro unit, in construct local coordinates.
function M:localForward()
    M.deprecated("localForward", "Element.getForward")
    return self:getForward()
end

--- <b>Deprecated:</b> The right vector of the gyro unit, in construct local coordinates.
--
-- This method is deprecated: Element.getRight should be used instead
-- @see Element.getRight
-- @return Normalized right vector of the gyro unit, in construct local coordinates.
function M:localRight()
    M.deprecated("localRight", "Element.getRight")
    return self:getRight()
end

--- <b>Deprecated:</b> The up vector of the gyro unit, in world coordinates.
--
-- This method is deprecated: Element.getWorldUp should be used instead
-- @see Element.getWorldUp
-- @return Normalized up vector of the gyro unit, in world coordinates.
function M:worldUp()
    M.deprecated("worldUp", "Element.getWorldUp")
    return self:getWorldUp()
end

--- <b>Deprecated:</b> The forward vector of the gyro unit, in world coordinates.
--
-- This method is deprecated: Element.getWorldForward should be used instead
-- @see Element.getWorldForward
-- @return Normalized forward vector of the gyro unit, in world coordinates.
function M:worldForward()
    M.deprecated("worldForward", "Element.getWorldForward")
    return self:getWorldForward()
end

--- <b>Deprecated:</b> The right vector of the gyro unit, in world coordinates.
--
-- This method is deprecated: Element.getWorldRight should be used instead
-- @see Element.getWorldRight
-- @return Normalized right vector of the gyro unit, in world coordinates.
function M:worldRight()
    M.deprecated("worldRight", "Element.getWorldRight")
    return self:getWorldRight()
end

--- The pitch value relative to the gyro orientation and the local gravity.
-- @treturn float The pitch angle in degrees, relative to the gyro orientation and the local gravity.
function M:getPitch()
    return self.pitch
end

--- The roll value relative to the gyro orientation and the local gravity.
-- @treturn float The roll angle in degrees, relative to the gyro orientation and the local gravity.
function M:getRoll()
    return self.roll
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.localUp = function() return self:localUp() end
    closure.localForward = function() return self:localForward() end
    closure.localRight = function() return self:localRight() end
    closure.worldUp = function() return self:worldUp() end
    closure.worldForward = function() return self:worldForward() end
    closure.worldRight = function() return self:worldRight() end
    closure.getPitch = function() return self:getPitch() end
    closure.getRoll = function() return self:getRoll() end
    return closure
end

return M