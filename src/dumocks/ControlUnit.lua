--- Control units come in various forms: cockpits, programming boards, emergency control units, etc. A control unit
-- stores a set of Lua scripts that can be used to control the elements that are plugged in on its CONTROL plugs.
-- Kinematics control units like cockpit or commander seats are also capable of controlling the ship's engines via the
-- update ICC method.
--
-- Element class:
-- <ul>
--   <li>Generic: Programming Board</li>
--   <li>RemoteControlUnit: Remote Controller</li>
--   <li>CockpitHovercraftUnit: Hovercraft Seat</li>
--   <li>CockpitFighterUnit: Cockpit</li>
--   <li>CockpitCommandmentUnit: Command Seat</li>
--   <li>PVPSeatUnit: Gunner Modules</li>
--   <li>ECU: Emergency Controller</li>
-- </ul>
--
-- Displayed widget fields for Generic, ECU, and PVPSeatUnit element classes:
-- <ul>
--   <li>showScriptError</li>
--   <li>elementId</li>
--   <li>controlMasterModeId</li>
-- </ul>
--
-- Additional widget fields for Cockpit and Remote classes:
-- <ul>
--   <li>showHasBrokenFuelTank</li>
--   <li>showOutOfFuel</li>
--   <li>showOverload</li>
--   <li>showSlowDown</li>
--   <li>speed</li>
--   <li>acceleration</li>
--   <li>airDensity</li>
--   <li>airResistance</li>
--   <li>atmoThrust</li>
--   <li>spaceThrust</li>
--   <li>controlData</li>
--   <li>currentBrake (not always shown)</li>
--   <li>maxBrake (not always shown)</li>
-- </ul>
--
-- Extends: @{Element}
-- @module ControlUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_GENERIC = "Generic"
local CLASS_PVP = "PVPSeatUnit"
local CLASS_REMOTE = "RemoteControlUnit"
local CLASS_ECU = "ECU"

local elementDefinitions = {}
elementDefinitions["programming board xs"] = {mass = 27.74, maxHitPoints = 50.0, itemId = 3415128439, class = CLASS_GENERIC}
elementDefinitions["remote controller xs"] = {mass = 7.79, maxHitPoints = 50.0, itemId = 1866437084, class = CLASS_REMOTE}
elementDefinitions["hovercraft seat controller s"] = {mass = 110.33, maxHitPoints = 187.0, itemId = 1744160618, class = "CockpitHovercraftUnit"}
elementDefinitions["cockpit m"] = {mass = 1208.13, maxHitPoints = 1125.0, itemId = 3640291983, class = "CockpitFighterUnit"}
elementDefinitions["command seat controller s"] = {mass = 3500.0, maxHitPoints = 250.0, itemId = 3655856020, class = "CockpitCommandmentUnit"}
elementDefinitions["gunner module s"] = {mass = 427.9, maxHitPoints = 250.0, itemId = 1373443625, class = CLASS_PVP}
elementDefinitions["gunner module m"] = {mass = 4250.0, maxHitPoints = 250.0, itemId = 564736657, class = CLASS_PVP}
elementDefinitions["gunner module l"] = {mass = 16000.0, maxHitPoints = 250.0, itemId = 3327293642, class = CLASS_PVP}
elementDefinitions["emergency controller xs"] = {mass = 9.35, maxHitPoints = 50.0, itemId = 286542481, class = CLASS_ECU}
local DEFAULT_ELEMENT = "programming board xs"

local M = MockElement:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class
    if o.elementClass == CLASS_GENERIC or o.elementClass == CLASS_PVP or o.elementClass == CLASS_ECU then
        o.widgetType = "basic_control_unit"
    else
        o.widgetType = "cockpit"
    end

    o.errorOnExit = false -- use to abort execution when exit is called
    o.exitCalled = false
    o.timers = {} -- map: "timer name"=>timerDurationSeconds
    o.tickCallbacks = {}
    o.remoteControlled = o.elementClass == CLASS_REMOTE
    o.planetInfluence = 1.0

    o.linkedElements = {}

    o.plugIn = 0.0

    return o
end

local GENERIC_DATA_TEMPLATE =
    '{"helperId":"%s","type":"%s","name":"%s","elementId":"%d","showScriptError":%s,"controlMasterModeId":%d'
