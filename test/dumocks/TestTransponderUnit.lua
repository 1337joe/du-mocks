#!/usr/bin/env lua
--- Tests on dumocks.TransponderUnit.
-- @see dumocks.TransponderUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mtu = require("dumocks.TransponderUnit")
require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestTransponderUnit = AbstractTestElementWithToggle

function _G.TestTransponderUnit.getTestElement()
    return mtu:new()
end

function _G.TestTransponderUnit.getStateFunction(closure)
    return closure.isActive
end

function _G.TestTransponderUnit.getActivateFunction(closure)
    return closure.activate
end

function _G.TestTransponderUnit.getDeactivateFunction(closure)
    return closure.deactivate
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestTransponderUnit.testConstructor()

    -- default element:
    -- ["transponder xs"] = {mass = 340, maxHitPoints = 50.0, itemId = 63667997}

    local trans1 = mtu:new(nil, 1, "Transponder")
    local trans2 = mtu:new(nil, 2, "invalid")
    local trans3 = mtu:new()

    local trans1Closure = trans1:mockGetClosure()
    local trans2Closure = trans2:mockGetClosure()
    local trans3Closure = trans3:mockGetClosure()

    lu.assertEquals(trans1Closure.getLocalId(), 1)
    lu.assertEquals(trans2Closure.getLocalId(), 2)
    lu.assertEquals(trans3Closure.getLocalId(), 0)

    -- prove default element is selected
    local defaultMass = 340
    lu.assertEquals(trans1Closure.getMass(), defaultMass)
    lu.assertEquals(trans2Closure.getMass(), defaultMass)
    lu.assertEquals(trans3Closure.getMass(), defaultMass)

    -- do some damage, max hit points is 50 (prove independance)
    trans1.hitPoints = 25.0
    trans2.hitPoints = 12.5
    trans3.hitPoints = 0.25

    lu.assertEquals(trans1Closure.getIntegrity(), 50.0)
    lu.assertEquals(trans2Closure.getIntegrity(), 25.0)
    lu.assertEquals(trans3Closure.getIntegrity(), 0.5)

    local defaultId = 63667997
    lu.assertEquals(trans1Closure.getItemId(), defaultId)
    lu.assertEquals(trans2Closure.getItemId(), defaultId)
    lu.assertEquals(trans3Closure.getItemId(), defaultId)
end

--- Verify setting tags follows spec.
function _G.TestTransponderUnit.testSetTags()
    local mock = mtu:new()
    local closure = mock:mockGetClosure()

    local initialTags = {"tags", "to", "override"}
    local expectedResult, actualResult, expectedTags

    expectedTags = {}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags()
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags({})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags({""})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {"valid"}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags({"valid"})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {"multiple", "valid"}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags({"multiple", "valid"})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {"too", "many", "tags", "to", "put", "in", "a", "single"}
    expectedResult = 1
    mock.tags = initialTags
    actualResult = closure.setTags({"too", "many", "tags", "to", "put", "in", "a", "single", "transponder"})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)

    expectedTags = {"tags", "to", "override"}
    expectedResult = 0
    mock.tags = initialTags
    actualResult = closure.setTags({"i n v a l i d"})
    lu.assertEquals(actualResult, expectedResult)
    lu.assertEquals(mock.tags, expectedTags)
end

--- Verify getting tags works.
function _G.TestTransponderUnit.testGetTags()
    local mock = mtu:new()
    local closure = mock:mockGetClosure()

    local expected, actual

    expected = {}
    mock.tags = expected
    actual = closure.getTags()
    lu.assertEquals(actual, expected)

    expected = {"one"}
    mock.tags = expected
    actual = closure.getTags()
    lu.assertEquals(actual, expected)

    expected = {"multiple", "valid", "tags"}
    mock.tags = expected
    actual = closure.getTags()
    lu.assertEquals(actual, expected)
end

--- Verify toggled works without errors.
function _G.TestTransponderUnit.testToggled()
    local mock = mtu:new()
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
    expectedState, expectedActive = 1, 0 -- lags behind active
    mock.state = true
    mock:mockDoToggled(expectedActive)
    lu.assertTrue(called)
    lu.assertFalse(calledOn)
    lu.assertTrue(calledOff)
    lu.assertEquals(state, expectedState)
    lu.assertEquals(actualActive, expectedActive)

    called, calledOn, calledOff = false, false, false
    expectedState, expectedActive = 0, 1 -- lags behind active
    mock.state = false
    mock:mockDoToggled(expectedActive)
    lu.assertTrue(called)
    lu.assertTrue(calledOn)
    lu.assertFalse(calledOff)
    lu.assertEquals(state, expectedState)
    lu.assertEquals(actualActive, expectedActive)
end

