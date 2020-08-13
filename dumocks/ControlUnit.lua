--- Control units come in various forms: cockpits, programming boards, emergency control units, etc. A control unit
-- stores a set of Lua scripts that can be used to control the elements that are plugged in on its CONTROL plugs.
-- Kinematics control units like cockpit or commander seats are also capable of controlling the ship's engines via the
-- update ICC method.
-- @module ControlUnit
-- @alias M

local MockElement = require "dumocks.Element"

local controlDefinitions = {
    programmingBoard = {
        mass = 27.74,
        maxHitPoints = 50.0
    },
    hovercraftSeat = {
        mass = 110.33,
        maxHitPoints = 187.0
    }
}

local M = MockElement:new()
M.elementClass = "Generic"

function M:new(o, id)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    o.errorOnExit = false -- use to abort execution when exit is called
    o.exitCalled = false
    o.timers = {} -- map: "timer name"=>timerDurationSeconds

    return o
end

--- Stops the control unit's Lua code and exits. Warning: calling this might cause your ship to fall from the sky, use
-- it with care. It is typically used in the coding of emergency control unit scripts to stop control once the ECU
-- thinks that the ship has safely landed.
function M:exit()
    if self.exitCalled then
        error("Exit called multiple times.")
    end
    self.exitCalled = true

    if self.errorOnExit then
        error("Exit called.")
    end
end

--- Set up a timer with a given tag ID in a given period. This will start to trigger the 'tick' event with the
-- corresponding ID as an argument, to help you identify what is ticking, and when.
-- @tparam string timerTagId The ID of the timer, as a string, which will be used in the 'tick' event to identify this
-- particular timer.
-- @tparam second period The period of the timer, in seconds. The time resolution is limited by the framerate here, so
-- you cannot set arbitrarily fast timers.
function M:setTimer(timerTagId, period)
    -- TODO what happens if period is negative?
    self.timers[timerTagId] = period
end

--- Stop the timer with the given ID.
-- @tparam string timerTagId The ID of the timer to stop, as a string.
function M:stopTimer(timerTagId)
    self.timers[timerTagId] = nil
end

--- Returns the local atmosphere density, between 0 and 1.
-- @treturn 0..1 The atmosphere density (0 = in space).
function M:getAtmosphereDensity()
end

--- Returns the closest planet influence, between 0 and 1.
-- @treturn 0..1 The closest planet influence. 0 = in space, 1 = on the ground.
function M:getClosestPlanetInfluence()
end

--- Return the relative position (in world coordinates) of the player currently running the control unit.
-- @treturn vec3 Relative position in world coordinates.
function M:getMasterPlayerRelativePosition()
end

--- Return the ID of the player currently running the control unit.
-- @treturn int ID of the player running the control unit.
function M:getMasterPlayerId()
end

--- Automatically assign the engines within the taglist to result in the given acceleration and angular acceleration
-- provided. Can only be called within the system.flush event. If engines designated by the tags are not capable of
-- producing the desired command, setEngineCommand will try to do its best to approximate it.
-- @tparam csv taglist Comma (for union) or space (for intersection) separated list of tags. You can set tags directly
-- on the engines in the right-click menu.
-- @tparam m/s2 acceleration The desired acceleration expressed in world coordinates.
-- @tparam rad/s2 angularAcceleration The desired angular acceleration expressed in world coordinates.
-- @tparam bool keepForceCollinearity Forces the resulting acceleration vector to be collinear to the acceleration
-- parameter.
-- @tparam bool keepTorqueCollinearity Forces the resulting angular acceleration vector to be collinear to the angular
-- acceleration parameter.
-- @tparam priority1SubTag priority1SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 1.
-- @tparam priority2SubTag priority2SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 2.
-- @tparam priority3SubTag priority3SubTags Comma (for union) or space (for intersection) separated list of tags of
-- included engines to use as priority 3.
-- @tparam 0,1 toleranceRatioToStopCommand When going through with priorities, if we reach a command that is achieved
-- within this tolerance, we will stop there.
function M:setEngineCommand(
    taglist,
    acceleration,
    angularAcceleration,
    keepForceCollinearity,
    keepTorqueCollinearity,
    priority1SubTags,
    priority2SubTags,
    priority3SubTags,
    toleranceRatioToStopCommand)
end

--- Force the thrust values for all the engines within the tag list.
-- @tparam csv taglist Comma separated list of tags. You can set tags directly on the engines in the right-click menu.
-- @tparam N thrust The desired thrust in newtons (note that for boosters, any non zero value here will set them to
-- 100%).
function M:setEngineThrust(taglist, thrust)
end

--- Set the value of the throttle in the cockpit, which will be displayed in the cockpit widget when flying.
-- @tparam 0,1,2 axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @tparam -1..1 commandValue In 'by throttle', the value of the throttle position: -1 = full reverse, 1 = full forward.
-- Or In 'By Target Speed', the value of the target speed in km/h.
function M:setAxisCommandValue(axis, commandValue)
end

--- Get the value of the throttl in the cockpit.
-- @tparam 0,1,2 axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @treturn -1..1/float In travel mode, return the value of the throttle position: -1 = full reverse, 1 = full
-- forward, or in cruise mode, return the value of the target speed.
function M:getAxisCommandValue(axis)
end

