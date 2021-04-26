--- System is a virtual element that represents your computer. It gives access to events like key strokes or mouse
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

    o.lockView = false
    o.freezeCharacter = false

    o.screenHeight = 1080
    o.screenWidth = 1920
    o.fov = 90

    return o
end

--- Return the currently key bound to the given action. Useful to display tips.
-- @param actionName (Undocumented) The action to query.
-- @treturn string The key associated to the given action name.
function M:getActionKeyName(actionName)
end

--- Control the display of the control unit custom screen, where you can define customized display information in HTML.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam boolean bool 1 show the screen, 0 hide the screen.
function M:showScreen(bool)
end

--- Set the content of the control unit custom screen with some HTML code.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam html content THe HTML content you want to display on the screen widget. You can also use SVG here to make
-- drawings.
function M:setScreen(content)
end

--- Create an empty panel. The original/official widget documentation is posted on the
-- <a href="https://board.dualthegame.com/index.php?/topic/16527-alpha-2-lua-changes-and-novelties/">forum</a>.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
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

--- Destroy the panel.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string panelId The panel ID.
-- @treturn boolean 1 on success, 0 on failure
function M:destroyWidgetPanel(panelId)
    if self.widgetPanels[panelId] ~= nil then
        self.widgetPanels[panelId] = nil
        return 1
    end
    return 0
end

--- Create an empty widget and add it to a panel.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
--
-- <h3>Available types:</h3>
-- Format: <span class="parameter">type</span> Description and contents (if type isn't a link to the relevent element
-- page for contents).
-- <ul>
--   <li><span class="parameter">text</span> Simple text display.
--     <ul>
--       <li><span class="parameter">text</span> (<span class="type">string</span>) The text to show.</li>
--     </ul>
--   </li>
--   <li><span class="parameter">title</span> Displays a bar like the panel title within the panel.
--     <ul>
--       <li><span class="parameter">text</span> (<span class="type">string</span>) The title to show.</li>
--     </ul>
--   </li>
--   <li><span class="parameter">gauge</span> Shows a bar filled up to the specified percentage.
--     <ul>
--       <li><span class="parameter">percentage</span> (<span class="type">float</span>) The percent full.</li>
--     </ul>
--   </li>
--   <li><span class="parameter">value</span> Shows a value, complete with label and units formatting.
--     <ul>
--       <li><span class="parameter">label</span> (<span class="type">string</span>) The label to show.</li>
--       <li><span class="parameter">value</span> (<span class="type">float</span>) The current value.</li>
--       <li><span class="parameter">unit</span> (<span class="type">string</span>) The unit label.</li>
--     </ul>
--   </li>
--   <li><span class="parameter">@{AntiGravityGeneratorUnit:getData|antigravity_generator}</span> The widget created by
--     the Anti-Gravity Generator element.</li>
--   <li><span class="parameter">@{ContainerUnit:getData|fuel_container}</span> The widget created by fuel tanks.</li>
--   <li><span class="parameter">@{CoreUnit:getData|core}</span> The widget created by core units.</li>
--   <li><span class="parameter">@{EngineUnit:getData|engine_unit}</span> The widget created by engines.</li>
--   <li><span class="parameter">@{GyroUnit:getData|gyro}</span> The widget created by gyroscopes.</li>
-- </ul>
-- @tparam string panelId The panel ID.
-- @tparam string type Widget type, determining how it will display data attached to ID.
-- @treturn string The widget ID, or "" on failure.
function M:createWidget(panelId, type)
end

--- Destroy the widget.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string widgetId The widget ID.
-- @treturn boolean 1 on success, 0 on failure.
function M:destroyWidget(widgetId)
end

--- Create data. See @{createWidget} for links to the format expected for the different widget types.
--
-- The string passed in must be valid JSON, the following samples are valid data strings for various widgets:
-- <ul>
--   <li>Single string value for text widget: <code>{"text":"displayed text"}</code></li>
--   <li>Single numerical value for gague widget: <code>{"percentage":60}</code></li>
--   <li>Multiple numerical values and a boolean:
--     <code>{"antiGPower":0.5,"antiGravityField":10,"baseAltitude":2000,"showError":false}</code></li>
-- </ul>
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataJson The data fields as JSON.
-- @treturn string The data ID, or "" on failure.
-- @see updateData
function M:createData(dataJson)
end

