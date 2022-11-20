--- System is a virtual element that represents your computer. It gives access to events like key strokes or mouse
-- movements that can be used inside your scripts. It also gives you access to regular updates that can be used to pace
-- the execution of your script.
-- @module system
-- @alias M

-- local posix = require "posix" -- for more precise clock

-- define class fields
local M = {}

--- Action names, as used by event filters.
--
-- Note: These are names shown in the event filter list, grouping them in a table is purely for documentation purposes.
-- @table Action
M.Action = {
    "forward",
    "backward",
    "yawleft",
    "yawright",
    "strafeleft",
    "straferight",
    "left",
    "right",
    "up",
    "down",
    "groundaltitudeup",
    "groundaltitudedown",
    "lalt",
    "lshift",
    "gear",
    "light",
    "brake",
    "option1",
    "option2",
    "option3",
    "option4",
    "option5",
    "option6",
    "option7",
    "option8",
    "option9",
    "leftmouse",
    "stopengines",
    "speedup",
    "speeddown",
    "antigravity",
    "booster",
}

function M:new(o)
    -- define default instance fields
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.widgetPanels = {} -- id (format: "p#") => {ordered list of widgets}
    o.widgets = {} -- id (format: "w#") => current data ids
    o.widgetData = {} -- id (format: "d#") => json

    o.lockView = false

    o.screenHeight = 1080
    o.screenWidth = 1920
    o.cameraHorizontalFov = 90
    o.cameraVerticalFov = 59

    o.locale = "en-US"

    return o
end

--- Return the currently key bound to the given action. Useful to display tips.
-- @tparam string actionName The action name, represented as a string taken among the set of predefined Lua-available
--   actions (you can check the dropdown of an event list to see what is available).
-- @treturn string The key associated to the given action name.
-- @see Action
function M:getActionKeyName(actionName)
end

--- Control the display of the control unit custom screen, where you can define customized display information in HTML.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam 0/1 bool 1 show the screen, 0 hide the screen.
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
-- @treturn 0/1 1 on success, 0 on failure
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
--   <li><span class="parameter">@{AntiGravityGeneratorUnit:getWidgetData|antigravity_generator}</span> The widget
--     created by anti-gravity generators.</li>
--   <li><span class="parameter">@{ContainerUnit:getWidgetData|fuel_container}</span> The widget created by fuel tanks.
--     </li>
--   <li><span class="parameter">@{CoreUnit:getWidgetData|core}</span> The widget created by core units.</li>
--   <li><span class="parameter">core_stress</span> Shows a meter indicating the current level of core stress and if
--       damage is being taken. Data is supported by @{CoreUnit:getWidgetData}.
--     <ul>
--       <li><span class="parameter">currentStress</span> (<span class="type">float</span>) Current core stress.</li>
--       <li><span class="parameter">maxStress</span> (<span class="type">float</span>) Max core stress.</li>
--     </ul>
--   </li>
--   <li><span class="parameter">@{Engine:getWidgetData|engine_unit}</span> The widget created by engines.</li>
--   <li><span class="parameter">@{GyroUnit:getWidgetData|gyro}</span> The widget created by gyroscopes.</li>
--   <li><span class="parameter">@{ShieldGeneratorUnit:getWidgetData|shield_generator}</span> The widget created by
--     shield generators.</li>
--   <li><span class="parameter">@{WarpDriveUnit:getWidgetData|warpdrive}</span> The widget created by warp drives.
--     </li>
--   <li><span class="parameter">@{WeaponUnit:getWidgetData|weapon}</span> The widget created by weapons.</li>
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
-- @treturn 0/1 1 on success, 0 on failure.
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
-- @treturn 0/1 1 on success, 0 on failure.
function M:destroyData(dataId)
end

--- Update JSON associated to data. The string passed in must be valid JSON. See @{createWidget} for links to the
-- format expected for the different widget types.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @tparam string dataJson The data fields as JSON.
-- @treturn 0/1 1 on success, 0 on failure.
-- @see createData
function M:updateData(dataId, dataJson)
end

--- Add data to widget.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID. May be a reference returned by @{createData} or the value returned by
--   @{Element:getDataId} to tie the widget to an element.
-- @tparam string widgetId The widget ID.
-- @treturn 0/1 1 on success, 0 on failure.
function M:addDataToWidget(dataId, widgetId)
end

