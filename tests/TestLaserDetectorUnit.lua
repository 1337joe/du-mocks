#!/usr/bin/env lua
--- Tests on dumocks.LaserDetectorUnit.
-- @see dumocks.LaserDetectorUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mldu = require("dumocks.LaserDetectorUnit")

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

--- Verify element class is correct.
function _G.TestLaserDetectorUnit.testGetElementClass()
    local element = mldu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LaserDetectorUnit")
end

--- Verify that get state retrieves the state properly.
function _G.TestLaserDetectorUnit.testGetState()
    local mock = mldu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
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
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

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
    lu.assertEquals(detectorState, 1) -- changes after callbacks

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

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestLaserDetectorUnit.skipTestGameBehavior()
    local mock = mldu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LaserDetectorUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())