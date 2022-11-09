#!/usr/bin/env lua
--- Tests on dumocks.PressureTileUnit.
-- @see dumocks.PressureTileUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mptu = require("dumocks.PressureTileUnit")
require("test.Utilities")
local AbstractTestElementWithState = require("test.dumocks.AbstractTestElementWithState")

_G.TestPressureTileUnit = AbstractTestElementWithState

function _G.TestPressureTileUnit.getTestElement()
    return mptu:new()
end

function _G.TestPressureTileUnit.getStateFunction(closure)
    return closure.isDown
end

--- Verify constructor arguments properly handled.
function _G.TestPressureTileUnit.testConstructor()

    -- default element:
    -- ["pressure tile xs"] = {mass = 50.63, maxHitPoints = 50.0, itemId = 2012928469}

    local tile0 = mptu:new()
    local tile1 = mptu:new(nil, 1, "Pressure Tile XS")
    local tile2 = mptu:new(nil, 2, "invalid")

    local tileClosure0 = tile0:mockGetClosure()
    local tileClosure1 = tile1:mockGetClosure()
    local tileClosure2 = tile2:mockGetClosure()

    lu.assertEquals(tileClosure0.getLocalId(), 0)
    lu.assertEquals(tileClosure1.getLocalId(), 1)
    lu.assertEquals(tileClosure2.getLocalId(), 2)

    local defaultMass = 50.63
    lu.assertEquals(tileClosure0.getMass(), defaultMass)
    lu.assertEquals(tileClosure1.getMass(), defaultMass)
    lu.assertEquals(tileClosure2.getMass(), defaultMass)

    local defaultId = 2012928469
    lu.assertEquals(tileClosure0.getItemId(), defaultId)
    lu.assertEquals(tileClosure1.getItemId(), defaultId)
    lu.assertEquals(tileClosure2.getItemId(), defaultId)
end

--- Verify pressed works without errors.
function _G.TestPressureTileUnit.testPressed()
    local mock = mptu:new()
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

--- Verify pressed works with and propagates errors.
function _G.TestPressureTileUnit.testPressedError()
    local mock = mptu:new()

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
function _G.TestPressureTileUnit.testReleased()
    local mock = mptu:new()
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
function _G.TestPressureTileUnit.testReleasedError()
    local mock = mptu:new()

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
-- 1. 1x Pressure Tile, connected to Programming Board on slot1
--
-- Exercises: getClass, isDown, EVENT_onPressed, EVENT_onReleased, getSignalOut
function _G.TestPressureTileUnit.testGameBehavior()
    local tile = mptu:new(nil, 1)
    local slot1 = tile:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getWidgetData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function(_)
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
        assert(pressedCount == 1) -- should only ever be called once, when the user presses the tile
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
    tile:mockRegisterPressed(pressedHandler1)
    tile:mockRegisterPressed(pressedHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.onReleased()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.isDown() == 0) -- toggles before calling handlers
        assert(releasedCount == 1) -- should only ever be called once, when the user releases the tile
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
    tile:mockRegisterReleased(releasedHandler1)
    tile:mockRegisterReleased(releasedHandler2)

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getState", "isDown", "getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "PressureTileUnit")
    assert(slot1.getItemId() == 2012928469)
    assert(string.match(string.lower(slot1.getName()), "pressure tile xs %[%d+%]"), slot1.getName())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 50.63)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    pressedCount = 0
    releasedCount = 0

    -- prep for user interaction
    assert(slot1.isDown() == 0)

    system.print("please enable and disable the tile")
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    tile:mockDoPressed()
    tile:mockDoReleased()

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