--- Remove data from widget.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
-- @tparam string dataId The data ID.
-- @tparam string widgetId The widget ID.
-- @treturn 0/1 1 on success, 0 on failure.
function M:removeDataFromWidget(dataId, widgetId)
end

--- Return the current value of the mouse wheel.
-- @treturn float The current value of the mouse wheel.
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

--- Return the value of the mouse sensitivity game setting.
-- @treturn float Sensitivity setting value.
function M:getMouseSensitivity()
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

--- <b>Deprecated:</b> Return the current value of the player field of view.
--
-- This method is deprecated: getCameraHorizontalFov should be used instead
-- @see getCameraHorizontalFov
-- @treturn float The current value of the player field of view.
function M:getFov()
    M.deprecated("getFov", "getCameraHorizontalFov")
    return self:getCameraHorizontalFov()
end

--- Return the current value of the player's horizontal field of view.
-- @treturn float The current value of the player's horizontal field of view.
function M:getCameraHorizontalFov()
    return self.cameraHorizontalFov
end

--- Return the current value of the player's vertical field of view.
-- @treturn float The current value of the playter's vertical field of view.
function M:getCameraVerticalFov()
    return self.cameraVerticalFov
end

--- Returns the active camera mode.
-- @treturn 1/2/3 1: First Person View, 2: Look Around Construct View, 3: Follow Construct View.
function M:getCameraMode()
    return 1
end

--- Checks if the active camera is in first person view.
-- @treturn 0/1 1 if the camera is in first person view.
function M:isFirstPerson()
    return 1
end

--- Returns the position of the camera, in construct local coordinates.
-- @treturn vec3 Camera position in construct local coordinates.
function M:getCameraPos()
end

--- Returns the position of the camera, in world coordinates.
-- @treturn vec3 Camera position in world coordinates.
function M:getCameraWorldPos()
end

--- Returns the forward direction vector of the active camera, in world coordinates.
-- @treturn vec3 Camera forward direction vector in world coordinates.
function M:getCameraWorldForward()
end

--- Returns the right direction vector of the active camera, in world coordinates.
-- @treturn vec3 Camera right direction vector in world coordinates.
function M:getCameraWorldRight()
end

--- Returns the up direction vector of the active camera, in world coordinates.
-- @treturn vec3 Camera up direction vector in world coordinates.
function M:getCameraWorldUp()
end

--- Returns the forward direction vector of the active camera, in construct local coordinates.
-- @treturn vec3 Camera forward direction vector in construct local coordinates.
function M:getCameraForward()
end

--- Returns the right direction vector of the active camera, in construct local coordinates.
-- @treturn vec3 Camera right direction vector in construct local coordinates.
function M:getCameraRight()
end

--- Returns the up direction vector of the active camera, in construct local coordinates.
-- @treturn vec3 Camera up direction vector in construct local coordinates.
function M:getCameraUp()
end

--- Return the current value of the mouse wheel (for the throttle speedUp/speedDown action).
-- @treturn float The current input.
function M:getThrottleInputFromMouseWheel()
end

--- Return the mouse input for the ship control action (forward/backward).
-- @treturn float The current input.
function M:getControlDeviceForwardInput()
end

--- Return the mouse input for the ship control action (yaw right/left).
-- @treturn float The current input.
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
-- @tparam 0/1 state 1 to lock and 0 to unlock.
function M:lockView(state)
    self.lockView = state == 1
end

--- Return the lock state of the mouse free look.
-- @treturn 0/1 1 when locked and 0 when unlocked.
function M:isViewLocked()
    if self.lockView then
        return 1
    end
    return 0
end

--- <b>Deprecated:</b> Freezes the character, liberating the associated movement keys to be used by the script.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the control unit,
-- vs. via a plug signal).
--
-- This method is deprecated: player.freeze should be used instead.
-- @see player.freeze
-- @tparam boolean bool 1 freeze the character, 0 unfreeze the character.
function M:freeze(bool)
    M.deprecated("freeze", "player.freeze")
end

--- <b>Deprecated:</b> Return the frozen status of the character (see 'freeze').
--
-- This method is deprecated: player.isFrozen should be used instead.
-- @see player.isFrozen
-- @treturn boolean 1 if the character is frozen, 0 otherwise
function M:isFrozen()
    M.deprecated("isFrozen", "player.isFrozen")
    return 0