local COCKPIT_DATA_TEMPLATE = ',"acceleration":%f,"airDensity":%f,"airResistance":%f,"atmoThrust":%f,' ..
                                 '"controlData":%s,"showHasInactiveFuelTank":%s,"showOutOfFuel":%s,"showOverload":%s,' ..
                                 '"showSlowDown":%s,"spaceThrust":%f,"speed":%f,"maxSpeed":%f,"speedEffects":%s'
local CONTROL_DATA_TEMPLATE = '{"axisData":[{"commandType":%d,"commandValue":%f,"speed":%f},' ..
                                '{"commandType":%d,"commandValue":%f,"speed":%f},' ..
                                '{"commandType":%d,"commandValue":%f,"speed":%f}],' ..
                                '"currentMasterMode":%d,"masterModeData":[{"name":""},{"name":""}]}'
local SPEED_EFFECTS_TEMPLATE = '{"boostCount":%d,"boostSpeedModifier":%f,"boostSpeedModifierRatio":%f,' ..
                                '"stasisCount":%d,"stasisSpeedModifier":%f,"stasisSpeedModifierRatio":%f,' ..
                                '"stasisTimeRemaining":%f}'
local PARENTING_DATA_TEMPLATE = ',"parentingInfo":{"autoParentingMode":%d,"closestConstructName":"%s","parentName":"%s",' ..
                                '"parentingState":%d}'
function M:getWidgetData()
    local formatString = GENERIC_DATA_TEMPLATE
    local controllerId = 123456789
    local type = self:getWidgetType()
    local showError = false
    local masterModeId = 0
    if self.elementClass == CLASS_GENERIC or self.elementClass == CLASS_PVP or self.elementClass == CLASS_ECU then
        formatString = formatString .. "}"
        return string.format(formatString, type, type, self.name, controllerId, showError, masterModeId)
    else
        formatString = formatString .. COCKPIT_DATA_TEMPLATE .. PARENTING_DATA_TEMPLATE .. "}"
        local speed = 0.0
        local maxSpeed = 0.0
        local acceleration = 0.0
        local airDensity = 0.0
        local airResistance = 0.0
        local atmoThrust = 0.0
        local spaceThrust = 0.0
        local controlData = "{}"
        local showHasInactiveFuelTank = false
        local showOutOfFuel = false
        local showOverload = false
        local showSlowDown = false
        local autoParentingMode = 0
        local closestConstructName = ""
        local parentName = ""
        local parentingState = 0

        controlData = string.format(CONTROL_DATA_TEMPLATE, 3, 0, 0, 3, 0, 0, 3, 0, 0, 0)
        local speedEffectsData = string.format(SPEED_EFFECTS_TEMPLATE, 0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0)
        return string.format(formatString, type, type, self.name, controllerId, showError, masterModeId, acceleration,
                    airDensity, airResistance, atmoThrust, controlData, showHasInactiveFuelTank, showOutOfFuel,
                    showOverload, showSlowDown, spaceThrust, speed, maxSpeed, speedEffectsData, autoParentingMode,
                    closestConstructName, parentName, parentingState)
    end
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Stops the control unit's Lua code and exits.
--
-- Warning: calling this might cause your ship to fall from the sky, use it with care. It is typically used in the
-- coding of emergency control unit scripts to stop control once the ECU thinks that the ship has safely landed.
function M:exit()
    if self.exitCalled then
        error("Exit called multiple times.")
    end
    self.exitCalled = true

    if self.errorOnExit then
        error("Exit called.")
    end
end

--- Set up a timer with a given tag in a given period. This will start to trigger the 'onTimer' event with the
-- corresponding tag as an argument, to help you identify what is ticking, and when.
-- @tparam string tag The tag of the timer, as a string, which will be used in the 'onTimer' event to identify this
-- particular timer.
-- @tparam second period The period of the timer, in seconds. The time resolution is limited by the framerate here, so
-- you cannot set arbitrarily fast timers.
function M:setTimer(tag, period)
    self.timers[tag] = period
end

--- Stop the timer with the given tag.
-- @tparam string tag The tag of the timer to stop, as a string.
function M:stopTimer(tag)
    self.timers[tag] = nil
