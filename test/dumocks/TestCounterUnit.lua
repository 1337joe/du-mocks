#!/usr/bin/env lua
--- Tests on dumocks.CounterUnit.
-- @see dumocks.CounterUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.CounterUnit")
require("test.Utilities")

_G.TestCounterUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestCounterUnit.testConstructor()

    -- default element:
    -- ["counter 2"] = {mass = 9.93, maxHitPoints = 50.0, maxCount = 2}

    local counter0 = mcu:new()
    local counter1 = mcu:new(nil, 1, "Counter 2")
    local counter2 = mcu:new(nil, 2, "invalid")
    local counter3 = mcu:new(nil, 3, "Counter 3")

    local counterClosure0 = counter0:mockGetClosure()
    local counterClosure1 = counter1:mockGetClosure()
    local counterClosure2 = counter2:mockGetClosure()
    local counterClosure3 = counter3:mockGetClosure()

    lu.assertEquals(counterClosure0.getId(), 0)
    lu.assertEquals(counterClosure1.getId(), 1)
    lu.assertEquals(counterClosure2.getId(), 2)
    lu.assertEquals(counterClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultCount = 2
    lu.assertEquals(counter0.maxCount, defaultCount)
    lu.assertEquals(counter1.maxCount, defaultCount)
    lu.assertEquals(counter2.maxCount, defaultCount)
    lu.assertNotEquals(counter3.maxCount, defaultCount)
end

--- Verify get counter state returns a value in range.
function _G.TestCounterUnit.testGetCounterState()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    lu.assertEquals(mock.maxCount, 2) -- default

    mock.activeOut = 1
    lu.assertEquals(closure.getCounterState(), 1)
    mock.activeOut = 3 -- bigger than max count, will wrap around
    lu.assertEquals(closure.getCounterState(), 1)

    -- not default element
    mock.maxCount = 10
    mock.activeOut = 3
    lu.assertEquals(closure.getCounterState(), 3)
end

--- Verify next advances properly.
function _G.TestCounterUnit.testNext()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    lu.assertEquals(mock.maxCount, 2) -- default
    mock.activeOut = 0

    closure.next()
    lu.assertEquals(mock.activeOut, 1)

    closure.next()
    lu.assertEquals(mock.activeOut, 0)

    -- not default element
    mock.maxCount = 5
    mock.activeOut = 0

    closure.next()
    lu.assertEquals(mock.activeOut, 1)

    closure.next()
    lu.assertEquals(mock.activeOut, 2)

    closure.next()
    lu.assertEquals(mock.activeOut, 3)

    closure.next()
    lu.assertEquals(mock.activeOut, 4)

    closure.next()
    lu.assertEquals(mock.activeOut, 0)

    closure.next()
    lu.assertEquals(mock.activeOut, 1)
end

--- Verify set signal in updates state.
function _G.TestCounterUnit.testSetSignalIn()
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
-- Exercises: getElementClass, getCounterState, next, setSignalIn, getSignalIn, getSignalOut
function _G.TestCounterUnit.testGameBehavior()
    local mock = mcu:new(nil, 1, "counter 5")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getCounterState", "next", "getSignalOut", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "CounterUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 9.93)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- advance counter using in signal, needs to not actually be linked to set value
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    local oldState = slot1.getCounterState()
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(oldState ~= slot1.getCounterState())
    oldState = slot1.getCounterState()
    -- weirdness with assigning fractions between 0 and 1: advances and sets to fractional value
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(oldState ~= slot1.getCounterState())
    oldState = slot1.getCounterState()
    -- doesn't advance if same number
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(oldState == slot1.getCounterState())
    oldState = slot1.getCounterState()
    -- out of 0-1 range sets to 0 or 1 and advances according to stored value
    slot1.setSignalIn("in", -1)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(oldState == slot1.getCounterState())
    oldState = slot1.getCounterState()
    slot1.setSignalIn("in", 5)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(oldState ~= slot1.getCounterState())
    oldState = slot1.getCounterState()
    -- string that can be converted to number behaves like number
    slot1.setSignalIn("in", "-3")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(oldState == slot1.getCounterState())
    oldState = slot1.getCounterState()
    slot1.setSignalIn("in", "7")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(oldState ~= slot1.getCounterState())
    oldState = slot1.getCounterState()
    slot1.setSignalIn("in", "0.7")
    assert(slot1.getSignalIn("in") == 0.7)
    assert(oldState ~= slot1.getCounterState())
    oldState = slot1.getCounterState()
    -- setting to non-numeric value sets to 0 and doesn't advance
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(oldState == slot1.getCounterState())
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(oldState == slot1.getCounterState())

    -- verify incorrect slot names are harmless
    slot1.setSignalIn("invalid", 1.0)
    assert(slot1.getSignalIn("invalid") == -1.0)
    assert(slot1.getSignalOut("invalid") == -1.0)

    -- reset
    while slot1.getCounterState() ~= 0 do
        slot1.next()
    end

    assert(slot1.getCounterState() == 0, "Active out: " .. slot1.getCounterState())

    assert(slot1.getSignalOut("OUT-signal-0") == 1.0)
    assert(slot1.getSignalOut("OUT-signal-1") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-2") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-3") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-4") == 0.0)

    slot1.next()
    assert(slot1.getCounterState() == 1, "Active out: " .. slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 2, "Active out: " .. slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 3, "Active out: " .. slot1.getCounterState())

    assert(slot1.getSignalOut("OUT-signal-0") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-1") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-2") == 0.0)
    assert(slot1.getSignalOut("OUT-signal-3") == 1.0)
    assert(slot1.getSignalOut("OUT-signal-4") == 0.0)

    slot1.next()
    assert(slot1.getCounterState() == 4, "Active out: " .. slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 0, "Active out: " .. slot1.getCounterState())

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
