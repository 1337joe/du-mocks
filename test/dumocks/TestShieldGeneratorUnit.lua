#!/usr/bin/env lua
--- Tests on dumocks.ShieldGeneratorUnit.
-- @see dumocks.ShieldGeneratorUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local msgu = require("dumocks.ShieldGeneratorUnit")
require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestShieldGeneratorUnit = AbstractTestElementWithToggle

function _G.TestShieldGeneratorUnit.getTestElement()
    return msgu:new()
end

function _G.TestShieldGeneratorUnit.getStateFunction(closure)
    return closure.isActive
end

function _G.TestShieldGeneratorUnit.getActivateFunction(closure)
    return closure.activate
end

function _G.TestShieldGeneratorUnit.getDeactivateFunction(closure)
    return closure.deactivate
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestShieldGeneratorUnit.testConstructor()

    -- default element:
    -- ["shield generator xs"] = {mass = 670.0, maxHitPoints = 1400.0, itemId = 2882830295,
    -- class = CLASS .. EXTRA_SMALL_GROUP, maxShieldHitpoints = 450000.0, ventingMaxCooldown = 60.0}

    local mock0 = msgu:new()
    local mock1 = msgu:new(nil, 1, "Shield Generator XS")
    local mock2 = msgu:new(nil, 2, "invalid")
    local mock3 = msgu:new(nil, 3, "shield generator s")

    local mockClosure0 = mock0:mockGetClosure()
    local mockClosure1 = mock1:mockGetClosure()
    local mockClosure2 = mock2:mockGetClosure()
    local mockClosure3 = mock3:mockGetClosure()

    lu.assertEquals(mockClosure0.getLocalId(), 0)
    lu.assertEquals(mockClosure1.getLocalId(), 1)
    lu.assertEquals(mockClosure2.getLocalId(), 2)
    lu.assertEquals(mockClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 670.0
    lu.assertEquals(mockClosure0.getMass(), defaultMass)
    lu.assertEquals(mockClosure1.getMass(), defaultMass)
    lu.assertEquals(mockClosure2.getMass(), defaultMass)
    lu.assertNotEquals(mockClosure3.getMass(), defaultMass)

    local defaultId = 2882830295
    lu.assertEquals(mockClosure0.getItemId(), defaultId)
    lu.assertEquals(mockClosure1.getItemId(), defaultId)
    lu.assertEquals(mockClosure2.getItemId(), defaultId)
    lu.assertNotEquals(mockClosure3.getItemId(), defaultId)
end

--- Verify behavior of autoCallback.
function _G.TestShieldGeneratorUnit.testAutoCallback()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    -- automatically applies state change
    mock.autoCallback = true

    mock.state = false
    lu.assertEquals(closure.isActive(), 0)
    closure.toggle()
    lu.assertEquals(closure.isActive(), 1)

    mock.state = false
    lu.assertEquals(closure.isActive(), 0)
    closure.activate()
    lu.assertEquals(closure.isActive(), 1)

    mock.state = true
    lu.assertEquals(closure.isActive(), 1)
    closure.deactivate()
    lu.assertEquals(closure.isActive(), 0)

    -- waits to apply state change until requested
    mock.autoCallback = false

    mock.state = false
    lu.assertEquals(closure.isActive(), 0)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.isActive(), 0)

    mock.state = false
    lu.assertEquals(closure.isActive(), 0)
    closure.toggle()
    lu.assertEquals(closure.isActive(), 0)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.isActive(), 1)

    mock.state = false
    lu.assertEquals(closure.isActive(), 0)
    closure.activate()
    lu.assertEquals(closure.isActive(), 0)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.isActive(), 1)

    mock.state = true
    lu.assertEquals(closure.isActive(), 1)
    closure.deactivate()
    lu.assertEquals(closure.isActive(), 1)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.isActive(), 0)
end

--- Verify shield hitpoints considers state.
function _G.TestShieldGeneratorUnit.testGetShieldHitpoints()
    local mock = msgu:new()
    mock.shieldHitpoints = 100
    local closure = mock:mockGetClosure()

    mock.state = true
    lu.assertEquals(closure.getShieldHitpoints(), 100)

    mock.state = false
    lu.assertEquals(closure.getShieldHitpoints(), 0)
end

