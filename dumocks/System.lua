--- System.
-- System is a virtual element that represents your computer. It gives access to events like key strokes or mouse
-- movements that can be used inside your scripts. It also gives you access to regular updates that can be used to pace
-- the execution of your script.
-- @module System
-- @alias M

-- local posix = require "posix" -- for more precise clock

-- define class fields
local M = {}

function M:new(o)
    -- define default instance fields
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.widgetPanels = {} -- id (format: "p#") => {ordered list of widgets}
    o.widgets = {} -- id (format: "w#") => current data ids
    o.widgetData = {} -- id (format: "d#") => json

    return o
end

function M:getActionKeyName(actionName)
end

function M:showScreen(bool)
end

function M:setScreen(content)
end

--- Create an empty panel. Note that this function is disabled if the player is not running the script explicitly
-- (pressing F on the Control unit, vs. via a plug signal).
-- @tparam string label The title of the panel.
-- @treturn string The panel ID, or "" on failure.
function M:createWidgetPanel(label)
    local nextIndex = #self.widgetPanels + 1
    -- TODO is this necessary?
    while self.widgetPanels[tostring(nextIndex)] ~= nil do
        nextIndex = nextIndex + 1
    end
    self.widgetPanels[tostring(nextIndex)] = {name = label}
    return tostring(nextIndex)
end

--- Destroy the panel. Note that this function is disabled if the player is not running the script explicitly (pressing
-- F on the Control unit, vs. via a plug signal).
-- @tparam string panelId The panel ID.
-- @treturn boolean 1 on success, 0 on failure
function M:destroyWidgetPanel(panelId)
    if self.widgetPanels[panelId] ~= nil then
        self.widgetPanels[panelId] = nil
        return 1
    end
    return 0
end

function M:createWidget(panelId, type)
end

function M:destroyWidget(widgetId)
end

function M:createData(dataJson)
end

function M:destroyData(dataId)
end

function M:updateData(dataId, dataJson)
end

function M:addDataToWidget(dataId, widgetId)
end

function M:removeDataFromWidget(dataId, widgetId)
end

function M:getMouseWheel()
end

function M:getMouseDeltaX()
end

function M:getMouseDeltaY()
end

function M:getMousePosX()
end

function M:getMousePosY()
end

function M:getThrottleInputFromMouseWheel()
end

function M:getControlDeviceForwardInput()
end

function M:getControlDeviceYawInput()
end

function M:getControlDeviceLeftRightInput()
end

function M:lockView()
    self.lockView = true
end

function M:isViewLocked()
end

function M:freeze(bool)
    self.freezeCharacter = bool
end

function M:isFrozen()
end

--- Return the current time since the arrival of the Arkship.
-- @treturn second The current time in seconds, with a microsecond precision.
function M.getTime()
    -- creates dependency on posix
    -- local s, ns = posix.clock_gettime(0)
    -- return s + math.floor(ns / 1000 + .5)
    return os.time() -- only precise to full seconds
end

function M:getActionUpdateDeltaTime()
end

function M:getPlayerName(id)
end

function M:getPlayerWorldPos(id)
end

--- Print a message in the Lua console.
-- @tparam string msg The message to print.
function M.print(msg)
    print(msg)
end

--- Event: Emitted when an action starts.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionStart(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when an action stops.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionStop(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted at each update as long as the action is maintained.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionLoop(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Game update event. This is equivalent to a timer set at 0 seconds, as updates will go as fast as the FPS can
-- go.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_update()
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Physics update. Do not use to put anything else by a call to updateICC on your control unit, as many
-- functions are disabled when called from 'flush'. This is only to update the physics (engine control, etc), not to
-- setup some gameplay code.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_flush()
    assert(false, "This is implemented for documentation purposes only.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.getActionKeyName = function(actionName) return self:getActionKeyName(actionName) end
    closure.showScreen = function(bool) return self:showScreen(bool) end
    closure.setScreen = function(content) return self:setScreen(content) end
    closure.createWidgetPanel = function(label) return self:createWidgetPanel(label) end
    closure.destroyWidgetPanel = function(label) return self:destroyWidgetPanel(label) end
    closure.createWidget = function(panelId, type) return self:createWidget(panelId, type) end
    closure.destroyWidget = function(widgetId) return self:destroyWidget(widgetId) end
    closure.createData = function(dataJson) return self:createData(dataJson) end
    closure.destroyData = function(dataId) return self:destroyData(dataId) end
    closure.updateData = function(dataId, dataJson) return self.updateData(dataId, dataJson) end
    closure.addDataToWidget = function(dataId, widgetId) return self.addDataToWidget(dataId, widgetId) end
    closure.removeDataFromWidget = function(dataId, widgetId) return self.removeDataFromWidget(dataId, widgetId) end
    closure.getMouseWheel = function() return self.getMouseWheel() end
    closure.getMouseDeltaX = function() return self.getMouseDeltaX() end
    closure.getMouseDeltaY = function() return self.getMouseDeltaY() end
    closure.getMousePosX = function() return self.getMousePosX() end
    closure.getMousePosY = function() return self.getMousePosY() end
    closure.getThrottleInputFromMouseWheel = function() return self.getThrottleInputFromMouseWheel() end
    closure.getControlDeviceForwardInput = function() return self.getControlDeviceForwardInput() end
    closure.getControlDeviceYawInput = function() return self.getControlDeviceYawInput() end
    closure.getControlDeviceLeftRightInput = function() return self.getControlDeviceLeftRightInput() end
    closure.lockView = function() return self.lockView() end
    closure.isViewLocked = function() return self.isViewLocked() end
    closure.freeze = function(bool) return self.freeze() end
    closure.isFrozen = function() return self.isFrozen() end
    closure.getTime = function() return self.getTime() end
    closure.getActionUpdateDeltaTime = function() return self.getActionUpdateDeltaTime() end
    closure.getPlayerName = function(id) return self.getPlayerName(id) end
    closure.getPlayerWorldPos = function(id) return self.getPlayerWorldPos(id) end
    closure.print = function(msg) return self.print(msg) end
    return closure
end

return M