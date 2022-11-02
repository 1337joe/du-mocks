#!/usr/bin/env lua
--- Tests on dumocks.CounterUnit.
-- @see dumocks.CounterUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mcu = require("dumocks.CounterUnit")
local utilities = require("test.Utilities")

_G.TestCounterUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestCounterUnit.testConstructor()

    -- default element:
    -- ["2 counter xs"] = {mass = 9.93, maxHitPoints = 50.0, itemId = 888062905, maxCount = 2}

    local counter0 = mcu:new()
    local counter1 = mcu:new(nil, 1, "2 Counter XS")
    local counter2 = mcu:new(nil, 2, "invalid")
    local counter3 = mcu:new(nil, 3, "3 Counter XS")

    local counterClosure0 = counter0:mockGetClosure()
    local counterClosure1 = counter1:mockGetClosure()
    local counterClosure2 = counter2:mockGetClosure()
    local counterClosure3 = counter3:mockGetClosure()

    lu.assertEquals(counterClosure0.getLocalId(), 0)
    lu.assertEquals(counterClosure1.getLocalId(), 1)
    lu.assertEquals(counterClosure2.getLocalId(), 2)
    lu.assertEquals(counterClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultCount = 2
    lu.assertEquals(counter0.maxCount, defaultCount)
    lu.assertEquals(counter1.maxCount, defaultCount)
    lu.assertEquals(counter2.maxCount, defaultCount)
    lu.assertNotEquals(counter3.maxCount, defaultCount)

    local defaultId = 888062905
    lu.assertEquals(counterClosure0.getItemId(), defaultId)
    lu.assertEquals(counterClosure1.getItemId(), defaultId)
    lu.assertEquals(counterClosure2.getItemId(), defaultId)
    lu.assertNotEquals(counterClosure3.getItemId(), defaultId)
end

--- Verify get index returns a value in range.
function _G.TestCounterUnit.testGetIndex()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- + 1 for 1-indexed getIndex

    mock.maxCount = 2
    mock.activeOut = 1
    lu.assertEquals(closure.getIndex(), 1 + 1)
    lu.assertEquals(utilities.verifyDeprecated("getCounterState", closure.getCounterState), 1 + 1)
    mock.activeOut = 3 -- bigger than max count, will wrap around
    lu.assertEquals(closure.getIndex(), 1 + 1)

    -- not default element
    mock.maxCount = 10
    mock.activeOut = 3
    lu.assertEquals(closure.getIndex(), 3 + 1)
    lu.assertEquals(utilities.verifyDeprecated("getCounterState", closure.getCounterState), 3 + 1)
end

--- Verify set index functions properly.
function _G.TestCounterUnit.testSetIndex()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- - 1 for 0-indexed activeOut

    mock.maxCount = 2

    closure.setIndex(1)
    lu.assertEquals(mock.activeOut, 1 - 1)
    closure.setIndex(2)
    lu.assertEquals(mock.activeOut, 2 - 1)
    closure.setIndex(3)
    lu.assertEquals(mock.activeOut, 2 - 1)
    closure.setIndex(100)
    lu.assertEquals(mock.activeOut, 2 - 1)
    closure.setIndex(0)
    lu.assertEquals(mock.activeOut, 1 - 1)
    closure.setIndex(-1)
    lu.assertEquals(mock.activeOut, 1 - 1)

    mock.maxCount = 10
    closure.setIndex(3)
    lu.assertEquals(mock.activeOut, 3 - 1)
    closure.setIndex(100)
    lu.assertEquals(mock.activeOut, 10 - 1)
end

--- Verify nextIndex advances properly.
function _G.TestCounterUnit.testNextIndex()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    mock.maxCount = 2
    mock.activeOut = 0

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 1)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 0)

    -- not default element
    mock.maxCount = 5
    mock.activeOut = 0

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 1)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 2)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 3)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 4)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 0)

    closure.nextIndex()
    lu.assertEquals(mock.activeOut, 1)

    -- verify deprecated method this replaces
    utilities.verifyDeprecated("next", closure.next)
    lu.assertEquals(mock.activeOut, 2)
end

--- Verify results of getMaxIndex.
function _G.TestCounterUnit.testGetMaxIndex()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- - 1 for 0-indexed getMaxIndex

    local expected

    expected = 2
    mock.maxCount = expected
    lu.assertEquals(closure.getMaxIndex(), expected - 1)

    expected = 5
    mock.maxCount = expected
    lu.assertEquals(closure.getMaxIndex(), expected - 1)

    expected = 10
    mock.maxCount = expected
    lu.assertEquals(closure.getMaxIndex(), expected - 1)
end

