#!/usr/bin/env lua
--- Tests on dumocks.ControlUnit.
-- @see dumocks.ControlUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mcu = require("dumocks.ControlUnit")
require("test.Utilities")

_G.TestControlUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestControlUnit.testConstructor()

    -- default element:
    -- ["programming board"] = {mass = 27.74, maxHitPoints = 50.0, itemId = 3415128439, class = CLASS_GENERIC}

    local control0 = mcu:new()
    local control1 = mcu:new(nil, 1, "Programming Board XS")
    local control2 = mcu:new(nil, 2, "invalid")
    local control3 = mcu:new(nil, 3, "hovercraft seat controller s")

    local controlClosure0 = control0:mockGetClosure()
    local controlClosure1 = control1:mockGetClosure()
    local controlClosure2 = control2:mockGetClosure()
    local controlClosure3 = control3:mockGetClosure()

    lu.assertEquals(controlClosure0.getLocalId(), 0)
    lu.assertEquals(controlClosure1.getLocalId(), 1)
    lu.assertEquals(controlClosure2.getLocalId(), 2)
    lu.assertEquals(controlClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 27.74
    lu.assertEquals(controlClosure0.getMass(), defaultMass)
    lu.assertEquals(controlClosure1.getMass(), defaultMass)
    lu.assertEquals(controlClosure2.getMass(), defaultMass)
    lu.assertNotEquals(controlClosure3.getMass(), defaultMass)

    local defaultId = 3415128439
    lu.assertEquals(controlClosure0.getItemId(), defaultId)
    lu.assertEquals(controlClosure1.getItemId(), defaultId)
    lu.assertEquals(controlClosure2.getItemId(), defaultId)
    lu.assertNotEquals(controlClosure3.getItemId(), defaultId)
end

--- Verify timers can be started.
function _G.TestControlUnit.testStartTimer()
    lu.skip("NYI")
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- non-string timerId
    -- negative duration
    -- TODO
end

--- Verify isRemoteControlled translates to numbers.
function _G.TestControlUnit.testIsRemoteControlled()
    local mock = mcu:new(nil, 1, "remote controller")
    local closure = mock:mockGetClosure()

    mock.remoteControlled = false
    lu.assertEquals(closure.isRemoteControlled(), 0)

    mock.remoteControlled = true
    lu.assertEquals(closure.isRemoteControlled(), 1)
end

--- Verify tick works without errors.
function _G.TestControlUnit.testTick()
    local mock = mcu:new()

    local expected, actual
    local callback = function(timerId)
        actual = timerId
    end
    mock:mockRegisterTimer(callback, "*")

    expected = "Timer"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)

    expected = "Update"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)
end

--- Verify tick works with and propagates errors.
function _G.TestControlUnit.testTickError()
    local mock = mcu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function(_)
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterTimer(callbackError, "*")

    local callback2 = function(_)
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterTimer(callback2, "*")

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoTick, mock, "Update")
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)
end

--- Verify filtering on tick timerId works.
function _G.TestControlUnit.testTickFilter()
    local mock = mcu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterTimer(callback, "Update")

    actual = nil
    expected = "Update"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)

    actual = nil
    expected = "Tick"
    mock:mockDoTick(expected)
    lu.assertNil(actual)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. control unit of any type, cockpit/remote controller must be on a dynamic construct
