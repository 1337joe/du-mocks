#!/usr/bin/env lua
--- Tests on dumocks.PressureTileUnit.
-- @see dumocks.PressureTileUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mptu = require("dumocks.PressureTileUnit")

_G.TestPressureTileUnit = {}

--- Verify constructor arguments properly handled.
function _G.TestPressureTileUnit.testConstructor()

    -- default element:
    -- ["pressure tile"] = {mass = 50.63, maxHitPoints = 50.0}

    local tile0 = mptu:new()
    local tile1 = mptu:new(nil, 1, "Pressure Tile")
    local tile2 = mptu:new(nil, 2, "invalid")

    local tileClosure0 = tile0:mockGetClosure()
    local tileClosure1 = tile1:mockGetClosure()
    local tileClosure2 = tile2:mockGetClosure()

    lu.assertEquals(tileClosure0.getId(), 0)
    lu.assertEquals(tileClosure1.getId(), 1)
    lu.assertEquals(tileClosure2.getId(), 2)

    local defaultMass = 50.63
    lu.assertEquals(tileClosure0.getMass(), defaultMass)
    lu.assertEquals(tileClosure1.getMass(), defaultMass)
    lu.assertEquals(tileClosure2.getMass(), defaultMass)
end

--- Verify pressed works without errors.
function _G.TestPressureTileUnit.testPressed()
    local mock = mptu:new()
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
        detectorState = closure.getState()
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
-- Exercises: getElementClass, getState, EVENT_pressed, EVENT_released, getSignalOut
function _G.TestPressureTileUnit.testGameBehavior()
    local tile = mptu:new(nil, 1)
    local slot1 = tile:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getData = function() return '"showScriptError":false' end
    unit.exit = function() end
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
        assert(pressedCount == 1) -- should only ever be called once, when the user presses the tile
        assert(slot1.getSignalOut("out") == 1.0)
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
    tile:mockRegisterPressed(pressedHandler1)
    tile:mockRegisterPressed(pressedHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.released()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.getState() == 0) -- toggles before calling handlers
        assert(releasedCount == 1) -- should only ever be called once, when the user releases the tile
        assert(slot1.getSignalOut("out") == 0.0)
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

        unit.exit() -- run stop to report final result
        ---------------
        -- copy to here to slot1.released()
        ---------------
    end
    tile:mockRegisterReleased(releasedHandler1)
    tile:mockRegisterReleased(releasedHandler2)

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getState", "getSignalOut",
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "load"}
    local unexpectedFunctions = {}
    for key, value in pairs(slot1) do
        if type(value) == "function" then
            for index, funcName in pairs(expectedFunctions) do
                if key == funcName then
                    table.remove(expectedFunctions, index)
                    goto continueOuter
                end
            end

            table.insert(unexpectedFunctions, key)
        end

        ::continueOuter::
    end
    local message = ""
    if #expectedFunctions > 0 then
        message = message .. "Missing expected functions: " .. table.concat(expectedFunctions, ", ") .. "\n"
    end
    if #unexpectedFunctions > 0 then
        message = message .. "Found unexpected functions: " .. table.concat(unexpectedFunctions, ", ") .. "\n"
    end
    assert(message:len() == 0, message)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "PressureTileUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 50.63)

    -- ensure initial state, set up globals
    pressedCount = 0
    releasedCount = 0

    -- prep for user interaction
    assert(slot1.getState() == 0)

    system.print("please enable and disable the tile")
    ---------------
    -- copy to here to unit.start()
    ---------------

    tile:mockDoPressed()
    tile:mockDoReleased()

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