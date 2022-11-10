--- Emits a signal for the duration it is pressed.
--
-- Element class: ManualButtonUnit
--
-- Extends: @{Element} &gt; @{ElementWithState}
-- @module ManualButtonUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithState = require "dumocks.ElementWithState"

local elementDefinitions = {}
elementDefinitions["manual button xs"] = {mass = 13.27, maxHitPoints = 50.0, itemId = 1550904282}
elementDefinitions["manual button s"] = {mass = 13.27, maxHitPoints = 50.0, itemId = 2896791363}
local DEFAULT_ELEMENT = "manual button s"

local M = MockElementWithState:new()
M.elementClass = "ManualButtonUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithState:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.pressedCallbacks = {}
    o.releasedCallbacks = {}

    return o
end

--- Checks if the manual button is down.
-- @treturn 0/1 1 if the manual button is down.
function M:isDown()
    if self.state then
        return 1
    end
    return 0
end

--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"out" for the out signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state.
function M:getSignalOut(plug)
    if plug == "out" then
        if self.state then
            return 1.0
        else
            return 0.0
        end
    end
    return MockElement.getSignalOut(self, plug)
end

--- <b>Deprecated:</b> Event: The button has been pressed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onPressed should be used instead.
-- @see EVENT_onPressed
function M.EVENT_pressed()
    M.deprecated("EVENT_pressed", "EVENT_onPressed")
    M.EVENT_onPressed()
end

--- Event: Emitted when the button is pressed.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onPressed()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterPressed")
end

--- <b>Deprecated:</b> Event: The button has been released.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onReleased should be used instead.
-- @see EVENT_onReleased
function M.EVENT_released()
    M.deprecated("EVENT_released", "EVENT_onReleased")
    M.EVENT_onReleased()
end

--- Event: Emitted when the button is released.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onReleased()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterReleased")
end

--- Mock only, not in-game: Register a handler for the in-game `onPressed()` event.
-- @tparam function callback The function to call when the button is pressed.
-- @treturn int The index of the callback.
-- @see EVENT_onPressed
function M:mockRegisterPressed(callback)
    local index = #self.pressedCallbacks + 1
    self.pressedCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the user pressing the button. Calling this while the button is already deactivated
-- is invalid and will have no effect.
--
-- Note: The state updates to true before the event handlers are called.
function M:mockDoPressed()
    -- bail if already activated
    if self.state then
        return
    end

    -- state changes before calling handlers
    self.state = true

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.pressedCallbacks) do
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

--- Mock only, not in-game: Register a handler for the in-game `released()` event.
-- @tparam function callback The function to call when the button is released.
-- @treturn int The index of the callback.
-- @see EVENT_released
function M:mockRegisterReleased(callback)
    local index = #self.releasedCallbacks + 1
    self.releasedCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the user pressing the button. Calling this while the button is already deactivated
-- is invalid and will have no effect.
--
-- Note: The state updates to false before the event handlers are called.
function M:mockDoReleased()
    -- bail if already deactivated
    if not self.state then
        return
    end

    -- state changes before calling handlers
    self.state = false

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.releasedCallbacks) do
        local status, err = pcall(callback)
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
    local closure = MockElementWithState.mockGetClosure(self)
    closure.isDown = function() return self:isDown() end

    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M