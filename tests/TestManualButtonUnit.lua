#!/usr/bin/env lua
--- Tests on dumocks.ManualButtonUnit.
-- @see dumocks.ManualButtonUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mmbu = require("dumocks.ManualButtonUnit")

_G.TestManualButtonUnit = {}

--- Verify element class is correct.
function _G.TestManualButtonUnit.testGetElementClass()
    local element = mmbu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ManualButtonUnit")
end

--- Verify that get state retrieves the state properly.
function _G.TestManualButtonUnit.testGetState()
    local mock = mmbu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
end


--- Verify hit works without errors.
function _G.TestManualButtonUnit.testHit()
    local mock = mmbu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.getState()
    end
    mock:mockRegisterPressed(callback)

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoPressed()
    lu.assertTrue(called)
    lu.assertEquals(detectorState, 1) -- changes before callback

    lu.assertTrue(mock.state)

    called = false
    mock:mockDoPressed()
    lu.assertFalse(called)

    lu.assertTrue(mock.state)
end

--- Verify hit works with and propagates errors.
function _G.TestManualButtonUnit.testHitError()
    local mock = mmbu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterPressed(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterPressed(callback2)

    lu.assertFalse(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoPressed, mock)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertTrue(mock.state)
end

--- Verify release works without errors.
function _G.TestManualButtonUnit.testReleased()
    local mock = mmbu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.getState()
    end
    mock:mockRegisterReleased(callback)

    mock.state = true
    lu.assertTrue(mock.state)

    called = false
    mock:mockDoReleased()
    lu.assertTrue(called)
    lu.assertEquals(detectorState, 1) -- changes after callbacks

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoReleased()
    lu.assertFalse(called)

    lu.assertFalse(mock.state)
end

--- Verify release works with and propagates errors.
function _G.TestManualButtonUnit.testReleasedError()
    local mock = mmbu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterReleased(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterReleased(callback2)

    mock.state = true
    lu.assertTrue(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoReleased, mock, 1)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertFalse(mock.state)
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestManualButtonUnit.skipTestGameBehavior()
    local mock = mmbu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "ManualButtonUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())