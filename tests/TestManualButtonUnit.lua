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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Manual Button S, connected to Programming Board on slot1
--
-- Exercises: getElementClass, getState, EVENT_pressed, EVENT_released
function _G.TestManualButtonUnit.testGameBehavior()
    local button = mmbu:new()
    local slot1 = button:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {getData = function() return '"showScriptError":false' end}
    local system = {}
    system.print = function() end

    -- use locals here since all code is in this method
    local pressedCount = 0
    local releasedCount = 0

    -- pressed handlers
    local pressedHandler1 = function()
        ---------------
        -- copy from here to slot1.pressed()
        ---------------
        pressedCount = pressedCount + 1
        assert(slot1.getState() == 1) -- toggles before calling handlers
        assert(pressedCount == 1) -- should only ever be called once, when the user presses the button
        ---------------
        -- copy to here to slot1.pressed()
        ---------------
    end
    local pressedHandler2 = function()
        ---------------
        -- copy from here to slot1.pressed()
        ---------------
        pressedCount = pressedCount + 1
        assert(pressedCount == 2) -- called second in pressed handler list
        ---------------
        -- copy to here to slot1.pressed()
        ---------------
    end
    button:mockRegisterPressed(pressedHandler1)
    button:mockRegisterPressed(pressedHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.released()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.getState() == 1) -- won't toggle till after handlers finished
        assert(releasedCount == 1) -- should only ever be called once, when the user releases the button
        ---------------
        -- copy to here to slot1.released()
        ---------------
    end
    local releasedHandler2 = function()
        ---------------
        -- copy from here to slot1.released()
        ---------------
        releasedCount = releasedCount + 1
        assert(releasedCount == 2) -- called second in released handler list
        ---------------
        -- copy to here to slot1.released()
        ---------------
    end
    button:mockRegisterReleased(releasedHandler1)
    button:mockRegisterReleased(releasedHandler2)

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "ManualButtonUnit")

    -- ensure initial state, set up globals
    pressedCount = 0
    releasedCount = 0

    -- prep for user interaction
    assert(slot1.getState() == 0)

    system.print("please enable and disable the button")
    ---------------
    -- copy to here to unit.start()
    ---------------

    button:mockDoPressed()
    button:mockDoReleased()

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(slot1.getState() == 0)
    assert(pressedCount == 2, "Pressed count should be 2: "..pressedCount)
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