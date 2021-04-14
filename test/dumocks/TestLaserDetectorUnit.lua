#!/usr/bin/env lua
--- Tests on dumocks.LaserDetectorUnit.
-- @see dumocks.LaserDetectorUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mldu = require("dumocks.LaserDetectorUnit")
local mleu = require("dumocks.LaserEmitterUnit")
require("test.Utilities")

_G.TestLaserDetectorUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLaserDetectorUnit.testConstructor()

    -- default element:
    -- ["laser receiver"] = {mass = 9.93, maxHitPoints = 50.0}

    local receiver0 = mldu:new()
    local receiver1 = mldu:new(nil, 1, "Laser Receiver")
    local receiver2 = mldu:new(nil, 2, "invalid")
    local receiver3 = mldu:new(nil, 3, "infrared laser receiver")

    local receiverClosure0 = receiver0:mockGetClosure()
    local receiverClosure1 = receiver1:mockGetClosure()
    local receiverClosure2 = receiver2:mockGetClosure()
    local receiverClosure3 = receiver3:mockGetClosure()

    lu.assertEquals(receiverClosure0.getId(), 0)
    lu.assertEquals(receiverClosure1.getId(), 1)
    lu.assertEquals(receiverClosure2.getId(), 2)
    lu.assertEquals(receiverClosure3.getId(), 3)

    -- all receivers share attributes, can't verify element selection
end

--- Verify hit works without errors.
function _G.TestLaserDetectorUnit.testHit()
    local mock = mldu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.getState()
    end
    mock:mockRegisterLaserHit(callback)

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoLaserHit()
    lu.assertTrue(called)
    lu.assertEquals(detectorState, 1) -- changes before callback

    lu.assertTrue(mock.state)

    called = false
    mock:mockDoLaserHit()
    lu.assertFalse(called)

    lu.assertTrue(mock.state)
end

--- Verify hit works with and propagates errors.
function _G.TestLaserDetectorUnit.testHitError()
    local mock = mldu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterLaserHit(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterLaserHit(callback2)

    lu.assertFalse(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoLaserHit, mock)
    lu.assertEquals(calls, 6)
    lu.assertEquals(callback1Order % 2, 1)
    lu.assertEquals(callback2Order % 2, 0)

    lu.assertTrue(mock.state)
end

--- Verify release works without errors.
function _G.TestLaserDetectorUnit.testRelease()
    local mock = mldu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.getState()
    end
    mock:mockRegisterLaserRelease(callback)

    mock.state = true
    lu.assertTrue(mock.state)

    called = false
    mock:mockDoLaserRelease()
    lu.assertTrue(called)
    lu.assertEquals(detectorState, 0) -- changes before callbacks

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoLaserRelease()
    lu.assertFalse(called)

    lu.assertFalse(mock.state)
end

--- Verify release works with and propagates errors.
function _G.TestLaserDetectorUnit.testReleaseError()
    local mock = mldu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterLaserRelease(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterLaserRelease(callback2)

    mock.state = true
    lu.assertTrue(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoLaserRelease, mock, 1)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertFalse(mock.state)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Laser Detector, connected to Programming Board on slot1
-- 2. 1x Laser Emitter, connected to Programming Board on slot2
--
-- Exercises: getElementClass, getState, EVENT_laserHit, EVENT_laserRelease, getSignalOut
function _G.TestLaserDetectorUnit.testGameBehavior()
    local detector = mldu:new(nil, 1)
    local slot1 = detector:mockGetClosure()

    local emitter = mleu:new()
    local slot2 = emitter:mockGetClosure()

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
    local hitCount = 0
    local releasedCount = 0

    -- pressed handlers
    local hitHandler1 = function()
        ---------------
        -- copy from here to slot1.laserHit()
        ---------------
        hitCount = hitCount + 1
        assert(slot1.getState() == 1) -- toggles before calling handlers
        assert(hitCount % 2 == 1) -- called first, odd number
        assert(slot1.getSignalOut("out") == 1.0)
        ---------------
        -- copy to here to slot1.laserHit()
        ---------------
    end
    local hitHandler2 = function()
        ---------------
        -- copy from here to slot1.laserHit()
        ---------------
        hitCount = hitCount + 1
        assert(hitCount % 2 == 0) -- called second in hit handler list, even number

        -- turn off emitter
        slot2.deactivate()
        ---------------
        -- copy to here to slot1.laserHit()
        ---------------
    end
    detector:mockRegisterLaserHit(hitHandler1)
    detector:mockRegisterLaserHit(hitHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.laserRelease()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.getState() == 0) -- toggled before calling handlers
        assert(releasedCount == 1) -- should only ever be called once, when the emitter turns off
        assert(slot1.getSignalOut("out") == 0.0)
        ---------------
        -- copy to here to slot1.laserRelease()
        ---------------
    end
    local releasedHandler2 = function()
        ---------------
        -- copy from here to slot1.laserRelease()
        ---------------
        releasedCount = releasedCount + 1
        assert(releasedCount == 2) -- called second in release handler list

        unit.exit() -- run stop to report final result
        ---------------
        -- copy to here to slot1.laserRelease()
        ---------------
    end
    detector:mockRegisterLaserRelease(releasedHandler1)
    detector:mockRegisterLaserRelease(releasedHandler2)

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getState", "getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "LaserDetectorUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 9.93)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    hitCount = 0
    releasedCount = 0

    -- prep for run
    local startState = slot2.getState()
    slot2.deactivate()
    if startState ~= 0 then
        local message = "Invalid state: emitter started on. Please restart test"
        system.print(message)
        assert(false, message)
    end

    slot2.activate()
    ---------------
    -- copy to here to unit.start()
    ---------------

    -- should turn laser on in start
    if slot2.getState() == 1 then
        detector:mockDoLaserHit()
    end
    -- should turn laser off in hit callback
    if slot2.getState() == 0 then
        detector:mockDoLaserRelease()
    end

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(slot1.getState() == 0)
    assert(hitCount == 6, "Hit count should be 2: " .. hitCount)
    assert(releasedCount == 2)

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
