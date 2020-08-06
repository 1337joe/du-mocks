--- System.
-- System is a virtual element that represents your computer. It gives access to events like key strokes or mouse
-- movements that can be used inside your scripts. It also gives you access to regular updates that can be used to pace
-- the execution of your script.
-- @module MockSystem
-- @alias M

-- local posix = require "posix" -- for more precise clock

-- define class fields
local M = {}

function M:new(o)
    -- define default instance fields
    o = o or {
        widgetPanels = {},
    }
    setmetatable(o, self)
    self.__index = self

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
end

function M:isViewLocked()
end

function M:freeze(bool)
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

--- Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing this object.
function M:getClosure()
    local closure = {}
    closure.createWidgetPanel = function(label) return self:createWidgetPanel(label) end
    closure.destroyWidgetPanel = function(label) return self:destroyWidgetPanel(label) end
    closure.getTime = function() return self.getTime() end
    closure.print = function(msg) return self.print(msg) end
    return closure
end

return M