end

--- Returns the ambient atmosphere density.
-- @treturn float The atmosphere density (between 0 and 1).
function M:getAtmosphereDensity()
end

--- Returns the influence rate of the closest planet.
-- @treturn float The closest planet influence rate (between 0 and 1).
function M:getClosestPlanetInfluence()
    return self.planetInfluence
end

--- <b>Deprecated:</b> Return the position of the player currently running the control unit, in construct local coordinates.
--
-- This method is deprecated: player.getPosition should be used instead
-- @see player.getPosition
-- @treturn vec3 Master player position in construct local coordinates.
function M:getMasterPlayerPosition()
    M.deprecated("getMasterPlayerPosition", "player.getPosition")
end

--- <b>Deprecated:</b> Return the position of the player currently running the control unit, in construct local coordinates.
--
-- This method is deprecated: player.getWorldPosition should be used instead
-- @see player.getWorldPosition
-- @treturn vec3 Master player position in world coordinates.
function M:getMasterPlayerWorldPosition()
    M.deprecated("getMasterPlayerWorldPosition", "player.getWorldPosition")
end

--- <b>Deprecated:</b> Returns the forward direction vector of the player currently running the control unit, in construct local coordinates.
--
-- This method is deprecated: player.getForward should be used instead
-- @see player.getForward
-- @treturn vec3 Master player forward direction vector in construct local coordinates.
function M:getMasterPlayerForward()
    M.deprecated("getMasterPlayerForward", "player.getForward")
end

--- <b>Deprecated:</b> Returns the up direction vector of the player currently running the control unit, in construct local coordinates.
--
-- This method is deprecated: player.getUp should be used instead
-- @see player.getUp
-- @treturn vec3 Master player up direction vector in construct local coordinates.
function M:getMasterPlayerUp()
    M.deprecated("getMasterPlayerUp", "player.getUp")
end

--- <b>Deprecated:</b> Returns the right direction vector of the player currently running the control unit, in construct local coordinates.
--
-- This method is deprecated: player.getRight should be used instead
-- @see player.getRight
-- @treturn vec3 Master player right direction vector in construct local coordinates.
function M:getMasterPlayerRight()
    M.deprecated("getMasterPlayerRight", "player.getRight")
end

--- <b>Deprecated:</b> Returns the forward direction vector of the player currently running the control unit, in world coordinates.
--
-- This method is deprecated: player.getWorldForward should be used instead
-- @see player.getWorldForward
-- @treturn vec3 Master player forward direction vector in world coordinates.
function M:getMasterPlayerWorldForward()
    M.deprecated("getMasterPlayerWorldForward", "player.getWorldForward")
end

--- <b>Deprecated:</b> Returns the up direction vector of the player currently running the control unit, in world coordinates.
--
-- This method is deprecated: player.getWorldUp should be used instead
-- @see player.getWorldUp
-- @treturn vec3 Master player up direction vector in world coordinates.
function M:getMasterPlayerWorldUp()
    M.deprecated("getMasterPlayerWorldUp", "player.getWorldUp")
end

--- <b>Deprecated:</b> Returns the right direction vector of the player currently running the control unit, in world coordinates.
--
-- This method is deprecated: player.getWorldRight should be used instead
-- @see player.getWorldRight
-- @treturn vec3 Master player right direction vector in world coordinates.
function M:getMasterPlayerWorldRight()
    M.deprecated("getMasterPlayerWorldRight", "player.getWorldRight")
end

--- <b>Deprecated:</b> Return the ID of the player currently running the control unit.
--
-- This method is deprecated: player.getId should be used instead
-- @see player.getId
-- @treturn int ID of the player running the control unit.
function M:getMasterPlayerId()
    M.deprecated("getMasterPlayerId", "player.getId")
end

--- <b>Deprecated:</b> Returns the list of organization IDs of the player running the control unit.
--
-- This method is deprecated: player.getOrgIds should be used instead
-- @see player.getOrgIds
-- @treturn list Organization IDs of the player running the control unit.
function M:getMasterPlayerOrgIds()
    M.deprecated("getMasterPlayerOrgIds", "player.getOrgIds")
end

