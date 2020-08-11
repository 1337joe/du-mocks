--- Manual button.
-- Emits a signal for the duration it is pressed.
-- @module MockManualButton
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {}
elementDefinitions["manual button xs"] = {mass = 13.27, maxHitPoints = 50.0}
elementDefinitions["manual button s"] = {mass = 13.27, maxHitPoints = 50.0}
local DEFAULT_ELEMENT = "manual button s"

local M = MockElement:new()
M.elementClass = "ManualButtonUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false
    o.pressedCallbacks = {}
    o.releasedCallbacks = {}

    return o
end

--- Returns the activation state of the button.
-- @return 1 when the button is pressed, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Mock only, not in-game: Register a handler for the in-game `pressed()` event.
--
-- Event: `pressed()`
--
-- The button has been pressed.
-- @tparam function callback The function to call when the button is pressed.
-- @treturn int The index of the callback.
function M:mockRegisterPressed(callback)
    local index = #self.pressedCallbacks + 1
    self.pressedCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the user pressing the button. Calling this while the button is already deactivated
-- is invalid and will have no effect.
--
-- Note: the state updates to true <em>before</em> the event handlers are called, which is different behavior to
-- releasing the button.
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
--
-- Event: `released()`
--
-- The button has been released.
-- @tparam function callback The function to call when the button is released.
-- @treturn int The index of the callback.
function M:mockRegisterReleased(callback)
    local index = #self.releasedCallbacks + 1
    self.releasedCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the user pressing the button. Calling this while the button is already deactivated
-- is invalid and will have no effect.
--
-- Note: the state updates to true <em>after</em> the event handlers are called, which is different behavior to
-- pressing the button.
function M:mockDoReleased()
    -- bail if already deactivated
    if not self.state then
        return
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.releasedCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- state changes after calling handlers
    self.state = true

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see MockElement:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getState = function() return self:getState() end
    return closure
end

return M