--- Verify toggled works without errors.
function _G.TestShieldGeneratorUnit.testToggled()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    local called, calledOn, calledOff, state, actualActive
    local callback = function(active)
        called = true
        state = closure.isActive()
        actualActive = active
    end
    mock:mockRegisterToggled(callback, "*")
    local callbackOn = function(active)
        calledOn = true
    end
    mock:mockRegisterToggled(callbackOn, "1") -- intentionally string
    local callbackOff = function(active)
        calledOff = true
    end
    mock:mockRegisterToggled(callbackOff, 0) -- intentionally not string

    local expectedState, expectedActive

    -- same state - no-op
    called, calledOn, calledOff = false, false, false
    mock.state = true
    mock:mockDoToggled(1)
    lu.assertFalse(called)
    lu.assertFalse(calledOn)
    lu.assertFalse(calledOff)

    called, calledOn, calledOff = false, false, false
    mock.state = false
    mock:mockDoToggled(0)
    lu.assertFalse(called)
    lu.assertFalse(calledOn)
    lu.assertFalse(calledOff)

    -- change state, specific callbacks expected
    called, calledOn, calledOff = false, false, false
    expectedState, expectedActive = 0, 0
    mock.state = true
    mock:mockDoToggled(expectedActive)
    lu.assertTrue(called)
    lu.assertFalse(calledOn)
    lu.assertTrue(calledOff)
    lu.assertEquals(state, expectedState)
    lu.assertEquals(actualActive, expectedActive)

    called, calledOn, calledOff = false, false, false
    expectedState, expectedActive = 1, 1
    mock.state = false
    mock:mockDoToggled(expectedActive)
    lu.assertTrue(called)
    lu.assertTrue(calledOn)
    lu.assertFalse(calledOff)
    lu.assertEquals(state, expectedState)
    lu.assertEquals(actualActive, expectedActive)
end

--- Verify toggled works with and propagates errors.
function _G.TestShieldGeneratorUnit.testToggledError()
    local mock = msgu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterToggled(callbackError, "*")

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterToggled(callback2, "*")

    mock.state = true

    -- both called, proper order, errors thrown, state still changes
    lu.assertErrorMsgContains("bad callback", mock.mockDoToggled, mock, 0)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertFalse(mock.state)
end

--- Verify absorbed works without errors.
function _G.TestShieldGeneratorUnit.testAbsorbed()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    local called, state, actualDamage, actualDamageRaw
    local callback = function(hitpoints, rawHitpoints)
        called = true
        state = closure.isActive()
        actualDamage = hitpoints
        actualDamageRaw = rawHitpoints
    end
    mock:mockRegisterAbsorbed(callback, "*", "*")

    mock.state = true
    mock.shieldHitpoints = mock.maxShieldHitpoints
    lu.assertTrue(mock.state)

    local expectedDamage, expectedDamageRaw

    -- weak hit
    called = false
    expectedDamage = 10
    expectedDamageRaw = 1.5 * expectedDamage
    mock:mockDoAbsorbed(expectedDamage, expectedDamageRaw)
    lu.assertTrue(called)
    lu.assertEquals(actualDamage, expectedDamage)
    lu.assertEquals(actualDamageRaw, expectedDamageRaw)
    -- changes before callbacks
    lu.assertEquals(mock.shieldHitpoints, mock.maxShieldHitpoints - 10)
    lu.assertEquals(state, 1) -- no change, not enough damage

    lu.assertTrue(mock.state)

    -- strong hit
    called = false
    expectedDamage = mock.maxShieldHitpoints + 100
    expectedDamageRaw = 1.5 * expectedDamage
    mock:mockDoAbsorbed(expectedDamage, expectedDamageRaw)
    lu.assertTrue(called)
    lu.assertEquals(actualDamage, expectedDamage)
    lu.assertEquals(actualDamageRaw, expectedDamageRaw)
    -- changes before callbacks
    lu.assertEquals(mock.shieldHitpoints, 0)
    lu.assertEquals(state, 0)

    lu.assertFalse(mock.state)

    -- hit after down
    called = false
    mock:mockDoAbsorbed(10)
    lu.assertFalse(called)

    lu.assertFalse(mock.state)
end

--- Verify absorbed works with and propagates errors.
function _G.TestShieldGeneratorUnit.testAbsorbedError()
    local mock = msgu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterAbsorbed(callbackError, "*", "*")

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterAbsorbed(callback2, "*", "*")

    mock.state = true
    mock.shieldHitpoints = mock.maxShieldHitpoints
    lu.assertTrue(mock.state)

    -- both called, proper order, errors thrown, state still changes
    lu.assertErrorMsgContains("bad callback", mock.mockDoAbsorbed, mock, mock.maxShieldHitpoints + 10, 15)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertFalse(mock.state)
end