--- <b>Deprecated:</b> Returns the mass of the active player.
--
-- This method is deprecated: player.getMass should be used instead
-- @see player.getMass
-- @treturn float The mass of the player in kilograms.
function M:getMasterPlayerMass()
    M.deprecated("getMasterPlayerMass", "player.getMass")
end

--- <b>Deprecated:</b> Returns the id of the construct on which the active player is boarded.
--
-- This method is deprecated: player.getParent should be used instead
-- @see player.getParent
-- @treturn int The parent id.
function M:getMasterPlayerParent()
    M.deprecated("getMasterPlayerParent", "player.getParent")
end

--- Checks if the control unit is protected by DRM.
-- @treturn 0/1 1 if the control unit is protected by DRM.
function M:hasDRM()
    return 0
end

--- Check if the construct is remote controlled.
-- @treturn 0/1 1 if the construct is remote controlled.
function M:isRemoteControlled()
    if self.remoteControlled then
        return 1
    end
    return 0
end

--- Automatically assign the engines within the taglist to result in the given acceleration and angular acceleration
-- provided. Can only be called within the system.onFlush event. If engines designated by the tags are not capable of
-- producing the desired command, setEngineCommand will try to do its best to approximate it.
--
-- Note: This function must be used on a piloting controller in @{system.EVENT_onFlush|system.onFlush} event.
-- @tparam string taglist Comma (for union) or space (for intersection) separated list of tags. You can set tags directly
-- on the engines in the right-click menu.
-- @tparam vec3 acceleration The desired acceleration expressed in world coordinates in m/s2.
-- @tparam vec3 angularAcceleration The desired angular acceleration expressed in world coordinates in rad/s2.
-- @tparam bool keepForceCollinearity Forces the resulting acceleration vector to be collinear to the acceleration
-- parameter.
-- @tparam bool keepTorqueCollinearity Forces the resulting angular acceleration vector to be collinear to the angular
-- acceleration parameter.
-- @tparam string priority1SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 1.
-- @tparam string priority2SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 2.
-- @tparam string priority3SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 3.
-- @tparam float toleranceRatioToStopCommand When going through with priorities, if we reach a command that is achieved
-- within this tolerance, we will stop there.
function M:setEngineCommand(taglist, acceleration, angularAcceleration, keepForceCollinearity, keepTorqueCollinearity,
    priority1SubTags, priority2SubTags, priority3SubTags, toleranceRatioToStopCommand)
end

--- Sets the thrust values for all engines in the tag list.
--
-- Note: This function must be used on a piloting controller.
-- @tparam string taglist Comma separated list of tags. You can set tags directly on the engines in the right-click menu.
-- @tparam float thrust The desired thrust in newtons (note that for boosters, any non zero value here will set them to
-- 100%).
function M:setEngineThrust(taglist, thrust)
end

--- Returns the total thrust values of all engines in the tag list.
--
-- Note: This function must be used on a piloting controller.
-- @tparam string taglist Comma separated list of tags. You can set tags directly on the engines in the right-click menu.
-- @treturn vec3 The total thrust in newtons.
function M:getEngineThrust(taglist)
end

--- Set the value of the throttle in the cockpit, which will be displayed in the cockpit widget when flying.
--
-- Note: This function must be used on a piloting controller.
-- @tparam int axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @tparam float commandValue In 'By Throttle', the value of the throttle position: -1 = full reverse, 1 = full
--   forward. Or in 'By Target Speed', the value of the target speed in km/h.
function M:setAxisCommandValue(axis, commandValue)
end

--- Get the value of the throttle in the cockpit.
--
-- Note: This function must be used on a piloting controller.
-- @tparam int axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @treturn float In travel mode, return the value of the throttle position: -1 = full reverse, 1 = full forward, or in
--   cruise mode, return the value of the target speed.
function M:getAxisCommandValue(axis)
end

--- Set the properties of an axis command. These properties will be used to display the command in UI.
--
-- Note: This function must be used on a piloting controller.
-- @tparam int axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @tparam int commandType By throttle = 0, by target speed = 1, hidden = 2.
-- @tparam list targetSpeedRanges This is to specify the cruise control target speed ranges (for now, only for the
-- longitudinal axis) in m/s.
function M:setupAxisCommandProperties(axis, commandType, targetSpeedRanges)
end

