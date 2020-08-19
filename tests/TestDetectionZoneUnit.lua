#!/usr/bin/env lua
--- Tests on dumocks.DetectionZoneUnit.
-- @see dumocks.DetectionZoneUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdzu = require("dumocks.DetectionZoneUnit")

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

--- Verify element class is correct.
function _G.TestDetectionZoneUnit.testGetElementClass()
    local element = mdzu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "DetectionZoneUnit")
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

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestDetectionZoneUnit.skipTestGameBehavior()
    local mock = mdzu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "DetectionZoneUnit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())