--
-- Exercises: getClass, getWidgetData, isRemoteControlled
function _G.TestControlUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"programming board xs", "remote controller xs", "hovercraft seat controller s",
                             "cockpit m", "command seat controller s", "gunner module s", "emergency controller xs"}) do
        mock = mcu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestControlUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestControlUnit.gameBehaviorHelper(mock, unit)

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function(_)
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    local class = unit.getClass()
    local expectedName, expectedIds
    local isGeneric, isRemote, isCockpit, isPvp, isEcu
    if class == "Generic" then
        isGeneric = true
        expectedName = "programming board xs"
        expectedIds = {[3415128439] = true}
    elseif class == "RemoteControlUnit" then
        isRemote = true
        expectedName = "remote controller xs"
        expectedIds = {[1866437084] = true}
    elseif class == "CockpitHovercraftUnit" then
        isCockpit = true
        expectedName = "hovercraft seat controller s"
        expectedIds = {[1744160618] = true}
    elseif class == "CockpitFighterUnit" then
        isCockpit = true
        expectedName = "cockpit m"
        expectedIds = {[3640291983] = true}
    elseif class == "CockpitCommandmentUnit" then
        isCockpit = true
        expectedName = "command seat controller s"
        expectedIds = {[3655856020] = true}
    elseif class == "PVPSeatUnit" then
        isPvp = true
        expectedName = "gunner module %w"
        expectedIds = {[1373443625] = true, [564736657] = true, [3327293642] = true}
    elseif class == "ECU" then
        isEcu = true
        expectedName = "emergency controller xs"
        expectedIds = {[286542481] = true}
    else
        assert(false, "Unexpected class: " .. class)
    end
    expectedName = expectedName .. " %[%d+%]"
    assert(string.match(string.lower(unit.getName()), expectedName), unit.getName())
    assert(expectedIds[unit.getItemId()], "Unexpected ID: " .. unit.getItemId())

    -- verify expected functions
    local expectedFunctions = {"exit", "setTimer", "stopTimer", "getAtmosphereDensity", "getClosestPlanetInfluence",
                               "getMasterPlayerId", "getMasterPlayerOrgIds", "setEngineCommand", "setEngineThrust",
                               "setAxisCommandValue", "getAxisCommandValue", "setupAxisCommandProperties",
                               "getControlMasterModeId", "cancelCurrentControlMasterMode", "isAnyLandingGearExtended",
                               "extendLandingGears", "retractLandingGears", "isMouseControlActivated",
                               "isMouseDirectControlActivated", "getMasterPlayerPosition", "getMasterPlayerWorldPosition",
                               "getMasterPlayerForward", "getMasterPlayerUp", "getMasterPlayerRight",
                               "getMasterPlayerWorldForward", "getMasterPlayerWorldUp", "getMasterPlayerWorldRight",
                               "isMouseVirtualJoystickActivated", "isAnyHeadlightSwitchedOn", "switchOnHeadlights",
                               "switchOffHeadlights", "isRemoteControlled", "activateGroundEngineAltitudeStabilization",
                               "getSurfaceEngineAltitudeStabilization", "deactivateGroundEngineAltitudeStabilization",
                               "computeGroundEngineAltitudeStabilizationCapabilities", "getThrottle",
                               "setupControlMasterModeProperties", "getMasterPlayerMass", "getMasterPlayerParent",
                               "isMasterPlayerSeated", "getMasterPlayerSeatId", "isAnyLandingGearDeployed",
                               "deployLandingGears", "setWidgetControlModeLabel", "getControlMode", "hasDRM",
                               "getEngineThrust"}
    if isGeneric or isEcu then
        table.insert(expectedFunctions, "setSignalIn")
        table.insert(expectedFunctions, "getSignalIn")
    end
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(unit, expectedFunctions)

    -- test inherited methods
    local data = unit.getWidgetData()
    local expectedFields = {"helperId", "name", "type", "showScriptError", "elementId", "controlMasterModeId"}
    local expectedValues = {}
    local ignoreFields = {}
    expectedValues["showScriptError"] = 'false'
    local widgetType
    if isGeneric or isPvp or isEcu then
        widgetType = "basic_control_unit"

        expectedValues["type"] = '"basic_control_unit"'
        expectedValues["helperId"] = '"basic_control_unit"'
    else
        widgetType = "cockpit"

        expectedValues["type"] = '"cockpit"'
        expectedValues["helperId"] = '"cockpit"'
        table.insert(expectedFields, "controlData")
        table.insert(expectedFields, "showHasInactiveFuelTank")
        table.insert(expectedFields, "showOutOfFuel")
        table.insert(expectedFields, "showOverload")
        table.insert(expectedFields, "showSlowDown")
        table.insert(expectedFields, "atmoThrust")
        table.insert(expectedFields, "spaceThrust")
        table.insert(expectedFields, "speed")
        table.insert(expectedFields, "maxSpeed")
        table.insert(expectedFields, "speedEffects")
        table.insert(expectedFields, "acceleration")
        table.insert(expectedFields, "airDensity")
        table.insert(expectedFields, "airResistance")
        ignoreFields = {"currentBrake", "maxBrake"}
        table.insert(expectedFields, "parentingInfo")
        table.insert(expectedFields, "autoParentingMode")
        table.insert(expectedFields, "closestConstructName")
        table.insert(expectedFields, "parentName")
        table.insert(expectedFields, "parentingState")
        -- all of this is within the speedEffects value
        -- TODO use real json parsing to detect this in a sensible way
        table.insert(expectedFields, "boostCount")
        table.insert(expectedFields, "boostSpeedModifier")
        table.insert(expectedFields, "boostSpeedModifierRatio")
        table.insert(expectedFields, "stasisCount")
        table.insert(expectedFields, "stasisSpeedModifier")
        table.insert(expectedFields, "stasisSpeedModifierRatio")
        table.insert(expectedFields, "stasisTimeRemaining")
        -- all of this is within the controlData value
        -- TODO use real json parsing to detect this in a sensible way
        table.insert(expectedFields, "axisData")
        table.insert(expectedFields, "speed")
        table.insert(expectedFields, "speed")
        table.insert(expectedFields, "speed")
        table.insert(expectedFields, "currentMasterMode")
        table.insert(expectedFields, "masterModeData")
        table.insert(expectedFields, "name")
        table.insert(expectedFields, "name")
        table.insert(expectedFields, "commandType")
        table.insert(expectedFields, "commandType")
        table.insert(expectedFields, "commandType")
        table.insert(expectedFields, "commandValue")
        table.insert(expectedFields, "commandValue")
        table.insert(expectedFields, "commandValue")
    end
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)

    assert(unit.getMaxHitPoints() >= 50.0)
    assert(unit.getMass() > 7.0)
    _G.Utilities.verifyBasicElementFunctions(unit, 3, widgetType)

    if isGeneric or isEcu then
        -- play with set signal, has no actual effect on state when set programmatically
        unit.setSignalIn("in", 0.0)
        assert(unit.getSignalIn("in") == 0.0)
        unit.setSignalIn("in", 1.0)
        assert(unit.getSignalIn("in") == 0.0)
        unit.setSignalIn("in", 0.7)
        assert(unit.getSignalIn("in") == 0.0)
        unit.setSignalIn("in", "1.0")
        assert(unit.getSignalIn("in") == 0.0)
    end

    if not (isGeneric or isPvp) then
        if isRemote then
            assert(unit.isRemoteControlled() == 1)
        else
            assert(unit.isRemoteControlled() == 0)
        end
    end

    system.print("Success")
    if isGeneric or isRemote or isEcu then
        unit.exit()
    end
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