--- <b>Deprecated:</b> Set the display name of a master mode as shown in the UI.
--
-- This method is deprecated: setWidgetControlModeLabel should be used instead
-- @see setWidgetControlModeLabel
-- @tparam int controlMasterModeId The master mode, 0=Travel Mode, 1=Cruise Control.
-- @tparam string displayName The name of the master mode.
function M:setupControlMasterModeProperties(controlMasterModeId, displayName)
    M.deprecated("setupControlMasterModeProperties", "setWidgetControlModeLabel")
    return self:setWidgetControlModeLabel(controlMasterModeId, displayName)
end

---  <b>Deprecated:</b> Get the current master mode in use. The mode is set by clicking the UI button or using the
-- associated keybinding.
--
-- This method is deprecated: getControlMode should be used instead
-- @see getControlMode
-- @treturn int The current master mode (for now, only 2 are available, 0 and 1).
function M:getControlMasterModeId()
    M.deprecated("getControlMasterModeId", "getControlMode")
    return self:getControlMode()
end

--- Returns the current control mode. The mode is set by clicking the UI button or using the associated keybinding.
--
-- Note: This function must be used on a piloting controller.
-- @treturn int The current control mode (for now, only 2 are available, 0 and 1).
function M:getControlMode()
end

--- Cancel the current master mode in used.
--
-- Note: This function must be used on a piloting controller.
    function M:cancelCurrentControlMasterMode()
end

--- Check if a mouse control scheme is selected.
--
-- Note: This function must be used on a piloting controller.
-- @treturn 0/1 1 if a mouse control scheme is selected.
function M:isMouseControlActivated()
end

--- Check if the mouse control direct scheme is selected.
--
-- Note: This function must be used on a piloting controller.
-- @treturn 0/1 1 if a mouse control direct scheme is selected.
function M:isMouseDirectControlActivated()
end

--- Check if the mouse control virtual joystick scheme is selected.
--
-- Note: This function must be used on a piloting controller.
-- @treturn 0/1 1 if a mouse control virtual joystick scheme is selected.
function M:isMouseVirtualJoystickActivated()
end

--- The ground engines will stabilize to this altitude within their limits. THe stabilization will be done by adjusting
-- thrust to never go over the target altitude. This includes VerticalBooster and HoverEngine.
--
-- Note: This function must be used on a piloting controller.
-- @tparam float targetAltitude The stabilization target altitude in m.
function M:activateGroundEngineAltitudeStabilization(targetAltitude)
end

--- Return the ground engines stabilization altitude.
--
-- Note: This function must be used on a piloting controller.
-- @treturn float The stabilization altitude in meters or 0 if none is set.
function M:getSurfaceEngineAltitudeStabilization()
end

--- The ground engines will behave like regular engine. This includes VerticalBooster and HoverEngine.
--
-- Note: This function must be used on a piloting controller.
function M:deactivateGroundEngineAltitudeStabilization()
end

--- Returns ground engine stabilization altitude capabilities (lower and upper ranges).
--
-- Note: This function must be used on a piloting controller.
-- @treturn vec2 Stabilization altitude capabilities for the least powerful engine and the most powerful engine.
function M:computeGroundEngineAltitudeStabilizationCapabilities()
end

--- Return the current throttle value.
--
-- Note: This function must be used on a piloting controller.
-- @treturn float The throttle value between -100 and 100.
function M:getThrottle()
end

--- Set the label of a control mode button shown in the control unit widget.
--
-- Note: This function must be used on a piloting controller.
-- @tparam int modeId The control mode: 0 = Travel Mode, 1 = Cruise Control by default.
-- @tparam string label The display name of the control mode, displayed on the widget button.
function M:setWidgetControlModeLabel(modeId, label)
end

--- <b>Deprecated:</b> Check landing gear status.
--
-- This method is deprecated: isAnyLandingGearDeployed should be used instead
-- @see isAnyLandingGearDeployed
-- @treturn 0/1 1 if any landing gear is extended.
function M:isAnyLandingGearExtended()
    M.deprecated("isAnyLandingGearExtended", "isAnyLandingGearDeployed")
    return self:isAnyLandingGearDeployed()
end