--- Destroy the data.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @treturn boolean 1 on success, 0 on failure.
function M:destroyData(dataId)
end

--- Update JSON associated to data. The string passed in must be valid JSON. See @{createWidget} for links to the
-- format expected for the different widget types.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @tparam string dataJson The data fields as JSON.
-- @treturn boolean 1 on success, 0 on failure.
-- @see createData
function M:updateData(dataId, dataJson)
end

--- Add data to widget.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @tparam string widgetId The widget ID.
-- @treturn boolean 1 on success, 0 on failure.
function M:addDataToWidget(dataId, widgetId)
end

--- Remove data from widget.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @tparam string widgetId The widget ID.
-- @treturn boolean 1 on success, 0 on failure.
function M:removeDataFromWidget(dataId, widgetId)
end

--- Return the current value of the mouse wheel.
-- @treturn 0..1 The current value of the mouse wheel.
function M:getMouseWheel()
end

--- Return the current value of the mouse delta X.
-- @treturn float The current value of the mouse delta X.
function M:getMouseDeltaX()
end

--- Return the current value of the mouse delta Y.
-- @treturn float The current value of the mouse delta Y.
function M:getMouseDeltaY()
end

--- Return the current value of the mouse pos X.
-- @treturn float The current value of the mouse pos X.
function M:getMousePosX()
end

--- Return the current value of the mouse pos Y.
-- @treturn float The current value of the mouse pos Y.
function M:getMousePosY()
end

--- Return the current value of the mouse wheel (for the throttle speedUp/speedDown action).
-- @treturn 0..1 The current input.
function M:getThrottleInputFromMouseWheel()
end

--- Return the mouse input for the ship control action (forward/backward).
-- @treturn -1..1 The current input.
function M:getControlDeviceForwardInput()
end

--- Return the mouse input for the ship control action (yaw right/left).
-- @treturn -1..1 The current input.
function M:getControlDeviceYawInput()
end

--- Return the mouse input for the ship control action (right/left).
-- @treturn float The current value of the mouse delta Y.
function M:getControlDeviceLeftRightInput()
end

--- Lock or unlock the mouse free look.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam boolean state 1 to lock and 0 to unlock.
function M:lockView(state)
    self.lockView = state == 1
end

--- Return the lock state of the mouse free look.
-- @treturn boolean 1 when locked and 0 when unlocked.
function M:isViewLocked()
    if self.lockView then
        return 1
    end
    return 0
end

--- Freezes the character, liberating the associated movement keys to be used by the script.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam boolean bool 1 freeze the character, 0 unfreeze the character.
function M:freeze(bool)
    self.freezeCharacter = bool == 1
end

--- Return the frozen status of the character (see 'freeze').
-- @treturn boolean 1 if the character is frozen, 0 otherwise
function M:isFrozen()
    if self.freezeCharacter then
        return 1
    end
    return 0
end

--- Return the current time since the arrival of the Arkship.
-- @treturn second The current time in seconds, with a microsecond precision.
function M:getTime()
    -- creates dependency on posix
    -- local s, ns = posix.clock_gettime(0)
    -- return s + math.floor(ns / 1000 + .5)
    return os.time() -- only precise to full seconds
end

--- Return delta time of action updates (to use in ActionLoop).
-- @treturn second The delta time in seconds.
function M:getActionUpdateDeltaTime()
end

--- Return the name of the given player, if in range of visibility.
-- @tparam int id The ID of the player.
-- @treturn string The name of the player.
function M:getPlayerName(id)
end

--- Return the world position of the given player, if in range of visibility.
-- @tparam int id The ID of the player.
-- @treturn string The coordinates of the player in world coordinates.
function M:getPlayerWorldPos(id)
end

--- Return the player world position as a waypoint string, starting with ::pos (only in explicit runs).
-- @treturn string The waypoint as a string.
function M:getWaypointFromPlayerPos()
end

--- Set a waypoint at the destination described by the waypoint string, of the form ::pos{...}
-- @tparam string waypointStr The waypoint as a string.
function M:setWaypoint(waypointStr)
end