end

--- <b>Deprecated:</b> Return the current time since the arrival of the Arkship.
--
-- This method is deprecated: getArkTime should be used instead.
-- @see getArkTime
-- @treturn second The current time in seconds, with a microsecond precision.
function M:getTime()
    M.deprecated("getTime", "getArkTime")
    return self:getArkTime();
end

--- Return the current time since the arrival of the Arkship on September 30th, 2017.
-- @treturn float Time in seconds.
function M:getArkTime()
end

--- Return the current time since the January 1st, 1970.
-- @treturn float Time in seconds.
function M:getUtcTime()
end

--- Return the time offset between local timezone and UTC.
-- @treturn float Time in seconds.
function M:getUtcOffset()
end

--- Return the locale in which the game is currently running.
-- @treturn string The locale, currently one of "en-US", "fr-FR", or "de-DE"
function M:getLocale()
    return self.locale
end

--- Return delta time of action updates (to use in ActionLoop).
-- @treturn float The delta time in seconds.
function M:getActionUpdateDeltaTime()
end

--- Return the name of the given player, if in range of visibility or broadcasted by a transponder.
-- @tparam int id The ID of the player.
-- @treturn string The name of the player.
function M:getPlayerName(id)
end

--- Return the world position of the given player, if in range of visibility.
-- @tparam int id The ID of the player.
-- @treturn string The coordinates of the player in world coordinates.
function M:getPlayerWorldPos(id)
end

--- Return the item table corresponding to the given item ID.
-- @tparam int id The ID of the item.
-- @treturn table An object table with fields: {[integer] id, [string] name, [string] displayName,
--   [string] locDisplayName, [string] displayNameWithSize, [string] locDisplayNameWithSize, [string] description,
--   [string] locDescription, [string] type, [number] unitMass, [number] unitVolume, [integer] tier, [string] scale,
--   [string] iconPath, [table] schematics, [table] products: {{[integer] id, [number] quantity}...}}.
function M:getItem(id)
end

--- <b>Deprecated:</b> Retrieves schematic details for the id provided as json.
--
-- This method is deprecated: getRecipes should be used instead.
-- @see getRecipes
-- @tparam int schematicId The id of the schematic to query, example: 1199082577 for Pure Aluminium refining.
-- @treturn jsonstr The schematic defails as a json object with fields: id, time, level, ingredients, products; where
-- ingredients and products are lists of json objects with fields: name, quantity, type
function M:getSchematic(schematicId)
    M.deprecated("getSchematic", "getRecipes")
    M:getRecipes(schematicId)
end

--- Returns a list of recipes producing the given item from its ID.
-- @tparam int id The ID of the item.
-- @treturn table A list of recipe table with field: {[integer] id, [integer] tier, [number] time,
--   [bool] nanocraftable, [table] products:{{[integer] id, [number] quantity},...}, 
--   [table] ingredients:{{[integer] id, [number] quantity},...}}.
function M:getRecipes(id)
end

--- <b>Deprecated:</b> Returns the name of the given organization, if known, e.g. broadcasted by a transponder.
--
-- This method is deprecated: getOrganization should be used instead.
-- @see getOrganization
-- @tparam int id The ID of the organization.
-- @treturn string The name of the organization.
function M:getOrganizationName(id)
    M.deprecated("getOrganizationName", "getOrganization")
    return self:getOrganization(id).name
end

--- <b>Deprecated:</b> Returns the tag of the given organization, if known, e.g. broadcasted by a transponder.
--
-- This method is deprecated: getOrganization should be used instead.
-- @see getOrganization
-- @tparam int id The ID of the organization.
-- @treturn string The tag of the organization.
function M:getOrganizationTag(id)
    M.deprecated("getOrganizationTag", "getOrganization")
    return self:getOrganization(id).tag
end

--- Returns the corresponding organization to the given organization ID, if known, e.g. broadcasted by a transponder.
-- @tparam int id The ID of the organization.
-- @treturn table A table containing information about the given organization {[string] name, [string] tag}
function M:getOrganization(id)
end

--- Return the player world position as a waypoint string, starting with '::pos'.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the Control Unit,
-- vs. via a plug signal).
-- @treturn string The waypoint as a string.
function M:getWaypointFromPlayerPos()
end