--- Checks if any landing gear is deployed.
-- @treturn 0/1 1 if any landing gear is deployed.
function M:isAnyLandingGearDeployed()
end

--- <b>Deprecated:</b> Extend/activate/drop the landing gears.
--
-- This method is deprecated: deployLandingGear should be used instead
-- @see deployLandingGear
function M:extendLandingGears()
    M.deprecated("extendLandingGears", "deployLandingGear")
    return self:deployLandingGear()
end

--- Deploy all landing gears.
function M:deployLandingGear()
end

--- Retract all landing gears.
function M:retractLandingGears()
end

--- Check construct lights status.
-- @treturn 0/1 1 if any headlight is switched on.
function M:isAnyHeadlightSwitchedOn()
end

--- Turn on the construct's headlights.
function M:switchOnHeadlights()
end

--- Turn off the construct's headlights.
function M:switchOffHeadlights()
end

--- <b>Deprecated:</b> Checks if the player currently running the control unit is seated.
--
-- This method is deprecated: player.isSeated should be used instead
-- @see player.isSeated
-- @treturn 0/1 1 if the player is seated.
function M:isMasterPlayerSeated()
    M.deprecated("isMasterPlayerSeated", "player.isSeated")
    return 0
end

--- <b>Deprecated:</b> Returns the UID of the seat on which the player currently running the control unit is sitting.
--
-- This method is deprecated: player.getSeatId should be used instead
-- @see player.getSeatId
-- @treturn int The UID of the seat, or 0 if not seated.
function M:getMasterPlayerSeatId()
    M.deprecated("getMasterPlayerSeatId", "player.getSeatId")
    return 0
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
--
-- Note: Only defined for Programming Board and ECU.
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- <b>Deprecated:</b> Event: Emitted when the timer with id 'timerId' is ticking.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onTimer should be used instead.
-- @see EVENT_onTimer
-- @tparam string timerId The ID (int) of the timer that just ticked (see setTimer to set a timer with a given ID)
function M.EVENT_tick(timerId)
    M.deprecated("EVENT_tick", "EVENT_onTimer")
    M.EVENT_onTimer()
end

--- Event: Emitted when the timer with id 'tag' is ticking.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string tag The tag of the timer that just ticked (see setTimer to set a timer with a given tag).
-- @see setTimer
function M.EVENT_onTimer(tag)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Mock only, not in-game: Register a handler for the in-game `tick(timerId)` event.
-- @tparam function callback The function to call when the timer ticks.
-- @tparam string filter The timerId to filter on, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_tick
function M:mockRegisterTimer(callback, filter)
    filter = filter or "*"

    local index = #self.tickCallbacks + 1
    self.tickCallbacks[index] = {
        callback = callback,
        filter = filter
    }
    return index
end