--- Verify toggled works with and propagates errors.
function _G.TestTransponderUnit.testToggledError()
    local mock = mtu:new()

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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Transponder, connected to Programming Board on slot1
--
-- Exercises: getClass, deactivate, activate, toggle, isActive, EVENT_toggled, setSignalIn, getSignalIn
function _G.TestTransponderUnit.testGameBehavior()
    local mock = mtu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    local finished = false

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
        finished = true
    end
    unit.setTimer = function()
    end
    unit.stopTimer = function()
    end
    local system = {}
    system.print = function()
    end

    -- not called by mock
    local tickFail = function()
        ---------------
        -- copy from here to unit.tick(timerId) fail
        ---------------
        -- should hit exit call from coroutine before this ticks
        system.print("Failed")
        unit.exit()
        ---------------
        -- copy to here to unit.tick(timerId) fail
        ---------------
    end
    local tickDelay = function()
        ---------------
        -- copy from here to unit.tick(timerId) delay
        ---------------
        unit.stopTimer("delay")
        _G.resumeCoroutine()
        ---------------
        -- copy to here to unit.tick(timerId) delay
        ---------------
    end

    -- toggled handlers
    local toggledListener = function(active)
        ---------------
        -- copy from here to slot1.toggled(active) *
        ---------------
        _G.toggleCount = _G.toggleCount + 1

        local state = slot1.isActive()
        assert(state ~= active,
            string.format("Expected state to NOT match toggle argument: active=%d, state=%d.", active, state))
        ---------------
        -- copy to here to slot1.toggled(active) *
        ---------------
    end
    mock:mockRegisterToggled(toggledListener, "*")
    local toggledListenerActive = function(active)
        ---------------
        -- copy from here to slot1.toggled(active) 1
        ---------------
        _G.toggleOnCount = _G.toggleOnCount + 1
        ---------------
        -- copy to here to slot1.toggled(active) 1
        ---------------
    end
    mock:mockRegisterToggled(toggledListenerActive, 1)
    local toggledListenerInactive = function(active)
        ---------------
        -- copy from here to slot1.toggled(active) 0
        ---------------
        _G.toggleOffCount = _G.toggleOffCount + 1
        ---------------
        -- copy to here to slot1.toggled(active) 0
        ---------------
    end
    mock:mockRegisterToggled(toggledListenerInactive, 0)

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"isActive", "setTags", "getTags", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "CombatDefense")
    assert(slot1.getItemId() == 63667997)
    assert(string.match(string.lower(slot1.getName()), "transponder xs %[%d+%]"), slot1.getName())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 340)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    _G.initialState = slot1.isActive()

    -- play with set signal, has no actual effect on state when set programmatically
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

    local function coroutineTest()
        local delay = 0.5
        local function yieldWithDelay()
            unit.setTimer("delay", delay)
            coroutine.yield()
        end

        local result, tags
        result = slot1.setTags()
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(0 == #tags, string.format("Received %d tags", #tags))

        local result, tags
        result = slot1.setTags({})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(0 == #tags, string.format("Received %d tags", #tags))

        local result, tags
        result = slot1.setTags({""})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(0 == #tags, string.format("Received %d tags", #tags))

        local result, tags
        result = slot1.setTags({"with space"})
        assert(result == 0)
        yieldWithDelay()
        -- failed to write, should still have previous count
        tags = slot1.getTags()
        assert(0 == #tags, string.format("Received %d tags", #tags))

        result = slot1.setTags({"tag1"})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(1 == #tags, string.format("Received %d tags", #tags))
        assert("tag1" == tags[1], tags[1])

        result = slot1.setTags({"tag1", "tag2"})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(2 == #tags, string.format("Received %d tags", #tags))
        assert("tag1" == tags[1], tags[1])
        assert("tag2" == tags[2], tags[2])

        result = slot1.setTags({"tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8"})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(8 == #tags, string.format("Received %d tags", #tags))

        result = slot1.setTags({"adding", "too", "many", "tags", "truncates", "instead", "of", "throwing", "errors"})
        assert(result == 1)
        yieldWithDelay()
        tags = slot1.getTags()
        assert(8 == #tags, string.format("Received %d tags", #tags))
        assert("adding" == tags[1], tags[1])
        assert("throwing" == tags[8], tags[8])

        -- validate toggle methods and event handler
        delay = 0.5

        -- define counters
        _G.toggleCount = 0
        _G.toggleOnCount = 0
        _G.toggleOffCount = 0

        -- ensure initial state on
        if slot1.isActive() == 0 then
            slot1.toggle()
            yieldWithDelay()
            assert(slot1.isActive() == 1)
        end

        -- reset counters in case initial state was off
        _G.toggleCount = 0
        _G.toggleOnCount = 0
        _G.toggleOffCount = 0

        slot1.deactivate()
        yieldWithDelay()
        assert(slot1.isActive() == 0)
        slot1.activate()
        yieldWithDelay()
        assert(slot1.isActive() == 1)
        slot1.toggle()
        yieldWithDelay()
        assert(slot1.isActive() == 0)

        assert(_G.toggleCount == 3, "Total toggle count: " .. _G.toggleCount)
        assert(_G.toggleOnCount == 1, "Total toggle on count: " .. _G.toggleOnCount)
        assert(_G.toggleOffCount == 2, "Total toggle off count: " .. _G.toggleOffCount)

        system.print("Success")
        unit.exit()
    end

    _G.activeCoroutine = coroutine.create(coroutineTest)
    coroutine.resume(_G.activeCoroutine)

    _G.resumeCoroutine = function()
        assert(_G.activeCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.activeCoroutine) ~= "dead",
            "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.activeCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
    end

    -- report failure if coroutine has not reached success within 5 seconds
    unit.setTimer("fail", 10)
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    -- tags
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()

    -- toggles
    tickDelay()
    tickDelay()
    tickDelay()
    tickDelay()

    lu.assertTrue(finished)
end

os.exit(lu.LuaUnit.run())
