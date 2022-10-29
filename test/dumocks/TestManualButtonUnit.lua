#!/usr/bin/env lua
--- Tests on dumocks.ManualButtonUnit.
-- @see dumocks.ManualButtonUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mmbu = require("dumocks.ManualButtonUnit")
require("test.Utilities")
local TestElementWithState = require("test.dumocks.TestElementWithState")

_G.TestManualButtonUnit = TestElementWithState

function _G.TestManualButtonUnit.getTestElement()
    return mmbu:new()
end

function _G.TestManualButtonUnit.getStateFunction(closure)
    return closure.isDown
end

--- Verify constructor arguments properly handled.
function _G.TestManualButtonUnit.testConstructor()

    -- default element:
    -- ["manual button s"] = {mass = 13.27, maxHitPoints = 50.0, itemId = 2896791363}

    local button0 = mmbu:new()
    local button1 = mmbu:new(nil, 1, "Manual Button S")
    local button2 = mmbu:new(nil, 2, "invalid")
    local button3 = mmbu:new(nil, 3, "Manual Button XS")

    local buttonClosure0 = button0:mockGetClosure()
    local buttonClosure1 = button1:mockGetClosure()
    local buttonClosure2 = button2:mockGetClosure()
    local buttonClosure3 = button3:mockGetClosure()

    lu.assertEquals(buttonClosure0.getLocalId(), 0)
    lu.assertEquals(buttonClosure1.getLocalId(), 1)
    lu.assertEquals(buttonClosure2.getLocalId(), 2)
    lu.assertEquals(buttonClosure3.getLocalId(), 3)

    local defaultMass = 13.27
    lu.assertEquals(buttonClosure0.getMass(), defaultMass)
    lu.assertEquals(buttonClosure1.getMass(), defaultMass)
    lu.assertEquals(buttonClosure2.getMass(), defaultMass)
    lu.assertEquals(buttonClosure3.getMass(), defaultMass)

    -- prove default element is selected only where appropriate
    local defaultId = 2896791363
    lu.assertEquals(buttonClosure0.getItemId(), defaultId)
    lu.assertEquals(buttonClosure1.getItemId(), defaultId)
    lu.assertEquals(buttonClosure2.getItemId(), defaultId)
    lu.assertNotEquals(buttonClosure3.getItemId(), defaultId)
end

--- Verify press works without errors.
function _G.TestManualButtonUnit.testOnPressed()
    local mock = mmbu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.isDown()
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

--- Verify press works with and propagates errors.
function _G.TestManualButtonUnit.testOnPressedError()
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
function _G.TestManualButtonUnit.testOnReleased()
    local mock = mmbu:new()
    local closure = mock:mockGetClosure()

    local called, detectorState
    local callback = function()
        called = true
        detectorState = closure.isDown()
    end
    mock:mockRegisterReleased(callback)

    mock.state = true
    lu.assertTrue(mock.state)

    called = false
    mock:mockDoReleased()
    lu.assertTrue(called)
    lu.assertEquals(detectorState, 0) -- changes before callbacks

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoReleased()
    lu.assertFalse(called)

    lu.assertFalse(mock.state)
end

--- Verify release works with and propagates errors.
function _G.TestManualButtonUnit.testOnReleasedError()
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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Manual Button S, connected to Programming Board on slot1
--
-- Exercises: getElementClass, isDown, EVENT_onPressed, EVENT_onReleased, getSignalOut
function _G.TestManualButtonUnit.testGameBehavior()
    local button = mmbu:new(nil, 1)
    local slot1 = button:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getWidgetData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    -- use locals here since all code is in this method
    local pressedCount = 0
    local releasedCount = 0

    -- pressed handlers
    local pressedHandler1 = function()
        ---------------
        -- copy from here to slot1.onPressed()
        ---------------
        pressedCount = pressedCount + 1
        assert(slot1.isDown() == 1) -- toggles before calling handlers
        assert(pressedCount == 1) -- should only ever be called once, when the user presses the button
        assert(slot1.getSignalOut("out") == 1.0)
        ---------------
        -- copy to here to slot1.onPressed()
        ---------------
    end
    local pressedHandler2 = function()
        ---------------
        -- copy from here to slot1.onPressed()
        ---------------
        pressedCount = pressedCount + 1
        assert(pressedCount == 2) -- called second in pressed handler list
        ---------------
        -- copy to here to slot1.onPressed()
        ---------------
    end
    button:mockRegisterPressed(pressedHandler1)
    button:mockRegisterPressed(pressedHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.onReleased()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.isDown() == 0) -- toggled before calling handlers
        assert(releasedCount == 1) -- should only ever be called once, when the user releases the button
        assert(slot1.getSignalOut("out") == 0.0)
        ---------------
        -- copy to here to slot1.onReleased()
        ---------------
    end
    local releasedHandler2 = function()
        ---------------
        -- copy from here to slot1.onReleased()
        ---------------
        releasedCount = releasedCount + 1
        assert(releasedCount == 2) -- called second in released handler list

        unit.exit() -- run stop to report final result
        ---------------
        -- copy to here to slot1.onReleased()
        ---------------
    end
    button:mockRegisterReleased(releasedHandler1)
    button:mockRegisterReleased(releasedHandler2)

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"isDown", "getState", "getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "ManualButtonUnit")
    local itemId = slot1.getItemId()
    local name = slot1.getName()
    if itemId == 2896791363 then
        assert(string.match(string.lower(name), "manual button s %[%d+%]"), name)
    elseif itemId == 1550904282 then
        assert(string.match(string.lower(name), "manual button xs %[%d+%]"), name)
    else
        error(string.format("Unexpected item id: %d (%s)", itemId, name))
    end
    assert(slot1.getMass() == 13.27)
    assert(slot1.getMaxHitPoints() == 50.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    pressedCount = 0
    releasedCount = 0

    -- prep for user interaction
    assert(slot1.isDown() == 0)

    system.print("please enable and disable the button")
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    button:mockDoPressed()
    button:mockDoReleased()

    ---------------
    -- copy from here to unit.onStop()
    ---------------
    assert(slot1.isDown() == 0)
    assert(pressedCount == 2, "Pressed count should be 2: " .. pressedCount)
    assert(releasedCount == 2)

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getWidgetData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end
    ---------------
    -- copy to here to unit.onStop()
    ---------------
end

os.exit(lu.LuaUnit.run())