--- Return the current value of the screen height.
-- @treturn int The current value of the screen height.
function M:getScreenHeight()
    return self.screenHeight
end

--- Return the current value of the screen width.
-- @treturn int The current value of the screen width.
function M:getScreenWidth()
    return self.screenWidth
end

--- Return the current value of the player field of view.
-- @treturn float The current value of the player field of view.
function M:getFov()
    return self.fov
end

--- Print a message in the Lua console.
-- @tparam string msg The message to print.
function M:print(msg)
    print(msg)
end

--- Print a message to the game log file at `INFO` level. Log file is located in `<user>/AppData/Local/NQ/DualUniverse/log/`.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logInfo(msg)
end

--- Print a message to the game log file at `WARNING` level. Log file is located in `<user>/AppData/Local/NQ/DualUniverse/log/`.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logWarning(msg)
end

--- Print a message to the game log file at `ERROR` level. Log file is located in `<user>/AppData/Local/NQ/DualUniverse/log/`.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logError(msg)
end

--- Unknown use.
--
-- Note: This method is not documented in the codex.
-- @param filter
-- @param name
function M:addMarker(filter, name)
end

--- Unknown use.
--
-- Note: This method is not documented in the codex.
-- @param filter
-- @param sectionName
-- @param varName
-- @param value
function M:addMeasure(filter, sectionName, varName, value)
end

--- Unknown use.
--
-- Note: This method is not documented in the codex.
-- @param result
function M:__NQ_returnFromRunPlayerLUA(result)
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

--- Event: Console input event.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_inputText(text)
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
    closure.updateData = function(dataId, dataJson) return self:updateData(dataId, dataJson) end
    closure.addDataToWidget = function(dataId, widgetId) return self:addDataToWidget(dataId, widgetId) end
    closure.removeDataFromWidget = function(dataId, widgetId) return self:removeDataFromWidget(dataId, widgetId) end
    closure.getMouseWheel = function() return self:getMouseWheel() end
    closure.getMouseDeltaX = function() return self:getMouseDeltaX() end
    closure.getMouseDeltaY = function() return self:getMouseDeltaY() end
    closure.getMousePosX = function() return self:getMousePosX() end
    closure.getMousePosY = function() return self:getMousePosY() end
    closure.getScreenHeight = function() return self:getScreenHeight() end
    closure.getScreenWidth = function() return self:getScreenWidth() end
    closure.getFov = function() return self:getFov() end
    closure.getThrottleInputFromMouseWheel = function() return self:getThrottleInputFromMouseWheel() end
    closure.getControlDeviceForwardInput = function() return self:getControlDeviceForwardInput() end
    closure.getControlDeviceYawInput = function() return self:getControlDeviceYawInput() end
    closure.getControlDeviceLeftRightInput = function() return self:getControlDeviceLeftRightInput() end
    closure.lockView = function() return self.lockView() end
    closure.isViewLocked = function() return self:isViewLocked() end
    closure.freeze = function(bool) return self:freeze() end
    closure.isFrozen = function() return self:isFrozen() end
    closure.getTime = function() return self:getTime() end
    closure.getActionUpdateDeltaTime = function() return self:getActionUpdateDeltaTime() end
    closure.getPlayerName = function(id) return self:getPlayerName(id) end
    closure.getPlayerWorldPos = function(id) return self:getPlayerWorldPos(id) end
    closure.getWaypointFromPlayerPos = function() return self:getWaypointFromPlayerPos() end
    closure.setWaypoint = function(waypoint) return self:setWaypoint(waypoint) end
    closure.print = function(msg) return self:print(msg) end

    closure.logInfo = function(msg) return self:logInfo(msg) end
    closure.logWarning = function(msg) return self:logWarning(msg) end
    closure.logError = function(msg) return self:logError(msg) end
    closure.addMarker = function(filter, name) return self:addMarker(filter, name) end
    closure.addMeasure = function(filter, sectionName, varName, value) return self:addMeasure(filter, sectionName, varName, value) end
    closure.__NQ_returnFromRunPlayerLUA = function(result) return self:__NQ_returnFromRunPlayerLUA(result) end
    -- unknown use, but present in all elements
    closure.load = function() end
    return closure
end

return M