--- Mock only, not in-game: Simulates a timer tick.
-- @tparam string timerId The ID of the timer that ticked.
function M:mockDoTick(timerId)
    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.tickCallbacks) do
        if callback.filter == "*" or callback.filter == timerId then
            local status, err = pcall(callback.callback, timerId)
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

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.exit = function() return self:exit() end
    closure.setTimer = function(timerTagId, period) return self:setTimer(timerTagId, period) end
    closure.stopTimer = function(timerTagId) return self:stopTimer(timerTagId) end
    closure.getAtmosphereDensity = function() return self:getAtmosphereDensity() end
    closure.getClosestPlanetInfluence = function() return self:getClosestPlanetInfluence() end
    closure.getMasterPlayerId = function() return self:getMasterPlayerId() end
    closure.getMasterPlayerOrgIds = function() return self:getMasterPlayerOrgIds() end
    closure.getMasterPlayerPosition = function() return self:getMasterPlayerPosition() end
    closure.getMasterPlayerWorldPosition = function() return self:getMasterPlayerWorldPosition() end
    closure.getMasterPlayerForward = function() return self:getMasterPlayerForward() end
    closure.getMasterPlayerUp = function() return self:getMasterPlayerUp() end
    closure.getMasterPlayerRight = function() return self:getMasterPlayerRight() end
    closure.getMasterPlayerWorldForward = function() return self:getMasterPlayerWorldForward() end
    closure.getMasterPlayerWorldUp = function() return self:getMasterPlayerWorldUp() end
    closure.getMasterPlayerWorldRight = function() return self:getMasterPlayerWorldRight() end
    closure.isMasterPlayerSeated = function() return self:isMasterPlayerSeated() end
    closure.getMasterPlayerSeatId = function() return self:getMasterPlayerSeatId() end
    closure.hasDRM = function() return self:hasDRM() end
    closure.isRemoteControlled = function() return self:isRemoteControlled() end

    if self.elementClass == CLASS_GENERIC or self.elementClass == CLASS_ECU then
        closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
        closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    end

    closure.setEngineCommand = function(
        taglist,
        acceleration,
        angularAcceleration,
        keepForceCollinearity,
        keepTorqueCollinearity,
        priority1SubTags,
        priority2SubTags,
        priority3SubTags,
        toleranceRatioToStopCommand)
        return self:setEngineCommand(
            taglist,
            acceleration,
            angularAcceleration,
            keepForceCollinearity,
            keepTorqueCollinearity,
            priority1SubTags,
            priority2SubTags,
            priority3SubTags,
            toleranceRatioToStopCommand
        )
    end
    closure.setEngineThrust = function(tagList, thrust) return self:setEngineThrust(tagList, thrust) end
    closure.getEngineThrust = function(tagList) return self:getEngineThrust(tagList) end
    closure.setAxisCommandValue = function(axis, commandValue) return self:setAxisCommandValue(axis, commandValue) end
    closure.getAxisCommandValue = function(axis) return self:getAxisCommandValue(axis) end
    closure.setupAxisCommandProperties = function(axis, commandType) return self:setupAxisCommandProperties(axis, commandType) end
    closure.setupControlMasterModeProperties = function(controlMasterModeId, displayName) return self:setupControlMasterModeProperties(controlMasterModeId, displayName) end
    closure.getControlMasterModeId = function() return self:getControlMasterModeId() end
    closure.getControlMode = function() return self:getControlMode() end
    closure.cancelCurrentControlMasterMode = function() return self:cancelCurrentControlMasterMode() end
    closure.isMouseControlActivated = function() return self:isMouseControlActivated() end
    closure.isMouseDirectControlActivated = function() return self:isMouseDirectControlActivated() end
    closure.isMouseVirtualJoystickActivated = function() return self:isMouseVirtualJoystickActivated() end
    closure.switchOnHeadlights = function() return self:switchOnHeadlights() end
    closure.switchOffHeadlights = function() return self:switchOffHeadlights() end
    closure.activateGroundEngineAltitudeStabilization = function(targetAltitude) return self:activateGroundEngineAltitudeStabilization(targetAltitude) end
    closure.getSurfaceEngineAltitudeStabilization = function() return self:getSurfaceEngineAltitudeStabilization() end
    closure.deactivateGroundEngineAltitudeStabilization = function() return self:deactivateGroundEngineAltitudeStabilization() end
    closure.computeGroundEngineAltitudeStabilizationCapabilities = function() return self:computeGroundEngineAltitudeStabilizationCapabilities() end
    closure.getThrottle = function() return self:getThrottle() end
    closure.setWidgetControlModeLabel = function(modeId, label) return self:setWidgetControlModeLabel(modeId, label) end
    closure.isAnyLandingGearExtended = function() return self:isAnyLandingGearExtended() end
    closure.isAnyLandingGearDeployed = function() return self:isAnyLandingGearDeployed() end
    closure.extendLandingGears = function() return self:extendLandingGears() end
    closure.deployLandingGears = function() return self:deployLandingGears() end
    closure.retractLandingGears = function() return self:retractLandingGears() end
    closure.isAnyHeadlightSwitchedOn = function() return self:isAnyHeadlightSwitchedOn() end
    closure.getMasterPlayerMass = function() return self:getMasterPlayerMass() end
    closure.getMasterPlayerParent = function() return self:getMasterPlayerParent() end

    -- add in fields to match the game

    -- all exported methods (everything above)
    local export = {}
    for k, v in pairs(closure) do
        export[k] = v
    end
    closure.export = export
    closure.unit = closure

    -- all linked elements by name
    for name, element in pairs(self.linkedElements) do
        closure[name] = element
    end

    return closure
end

return M