--- Set a waypoint at the destination described by the waypoint string, of the form '::pos'.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the Control Unit,
-- vs. via a plug signal).
-- @tparam string waypointStr The waypoint as a string.
-- @tparam boolean notify (Optional) True to display a notification on waypoint change.
function M:setWaypoint(waypointStr, notify)
end

--- Clear the active destination waypoint.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the Control Unit,
-- vs. via a plug signal).
-- @tparam boolean notify (Optional) True to display a notification about the waypoint's clearing.
function M:clearWaypoint(notify)
end

--- Print the given message in the Lua chat channel.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the Control Unit,
-- vs. via a plug signal).
-- @tparam string msg The message to print.
function M:print(msg)
    print(msg)
end

--- Set the visibility of the helper top menu.
--
-- Note: This function is disabled if the player is not running the script explicitly (pressing F on the Control Unit,
-- vs. via a plug signal).
-- @tparam 0/1 show 1 show the top helper menu, 0 hide the top helper menu.
function M:showHelper(show)
end

--- Play a sound file from your user folder (located in "My documents/NQ/DualUniverse/audio"). Only one sound at a
-- time.
-- @tparam string filePath Relative path to user data folder (.mp3, .wav).
function M:playSound(filePath)
end

--- Check if a sound is playing.
-- @treturn 0/1 1 if a sound is playing.
function M:isPlayingSound()
end

--- Stop the current playing sound.
function M:stopSound()
end

--- <b>Deprecated:</b> Log functionality removed in r0.28.0.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logInfo(msg)
    M.deprecated("logInfo")
end

--- <b>Deprecated:</b> Log functionality removed in r0.28.0.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logWarning(msg)
    M.deprecated("logWarning")
end

--- <b>Deprecated:</b> Log functionality removed in r0.28.0.
--
-- Note: This method is not documented in the codex.
-- @tparam string msg The message to print.
function M:logError(msg)
    M.deprecated("logError")
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

--- <b>Deprecated:</b> Event: Emitted when an action starts.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onActionStart should be used instead.
-- @see EVENT_onActionStart
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionStart(action)
    M.deprecated("EVENT_actionStart", "EVENT_onActionStart")
    M.EVENT_onActionStart(action)
end

