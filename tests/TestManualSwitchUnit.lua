#!/usr/bin/env lua
--- Tests on dumocks.ManualSwitchUnit.
-- @see dumocks.ManualSwitchUnit

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local mmsu = require("dumocks.ManualSwitchUnit")
require("tests.Utilities")

_G.TestManualSwitchUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestManualSwitchUnit.testConstructor()

    -- default element:
    -- ["manual switch"] = {mass = 13.27, maxHitPoints = 50.0}

    local switch1 = mmsu:new(nil, 1, "Manual Switch")
    local switch2 = mmsu:new(nil, 2, "invalid")
    local switch3 = mmsu:new()

    local switch1Closure = switch1:mockGetClosure()
    local switch2Closure = switch2:mockGetClosure()
    local switch3Closure = switch3:mockGetClosure()

    lu.assertEquals(switch1Closure.getId(), 1)
    lu.assertEquals(switch2Closure.getId(), 2)
    lu.assertEquals(switch3Closure.getId(), 0)

    -- prove default element is selected
    local defaultMass = 13.27
    lu.assertEquals(switch1Closure.getMass(), defaultMass)
    lu.assertEquals(switch2Closure.getMass(), defaultMass)
    lu.assertEquals(switch3Closure.getMass(), defaultMass)

    -- do some damage, max hit points is 50 (prove independance)
    switch1.hitPoints = 25.0
    switch2.hitPoints = 12.5
    switch3.hitPoints = 0.25

    lu.assertEquals(switch1Closure.getIntegrity(), 50.0)
    lu.assertEquals(switch2Closure.getIntegrity(), 25.0)
    lu.assertEquals(switch3Closure.getIntegrity(), 0.5)
end

--- Verify callbacks can be registered and fire properly for `pressed()`.
function _G.TestManualSwitchUnit.testDoPressedValid()
    local switch = mmsu:new()

    local pressed1Result = nil
    local pressed1Index = switch:mockRegisterPressed(function()
        pressed1Result = switch:getState()
    end)
    lu.assertNotNil(pressed1Index)

    switch.state = false -- ensure not pressed
    switch:mockDoPressed()

    lu.assertTrue(switch.state) -- turns on switch
    lu.assertEquals(pressed1Result, 1) -- fires handler after turning on
end

--- Verify callbacks are properly handled for invalid calls for `pressed()`.
function _G.TestManualSwitchUnit.testDoPressedInvalid()
    local switch = mmsu:new()

    local pressed1Result = nil
    local pressed1Index = switch:mockRegisterPressed(function()
        pressed1Result = switch:getState()
    end)
    lu.assertNotNil(pressed1Index)

    switch.state = true -- invalid state, should do nothing
    switch:mockDoPressed()

    lu.assertTrue(switch.state) -- switch is still on
    lu.assertNil(pressed1Result) -- handler not fired
end

--- Verify callbacks can be registered and properly handle errors for `pressed()`.
function _G.TestManualSwitchUnit.testDoPressedError()
    local switch = mmsu:new()

    local callbackNumber = 0

    -- second callback - is valid and should fire second
    local pressed1Message = "I have problems!"
    local pressed1CallOrder = nil
    local pressed1Callback = function()
        callbackNumber = callbackNumber + 1
        pressed1CallOrder = callbackNumber
        error(pressed1Message)
    end
    local pressed1Index = switch:mockRegisterPressed(pressed1Callback)
    lu.assertNotNil(pressed1Index)

    -- second callback - is valid and should fire second
    local pressed2CallOrder = nil
    local pressed2Callback = function()
        callbackNumber = callbackNumber + 1
        pressed2CallOrder = callbackNumber
    end
    local pressed2Index = switch:mockRegisterPressed(pressed2Callback)
    lu.assertNotNil(pressed2Index)

    switch.state = false -- ensure valid state
    local status, err = pcall(function()
        switch:mockDoPressed()
    end)

    -- threw error
    lu.assertFalse(status, "Should have thrown error.")
    -- verify error message from first callback propagated up
    lu.assertStrContains(err, pressed1Message)

    -- still turned on switch
    lu.assertTrue(switch.state)

    -- verify order and that second callback was reached
    lu.assertEquals(pressed1CallOrder, 1)
    lu.assertEquals(pressed2CallOrder, 2)
end

--- Verify callbacks can be registered and fire properly for `released()`.
function _G.TestManualSwitchUnit.testDoReleasedValid()
    local switch = mmsu:new()

    local released1Result = nil
    local released1Index = switch:mockRegisterReleased(function()
        released1Result = switch:getState()
    end)
    lu.assertNotNil(released1Index)

    switch.state = true -- ensure pressed
    switch:mockDoReleased()

    lu.assertFalse(switch.state) -- turns off switch
    lu.assertEquals(released1Result, 1) -- fires handler before turning off
end

--- Verify callbacks are properly handled for invalid calls for `released()`.
function _G.TestManualSwitchUnit.testDoReleasedInvalid()
    local switch = mmsu:new()

    local released1Result = nil
    local released1Index = switch:mockRegisterReleased(function()
        released1Result = switch:getState()
    end)
    lu.assertNotNil(released1Index)

    switch.state = false -- invalid state, should do nothing
    switch:mockDoReleased()

    lu.assertFalse(switch.state) -- switch is still on
    lu.assertNil(released1Result) -- handler not fired
end

