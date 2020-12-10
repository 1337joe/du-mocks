#!/usr/bin/env lua
--- Tests on dumocks.DetectionZoneUnit.
-- @see dumocks.DetectionZoneUnit

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local mdzu = require("dumocks.DetectionZoneUnit")
require("tests.Utilities")

_G.TestDetectionZoneUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestDetectionZoneUnit.testConstructor()

    -- default element:
    -- ["detection zone xs"] = {mass = 7.79, maxHitPoints = 50.0}

    local detector0 = mdzu:new()
    local detector1 = mdzu:new(nil, 1, "Detection Zone XS")
    local detector2 = mdzu:new(nil, 2, "invalid")
    local detector3 = mdzu:new(nil, 3, "detection zone s")

    local detectorClosure0 = detector0:mockGetClosure()
    local detectorClosure1 = detector1:mockGetClosure()
    local detectorClosure2 = detector2:mockGetClosure()
    local detectorClosure3 = detector3:mockGetClosure()

    lu.assertEquals(detectorClosure0.getId(), 0)
    lu.assertEquals(detectorClosure1.getId(), 1)
    lu.assertEquals(detectorClosure2.getId(), 2)
    lu.assertEquals(detectorClosure3.getId(), 3)

    -- all detection zones share attributes, can't verify element selection
end

--- Verify enter works without errors.
function _G.TestDetectionZoneUnit.testEnter()
    local mock = mdzu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterEnter(callback)

    expected = 1
    mock:mockDoEnter(expected)
    lu.assertEquals(actual, expected)

    expected = 9999
    mock:mockDoEnter(expected)
    lu.assertEquals(actual, expected)
end

--- Verify enter works with and propagates errors.
function _G.TestDetectionZoneUnit.testEnterError()
    local mock = mdzu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function(_)
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterEnter(callbackError)

    local callback2 = function(_)
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterEnter(callback2)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoEnter, mock, 1)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)
end

--- Verify filtering on enter id works.
function _G.TestDetectionZoneUnit.testEnterFilter()
    local mock = mdzu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterEnter(callback, "1")

    actual = nil
    expected = 1
    mock:mockDoEnter(expected)
    lu.assertEquals(actual, expected)

    actual = nil
    expected = 9999
    mock:mockDoEnter(expected)
    lu.assertNil(actual)
end

--- Verify leave works without errors.
function _G.TestDetectionZoneUnit.testLeave()
    local mock = mdzu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterLeave(callback)

    expected = 1
    mock:mockDoLeave(expected)
    lu.assertEquals(actual, expected)

    expected = 9999
    mock:mockDoLeave(expected)
    lu.assertEquals(actual, expected)
end

--- Verify leave works with and propagates errors.
function _G.TestDetectionZoneUnit.testLeaveError()
    local mock = mdzu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function(_)
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterLeave(callbackError)

    local callback2 = function(_)
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterLeave(callback2)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoLeave, mock, 1)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)
end

--- Verify filtering on leave id works.
function _G.TestDetectionZoneUnit.testLeaveFilter()
    local mock = mdzu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterLeave(callback, "1")

    actual = nil
    expected = 1
    mock:mockDoLeave(expected)
    lu.assertEquals(actual, expected)

    actual = nil
    expected = 9999
    mock:mockDoLeave(expected)
    lu.assertNil(actual)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Detection Zone XS, connected to Programming Board on slot1
--
-- Exercises: getElementClass, EVENT_enter, EVENT_leave, getSignalOut
function _G.TestDetectionZoneUnit.testGameBehavior()
    local zone = mdzu:new(nil, 1)
    local slot1 = zone:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    -- use locals here since all code is in this method
    local enterCount, leaveCount
    local enterPlayer, leavePlayer

    -- enter handlers
    local enterHandler1 = function(id)
        ---------------
        -- copy from here to slot1.enter(id) *
        ---------------
        enterPlayer = id
        enterCount = enterCount + 1
        assert(enterCount == 1) -- should only ever be called once, when the user presses the button
        assert(slot1.getSignalOut("out") == 1.0)
        ---------------
        -- copy to here to slot1.enter(id) *
        ---------------
    end
    local enterHandler2 = function(_)
        ---------------
        -- copy from here to slot1.enter(id) *
        ---------------
        enterCount = enterCount + 1
        assert(enterCount == 2) -- called second in enter handler list
        ---------------
        -- copy to here to slot1.enter(id) *
        ---------------
    end
    zone:mockRegisterEnter(enterHandler1)
    zone:mockRegisterEnter(enterHandler2)

    -- leave handlers
    local leaveHandler1 = function(id)
        ---------------
        -- copy from here to slot1.leave(id) *
        ---------------
        leavePlayer = id
        leaveCount = leaveCount + 1
        assert(leaveCount == 1) -- should only ever be called once, when the user leaves the zone
        assert(slot1.getSignalOut("out") == 0.0)
        ---------------
        -- copy to here to slot1.leave(id) *
        ---------------
    end
    local leaveHandler2 = function(_)
        ---------------
        -- copy from here to slot1.leave(id) *
        ---------------
        leaveCount = leaveCount + 1
        assert(leaveCount == 2) -- called second in leave handler list

        unit.exit()
        ---------------
        -- copy to here to slot1.leave(id) *
        ---------------
    end
    zone:mockRegisterLeave(leaveHandler1)
    zone:mockRegisterLeave(leaveHandler2)

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "DetectionZoneUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 7.79)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    enterCount = 0
    leaveCount = 0
    enterPlayer = nil
    leavePlayer = nil

    system.print("please enter and leave the zone")
    ---------------
    -- copy to here to unit.start()
    ---------------

    zone:mockDoEnter(10)
    zone.plugOut = 0.0
    zone:mockDoLeave(10)

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(enterCount == 2, "Enter count should be 2: " .. enterCount)
    assert(leaveCount == 2)
    assert(enterPlayer == leavePlayer)

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end
    ---------------
    -- copy to here to unit.stop()
    ---------------
end

os.exit(lu.LuaUnit.run())