--- Verify down works without errors.
function _G.TestShieldGeneratorUnit.testDown()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    local called, state
    local callback = function()
        called = true
        state = closure.isActive()
    end
    mock:mockRegisterDown(callback)

    mock.state = true
    lu.assertTrue(mock.state)

    called = false
    mock:mockDoDown()
    lu.assertTrue(called)
    lu.assertEquals(state, 0) -- changes before callbacks

    lu.assertFalse(mock.state)

    called = false
    mock:mockDoDown()
    lu.assertFalse(called)

    lu.assertFalse(mock.state)
end

--- Verify down works with and propagates errors.
function _G.TestShieldGeneratorUnit.testDownError()
    local mock = msgu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterDown(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterDown(callback2)

    mock.state = true
    lu.assertTrue(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoDown, mock)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertFalse(mock.state)
end

--- Verify restored works without errors.
function _G.TestShieldGeneratorUnit.testRestored()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    local called, state
    local callback = function()
        called = true
        state = closure.isActive()
    end
    mock:mockRegisterRestored(callback)

    mock.state = false
    lu.assertFalse(mock.state)

    called = false
    mock:mockDoRestored()
    lu.assertTrue(called)
    lu.assertEquals(state, 1) -- changes before callbacks

    lu.assertTrue(mock.state)

    called = false
    mock:mockDoRestored()
    lu.assertFalse(called)

    lu.assertTrue(mock.state)
end

--- Verify restored works with and propagates errors.
function _G.TestShieldGeneratorUnit.testRestoredError()
    local mock = msgu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterRestored(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterRestored(callback2)

    mock.state = false
    lu.assertFalse(mock.state)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoRestored, mock)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertTrue(mock.state)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Shield Generator, connected to Programming Board on slot1
--
-- Exercises: getClass, deactivate, activate, toggle, isActive, getShieldHitpoints, getMaxShieldHitpoints
function _G.TestShieldGeneratorUnit.testGameBehavior()
    local mock = msgu:new(nil, 1)
    mock.autoCallback = false
    local slot1 = mock:mockGetClosure()

    -- fake coroutine: uncomment to allow errors to immediately propagate up
    -- coroutine = {}
    -- function coroutine.create(func)
    --     coroutine.myFunc = func
    -- end
    -- function coroutine.resume()
    --     coroutine.myFunc()
    --     coroutine.resume = function() end
    -- end
    -- function coroutine.yield()
    -- end

    local finished = false

    -- stub this in directly to suppress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
        finished = true
    end
    unit.setTimer = function(_, _)
    end
    unit.stopTimer = function(_)
    end
    local system = {}
    system.print = function(msg)
    end

    -- not called by mock
    local tickFail = function()
        ---------------
        -- copy from here to unit.onTimer(timerId) fail
        ---------------
        -- should hit exit call from coroutine before this ticks
        system.print("Failed")
        unit.exit()
        ---------------
        -- copy to here to unit.onTimer(timerId) fail
        ---------------
    end
    local tickDelay = function()
        ---------------
        -- copy from here to unit.onTimer(timerId) delay
        ---------------
        unit.stopTimer("delay")
        _G.resumeCoroutine()
        ---------------
        -- copy to here to unit.onTimer(timerId) delay
        ---------------
    end

    local absorbedListener = function()
        ---------------
        -- copy from here to slot1.onAbsorbed(hitpoints,rawHitpoints) * *
        ---------------
        assert(false, "Not expecting absorbed to be called outside of combat.")
        ---------------
        -- copy to here to slot1.onAbsorbed(hitpoints,rawHitpoints) * *
        ---------------
    end
    mock:mockRegisterAbsorbed(absorbedListener)

    local downListener = function()
        ---------------
        -- copy from here to slot1.onDown()
        ---------------
        assert(false, "Not expecting down to be called outside of combat.")
        ---------------
        -- copy to here to slot1.onDown()
        ---------------
    end
    mock:mockRegisterDown(downListener)

    local restoredListener = function()
        ---------------
        -- copy from here to slot1.onRestored()
        ---------------
        assert(false, "Not expecting restored to be called outside of combat.")
        ---------------
        -- copy to here to slot1.onRestored()
        ---------------
    end
    mock:mockRegisterRestored(restoredListener)

    local toggledListener = function(active)
        ---------------
        -- copy from here to slot1.onToggled(active) *
        ---------------
        _G.toggleCount = _G.toggleCount + 1

        local state = slot1.isActive()
        assert(state == active,
            string.format("Expected state to match toggle argument: active=%d, state=%d.", active, state))

        -- give element time to settle before changing
        unit.setTimer("delay", 0.25)
        ---------------
        -- copy to here to slot1.onToggled(active) *
        ---------------
    end
    mock:mockRegisterToggled(toggledListener, "*")
    local toggledListenerActive = function(active)
        ---------------
        -- copy from here to slot1.onToggled(active) 1
        ---------------
        _G.toggleOnCount = _G.toggleOnCount + 1
        assert(slot1.isActive() == 1, "Expected state 1 when toggled active.")
        assert(slot1.getShieldHitpoints() == slot1.getMaxShieldHitpoints(), "Expected max HP when on")
        ---------------
        -- copy to here to slot1.onToggled(active) 1
        ---------------
    end
    mock:mockRegisterToggled(toggledListenerActive, 1)
    local toggledListenerInactive = function(active)
        ---------------
        -- copy from here to slot1.onToggled(active) 0
        ---------------
        _G.toggleOffCount = _G.toggleOffCount + 1
        assert(slot1.isActive() == 0, "Expected state 0 when toggled inactive.")
        -- assert(slot1.getShieldHitpoints() == 0, "Expected 0 HP when off") -- inconsistent
        ---------------
        -- copy to here to slot1.onToggled(active) 0
        ---------------
    end
    mock:mockRegisterToggled(toggledListenerInactive, 0)

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getShieldHitpoints", "getMaxShieldHitpoints", "getStressHitpoints",
                               "getStressHitpointsRaw", "getStressRatio", "getStressRatioRaw", "getResistances",
                               "setResistances", "getResistancesRemaining", "getResistancesPool",
                               "getResistancesCooldown", "getResistancesMaxCooldown", "isVenting", "startVenting",
                               "getVentingCooldown", "getVentingMaxCooldown", "setSignalIn", "getSignalIn",
                               "stopVenting", "isActive"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "ShieldGeneratorExtraSmallGroup")
    assert(string.match(string.lower(slot1.getName()), "shield generator %w+ %[%d+%]"), slot1.getName())
    local expectedIds = {[2882830295] = true, [3696387320] = true, [254923774] = true, [2034818941] = true}
    assert(expectedIds[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())

    local data = slot1.getWidgetData()
    local expectedFields = {"elementId", "helperId", "isActive", "isVenting", "ventingCooldown", "ventingMaxCooldown",
        "ventingStartHp", "ventingTargetHp", "resistances", "antimatter", "stress", "value", "electromagnetic",
        "stress", "value", "kinetic", "stress", "value", "thermic", "stress", "value", "name", "shieldHp",
        "shieldMaxHp", "type"}
    local expectedValues = {}
    expectedValues["helperId"] = '"shield_generator"'
    expectedValues["type"] = '"shield_generator"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() >= 1400)
    assert(slot1.getMass() >= 670.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "shield_generator")

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.isActive()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)

    assert(slot1.getMaxShieldHitpoints() >= 300000)

    _G.toggleCount = 0
    _G.toggleOnCount = 0
    _G.toggleOffCount = 0

    local function stateChangeTest()
        -- ensure initial state on
        if slot1.isActive() == 0 then
            slot1.activate()
            coroutine.yield()
            assert(slot1.isActive() == 1)
        end

        -- full hp when on
        assert(slot1.getShieldHitpoints() >= 300000)

        -- reset
        _G.toggleCount = 0
        _G.toggleOnCount = 0
        _G.toggleOffCount = 0

        -- validate methods
        slot1.deactivate()
        coroutine.yield()
        assert(slot1.isActive() == 0)
        slot1.activate()
        coroutine.yield()
        assert(slot1.isActive() == 1)
        slot1.toggle()
        coroutine.yield()
        assert(slot1.isActive() == 0)

        -- assert(slot1.getShieldHitpoints() == 0, "Expected 0 HP when off") -- inconsistent

        assert(_G.toggleCount == 3, "Total toggle count: " .. _G.toggleCount)
        assert(_G.toggleOnCount == 1, "Total toggle on count: " .. _G.toggleOnCount)
        assert(_G.toggleOffCount == 2, "Total toggle off count: " .. _G.toggleOffCount)

        system.print("Success")
        unit.exit()
    end

    _G.shieldStateCoroutine = coroutine.create(stateChangeTest)
    coroutine.resume(_G.shieldStateCoroutine)

    _G.resumeCoroutine = function()
        assert(_G.shieldStateCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.shieldStateCoroutine) ~= "dead",
            "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.shieldStateCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
    end

    -- report failure if coroutine has not reached success within 5 seconds
    unit.setTimer("fail", 5)
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    -- autoCallback disabled, manually call each time
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()

    lu.assertTrue(finished)
end

os.exit(lu.LuaUnit.run())