--- Set the properties of an axis command. These properties will be used to display the command in UI.
-- @tparam 0,1,2 axis Longitudinal = 0, lateral = 1, vertical = 2.
-- @tparam 0,1 commandType By throttle = 0, by target speed = 1, hidden = 2.
-- @tparam list targetSpeedRanges This is to specify the cruise control target speed ranges (for now, only for the
-- longitudinal axis).
function M:setupAxisCommandProperties(axis, commandType, targetSpeedRanges)
end

--- Get the current master mode in use. The mode is set by clicking the UI button or using the associated keybinding.
-- @treturn int The current master mode (for now, only 2 are available, 0 and 1).
function M:getControlMasterModeId()
end

--- Cancel the current master mode in used.
function M:cancelCurrentControlMasterMode()
end

--- Check landing gear status.
-- @treturn 0/1 1 if any landing gear is extended.
function M:isAnyLandingGearExtended()
end

--- Extend/activate/drop the landing gears.
function M:extendLandingGears()
end

--- Retract/deactivate the landing gears.
function M:retractLandingGears()
end

--- Check if a mouse control scheme is selected.
-- @treturn 0/1 1 if a mouse control scheme is selected.
function M:isMouseControlActivated()
end

--- Check if the mouse control direct scheme is selected.
-- @treturn 0/1 1 if a mouse control direct scheme is selected.
function M:isMouseDirectControlActivated()
end

--- Check if the mouse control virtual joystick scheme is selected.
-- @treturn 0/1 1 if a mouse control virtual joystick scheme is selected.
function M:isMouseVirtualJoystickActivated()
end

--- Check lights status.
-- @treturn 0/1 1 if any headlight is switched on.
function M:isAnyHeadlightSwitchedOn()
end

--- switchOn the lights.
function M:switchOnHeadlights()
end

--- switchOff the lights.
function M:switchOffHeadlights()
end

--- Check if the construct is remote controlled.
-- @treturn 0/1 1 if the construct is remote controlled.
function M:isRemoteControlled()
end

--- The ground engines will stabilize to this altitude within their limits. THe stabilization will be done by adjusting
-- thrust to never go over the target altitude. This includes VerticalBooster and HoverEngine.
function M:activateGroundEngineAltitudeStabilization(targetAltitude)
end

--- Return the ground engines stabilization altitude.
-- @treturn float The stab altitude (m) or 0 if none is set.
function M:getSurfaceEngineAltitudeStabilization()
end

--- THe ground engines will behave like regular engine. This includes VerticalBooster and HoverEngine.
function M:deactivateGroundEngineAltitudeStabilization()
end

--- Returns ground engine stabilization altitude capabilities (lower and upper ranges).
-- @treturn vec2 Stabilization altitude capabilities for the least powerful engine and the most powerful engine.
function M:computeGroundEngineAltitudeStabilizationCapabilities()
end

--- Return the current throttle value.
-- @treturn float The throttle value between -100 and 100.
function M:getThrottle()
end

--- Event: Emitted when the timer with id 'timerId' is ticking.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @param timerId The ID (int) of the timer that just ticked (see setTimer to set a timer with a given ID)
function M.EVENT_tick(timerId)
    assert(false, "This is implemented for documentation purposes only.")
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
    closure.getMasterPlayerRelativePosition = function() return self:getMasterPlayerRelativePosition() end
    closure.getMasterPlayerId = function() return self:getMasterPlayerId() end
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
    closure.setAxisCommandValue = function(axis, commandValue) return self:setAxisCommandValue(axis, commandValue) end
    closure.getAxisCommandValue = function(axis) return self:getAxisCommandValue(axis) end
    closure.setupAxisCommandProperties = function(axis, commandType)
        return self:setupAxisCommandProperties(axis, commandType)
    end
    closure.getControlMasterModeId = function() return self:getControlMasterModeId() end
    closure.cancelCurrentControlMasterMode = function() return self:cancelCurrentControlMasterMode() end
    closure.isAnyLandingGearExtended = function() return self:isAnyLandingGearExtended() end
    closure.extendLandingGears = function() return self:extendLandingGears() end
    closure.retractLandingGears = function() return self:retractLandingGears() end
    closure.isMouseControlActivated = function() return self:isMouseControlActivated() end
    closure.isMouseDirectControlActivated = function() return self:isMouseDirectControlActivated() end
    closure.isMouseVirtualJoystickActivated = function() return self:isMouseVirtualJoystickActivated() end
    closure.isAnyHeadlightSwitchedOn = function() return self:isAnyHeadlightSwitchedOn() end
    closure.switchOnHeadlights = function() return self:switchOnHeadlights() end
    closure.switchOffHeadlights = function() return self:switchOffHeadlights() end
    closure.isRemoteControlled = function() return self:isRemoteControlled() end
    closure.activateGroundEngineAltitudeStabilization = function(targetAltitude)
        return self:activateGroundEngineAltitudeStabilization(targetAltitude)
    end
    closure.getSurfaceEngineAltitudeStabilization = function() return self:getSurfaceEngineAltitudeStabilization() end
    closure.deactivateGroundEngineAltitudeStabilization = function()
        return self:deactivateGroundEngineAltitudeStabilization()
    end
    closure.computeGroundEngineAltitudeStabilizationCapabilities = function()
        return self:computeGroundEngineAltitudeStabilizationCapabilities()
    end
    closure.getThrottle = function() return self:getThrottle() end
    return closure
end

return M