--- Verify set signal in updates state.
function _G.TestCounterUnit.testSetSignalIn()
    lu.skip("No longer functional")
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- no error thrown
    closure.setSignalIn("INVALID", "blah")

    local previousState

    -- expected values
    previousState = mock.activeOut
    closure.setSignalIn("in", 0.0)
    lu.assertEquals(mock.plugIn, 0.0)
    lu.assertEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", 1.0)
    lu.assertEquals(mock.plugIn, 1.0)
    lu.assertNotEquals(mock.activeOut, previousState)

    -- invalid and out of range values (alternating high-low results to allow state advancement)
    previousState = mock.activeOut
    closure.setSignalIn("in", -1.0)
    lu.assertEquals(mock.plugIn, 0.0)
    lu.assertEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", 5.0)
    lu.assertEquals(mock.plugIn, 1.0)
    lu.assertNotEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", "words")
    lu.assertEquals(mock.plugIn, 0.0)
    lu.assertEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", nil)
    lu.assertEquals(mock.plugIn, 0.0)
    lu.assertEquals(mock.activeOut, previousState)

    -- weirdness with fractional values (always advances if different)
    previousState = mock.activeOut
    closure.setSignalIn("in", 0.7)
    lu.assertEquals(mock.plugIn, 0.7)
    lu.assertNotEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", "0.7")
    lu.assertEquals(mock.plugIn, 0.7)
    lu.assertEquals(mock.activeOut, previousState)

    previousState = mock.activeOut
    closure.setSignalIn("in", 0.5)
    lu.assertEquals(mock.plugIn, 0.5)
    lu.assertNotEquals(mock.activeOut, previousState)
end

--- Verify get signal in aligns with state.
function _G.TestCounterUnit.testGetSignalIn()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- capitalization matters
    lu.assertEquals(closure.getSignalIn("IN"), -1.0)

    -- expected values
    mock.plugIn = 1
    lu.assertEquals(closure.getSignalIn("in"), 1.0)

    mock.plugIn = 0
    lu.assertEquals(closure.getSignalIn("in"), 0.0)

    -- unexpectedly valid values
    mock.plugIn = 0.5
    lu.assertEquals(closure.getSignalIn("in"), 0.5)

    mock.plugIn = "0.7"
    lu.assertEquals(closure.getSignalIn("in"), 0.7)

    -- invalid values
    mock.plugIn = nil
    lu.assertEquals(closure.getSignalIn("in"), 0.0)

    mock.plugIn = "words"
    lu.assertEquals(closure.getSignalIn("in"), 0.0)
end

--- Verify get signal out aligns with state.
function _G.TestCounterUnit.testGetSignalOut()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    lu.assertEquals(mock.maxCount, 2) -- default

    -- invalid indices
    lu.assertEquals(closure.getSignalOut("OUT-signal-blah"), -1.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-3"), -1.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-10"), -1.0)

    -- verify reflects current state
    mock.activeOut = 0
    lu.assertEquals(closure.getSignalOut("OUT-signal-0"), 1.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-1"), 0.0)
    mock.activeOut = 1
    lu.assertEquals(closure.getSignalOut("OUT-signal-0"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-1"), 1.0)

    -- not default element
    mock.maxCount = 10
    -- verify reflects current state
    mock.activeOut = 0
    lu.assertEquals(closure.getSignalOut("OUT-signal-0"), 1.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-1"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-2"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-3"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-4"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-5"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-6"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-7"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-8"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-9"), 0.0)
    mock.activeOut = 8
    lu.assertEquals(closure.getSignalOut("OUT-signal-0"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-1"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-2"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-3"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-4"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-5"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-6"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-7"), 0.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-8"), 1.0)
    lu.assertEquals(closure.getSignalOut("OUT-signal-9"), 0.0)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Counter 5, connected to Programming Board on slot1
--
-- Nothing should be connected to the "in" plug.
--
-- Exercises: getClass, getCounterState, getIndex, setIndex, nextIndex, getMaxIndex, setSignalIn, getSignalIn, getSignalOut
function _G.TestCounterUnit.testGameBehavior()
    local mock = mcu:new(nil, 1, "5 counter xs")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getCounterState", "getIndex", "setIndex", "nextIndex", "next", "getMaxIndex",
                               "getSignalOut", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "CounterUnit")
    local expectedIds = {[888062905] = true, [888062906] = true, [888062908] = true, [888062910] = true, [888063487] = true}
    assert(expectedIds[slot1.getItemId()])
    local maxIndex = string.match(string.lower(slot1.getName()), "(%d+) counter xs %[%d+%]")
    assert(maxIndex, slot1.getName())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 9.93)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.getIndex()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getIndex() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getIndex() == initialState)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getIndex() == initialState)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getIndex() == initialState)

    local actualMax = slot1.getMaxIndex() + 1
    assert(actualMax == tonumber(maxIndex))

    local function checkSignals()
        local expectedIndex = slot1.getIndex()
        local expected, actual
        for signalIndex = 0, slot1.getMaxIndex() do
            if expectedIndex - 1 == signalIndex then
                expected = 1.0
            else
                expected = 0.0
            end
            actual = slot1.getSignalOut("OUT-signal-" .. signalIndex)
            assert(actual == expected,
                string.format("Expected index %d, signal index %d returned %d instead of %d",
                expectedIndex, signalIndex, actual, expected))
        end
    end

    slot1.setIndex(actualMax)
    assert(slot1.getIndex() == actualMax)
    checkSignals()

    slot1.setIndex(1)
    assert(slot1.getIndex() == 1, "Active out: " .. slot1.getIndex())
    checkSignals()

    slot1.setIndex(1)
    slot1.nextIndex()
    assert(slot1.getIndex() == 2, "Active out: " .. slot1.getIndex())
    checkSignals()

    -- wraps around
    slot1.setIndex(actualMax)
    slot1.nextIndex()
    assert(slot1.getIndex() == 1)
    checkSignals()

    -- out of bounds
    slot1.setIndex(25)
    assert(slot1.getIndex() == actualMax)
    slot1.setIndex(-1)
    assert(slot1.getIndex() == 1)
    slot1.setIndex(0)
    assert(slot1.getIndex() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