--- Verify callbacks can be registered and properly handle errors for `released()`.
function _G.TestManualSwitchUnit.testDoReleasedError()
    local switch = mmsu:new()

    local callbackNumber = 0

    -- second callback - is valid and should fire second
    local released1Message = "I have problems!"
    local released1CallOrder = nil
    local released1Callback = function()
        callbackNumber = callbackNumber + 1
        released1CallOrder = callbackNumber
        error(released1Message)
    end
    local released1Index = switch:mockRegisterReleased(released1Callback)
    lu.assertNotNil(released1Index)

    -- second callback - is valid and should fire second
    local released2CallOrder = nil
    local released2Callback = function()
        callbackNumber = callbackNumber + 1
        released2CallOrder = callbackNumber
    end
    local released2Index = switch:mockRegisterReleased(released2Callback)
    lu.assertNotNil(released2Index)

    switch.state = true -- ensure valid state
    local status, err = pcall(function()
        switch:mockDoReleased()
    end)

    -- threw error
    lu.assertFalse(status, "Should have thrown error.")
    -- verify error message from first callback propagated up
    lu.assertStrContains(err, released1Message)

    -- still turned off switch
    lu.assertFalse(switch.state)

    -- verify order and that second callback was reached
    lu.assertEquals(released1CallOrder, 1)
    lu.assertEquals(released2CallOrder, 2)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Switch, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, EVENT_pressed, EVENT_released, setSignalIn, getSignalIn, getSignalOut
function _G.TestManualSwitchUnit.testGameBehavior()
    local switch = mmsu:new(nil, 1)
    local slot1 = switch:mockGetClosure()

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
    local pressedCount = 0
    local releasedCount = 0

    -- pressed handlers
    local pressedHandler1 = function()
        ---------------
        -- copy from here to slot1.pressed()
        ---------------
        pressedCount = pressedCount + 1
        assert(slot1.getState() == 1) -- toggles before calling handlers
        assert(pressedCount == 1) -- should only ever be called once, when the user presses the switch
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
    switch:mockRegisterPressed(pressedHandler1)
    switch:mockRegisterPressed(pressedHandler2)

    -- released handlers
    local releasedHandler1 = function()
        ---------------
        -- copy from here to slot1.released()
        ---------------
        releasedCount = releasedCount + 1
        assert(slot1.getState() == 1) -- won't toggle till after handlers finished
        assert(releasedCount == 1) -- should only ever be called once, when the user releases the switch
        assert(slot1.getSignalOut("out") == 1.0)
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
    switch:mockRegisterReleased(releasedHandler1)
    switch:mockRegisterReleased(releasedHandler2)

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getSignalOut", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "ManualSwitchUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 13.27)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    slot1.deactivate()

    -- play with set signal, reset periodically as switch cannot be turned off with the "on" signal
    slot1.setSignalIn("on", 0.0)
    assert(slot1.getSignalIn("on") == 0.0)
    assert(slot1.getState() == 0.0)
    -- turns on
    slot1.setSignalIn("on", 1.0)
    assert(slot1.getSignalIn("on") == 1.0)
    assert(slot1.getState() == 1.0)
    -- but not back off
    slot1.setSignalIn("on", 0.0)
    assert(slot1.getSignalIn("on") == 0.0)
    assert(slot1.getState() == 1.0)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.deactivate()
    slot1.setSignalIn("on", 0.7)
    assert(slot1.getSignalIn("on") == 0.7)
    assert(slot1.getState() == 1.0)
    slot1.deactivate()
    slot1.setSignalIn("on", "0.5")
    assert(slot1.getSignalIn("on") == 0.5)
    assert(slot1.getState() == 1.0)
    slot1.deactivate()
    slot1.setSignalIn("on", "0.0")
    assert(slot1.getSignalIn("on") == 0.0)
    assert(slot1.getState() == 0.0)
    slot1.setSignalIn("on", "7.0")
    assert(slot1.getSignalIn("on") == 1.0)
    assert(slot1.getState() == 1.0)
    -- invalid sets to 0
    slot1.deactivate()
    slot1.setSignalIn("on", "text")
    assert(slot1.getSignalIn("on") == 0.0)
    assert(slot1.getState() == 0.0)
    slot1.setSignalIn("on", nil)
    assert(slot1.getSignalIn("on") == 0.0)
    assert(slot1.getState() == 0.0)

    -- ensure initial state
    slot1.deactivate()
    assert(slot1.getState() == 0)

    -- ensure initial state, set up globals
    slot1.deactivate()
    assert(slot1.getState() == 0)
    pressedCount = 0
    releasedCount = 0

    -- validate methods
    slot1.activate()
    assert(slot1.getState() == 1)
    assert(slot1.getSignalOut("out") == 1.0)
    slot1.deactivate()
    assert(slot1.getState() == 0)
    assert(slot1.getSignalOut("out") == 0.0)
    slot1.toggle()
    assert(slot1.getState() == 1)
    assert(slot1.getSignalOut("out") == 1.0)

    -- prep for user interaction
    slot1.deactivate()
    assert(slot1.getState() == 0)

    system.print("please enable and disable the switch")
    ---------------
    -- copy to here to unit.start()
    ---------------

    switch:mockDoPressed()
    switch:mockDoReleased()

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(slot1.getState() == 0)
    assert(pressedCount == 2, "Pressed count should be 2: " .. pressedCount)
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