--- Event: Emitted when an action starts.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
-- @see Action
function M.EVENT_onActionStart(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Emitted when an action stops.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onActionStop should be used instead.
-- @see EVENT_onActionStop
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionStop(action)
    M.deprecated("EVENT_actionStop", "EVENT_onActionStop")
    M.EVENT_onActionStop(action)
end

--- Event: Emitted when an action stops.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
-- @see Action
function M.EVENT_onActionStop(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Emitted at each update as long as the action is maintained.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onActionLoop should be used instead.
-- @see EVENT_onActionLoop
-- @tparam LUA_action action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
function M.EVENT_actionLoop(action)
    M.deprecated("EVENT_actionLoop", "EVENT_onActionLoop")
    M.EVENT_onActionLoop(action)
end

--- Event: Emitted at each update as long as the action is maintained.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string action The action, represented as a string taken among the set of predefined Lua-available actions
-- (you can check the drop down list to see what is available).
-- @see Action
function M.EVENT_onActionLoop(action)
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Game update event. This is equivalent to a timer set at 0 seconds, as updates will go as
-- fast as the FPS can go.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onUpdate should be used instead.
-- @see EVENT_onUpdate
function M.EVENT_update()
    M.deprecated("EVENT_update", "EVENT_onUpdate")
    M.EVENT_onUpdate()
end

--- Event: Game update event. This is equivalent to a timer set at 0 seconds, as updates will go as fast as the FPS can
-- go.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onUpdate()
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Physics update. Do not use to put anything else by a call to updateICC on your control
-- unit, as many functions are disabled when called from 'flush'. This is only to update the physics (engine control,
-- etc), not to setup some gameplay code.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onFlush should be used instead.
-- @see EVENT_onFlush
function M.EVENT_flush()
    M.deprecated("EVENT_flush", "EVENT_onFlush")
    M.EVENT_onFlush()
end

--- Event: Physics update. Do not use to put anything else by a call to updateICC on your control unit, as many
-- functions are disabled when called from 'onFlush'. This is only to update the physics (engine control, etc), not to
-- setup some gameplay code.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onFlush()
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Console input event.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onInputText should be used instead.
-- @see EVENT_onInputText
-- @tparam string text The message entered.
function M.EVENT_inputText(text)
    M.deprecated("EVENT_inputText", "EVENT_onInputText")
    M.EVENT_onInputText(text)
end

--- Event: A new message has been entered in the Lua tab of the chat, acting like a command line interface.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string text The message entered.
function M.EVENT_onInputText(text)
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Emitted when the player changes the camera mode.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onCameraChanged should be used instead.
-- @see EVENT_onCameraChanged
-- @tparam 1/2/3 mode The camera mode, represented by an integer (1: First Person View, 2: Look Around Construct View, 3:
--   Follow Construct View).
function M.EVENT_cameraChanged(mode)
    M.deprecated("EVENT_cameraChanged", "EVENT_onCameraChanged")
    M.EVENT_onCameraChanged(mode)
end

--- Event: Emitted when the player changes the camera mode.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int mode The camera mode, represented by an integer (First Person View = 1, Look Around Construct View = 2,
--   Follow Construct View = 3).
function M.EVENT_onCameraChanged(mode)
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
    closure.getMouseSensitivity = function() return self:getMouseSensitivity() end
    closure.getScreenHeight = function() return self:getScreenHeight() end
    closure.getScreenWidth = function() return self:getScreenWidth() end
    closure.getFov = function() return self:getFov() end
    closure.getCameraHorizontalFov = function() return self:getCameraHorizontalFov() end
    closure.getCameraVerticalFov = function() return self:getCameraVerticalFov() end
    closure.getCameraMode = function() return self:getCameraMode() end
    closure.isFirstPerson = function() return self:isFirstPerson() end
    closure.getCameraPos = function() return self:getCameraPos() end
    closure.getCameraWorldPos = function() return self:getCameraWorldPos() end
    closure.getCameraWorldForward = function() return self:getCameraWorldForward() end
    closure.getCameraWorldRight = function() return self:getCameraWorldRight() end
    closure.getCameraWorldUp = function() return self:getCameraWorldUp() end
    closure.getCameraForward = function() return self:getCameraForward() end
    closure.getCameraRight = function() return self:getCameraRight() end
    closure.getCameraUp = function() return self:getCameraUp() end
    closure.getThrottleInputFromMouseWheel = function() return self:getThrottleInputFromMouseWheel() end
    closure.getControlDeviceForwardInput = function() return self:getControlDeviceForwardInput() end
    closure.getControlDeviceYawInput = function() return self:getControlDeviceYawInput() end
    closure.getControlDeviceLeftRightInput = function() return self:getControlDeviceLeftRightInput() end
    closure.lockView = function(state) return self:lockView(state) end
    closure.isViewLocked = function() return self:isViewLocked() end
    closure.freeze = function(bool) return self:freeze(bool) end
    closure.isFrozen = function() return self:isFrozen() end
    closure.getTime = function() return self:getTime() end
    closure.getArkTime = function() return self:getArkTime() end
    closure.getUtcTime = function() return self:getUtcTime() end
    closure.getUtcOffset = function() return self:getUtcOffset() end
    closure.getLocale = function() return self:getLocale() end
    closure.getActionUpdateDeltaTime = function() return self:getActionUpdateDeltaTime() end
    closure.getPlayerName = function(id) return self:getPlayerName(id) end
    closure.getPlayerWorldPos = function(id) return self:getPlayerWorldPos(id) end
    closure.getItem = function(id) return self:getItem(id) end
    closure.getSchematic = function(id) return self:getSchematic(id) end
    closure.getRecipes = function(id) return self:getRecipes(id) end
    closure.getOrganization = function(id) return self:getOrganization(id) end
    closure.getOrganizationName = function(id) return self:getOrganizationName(id) end
    closure.getOrganizationTag = function(id) return self:getOrganizationTag(id) end
    closure.getWaypointFromPlayerPos = function() return self:getWaypointFromPlayerPos() end
    closure.setWaypoint = function(waypoint) return self:setWaypoint(waypoint) end
    closure.clearWaypoint = function() return self:clearWaypoint() end
    closure.print = function(msg) return self:print(msg) end
    closure.showHelper = function(show) return self:showHelper(show) end
    closure.playSound = function(filePath) return self:playSound(filePath) end
    closure.isPlayingSound = function() return self:isPlayingSound() end
    closure.stopSound = function() return self:stopSound() end

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