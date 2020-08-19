#!/usr/bin/env lua
--- Tests on dumocks.CounterUnit.
-- @see dumocks.CounterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.CounterUnit")

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

--- Verify element class is correct.
function _G.TestCounterUnit.testGetElementClass()
    local element = mcu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CounterUnit")
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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Counter 5, connected to Programming Board on slot1
--
-- Exercises: getElementClass, getCounterState, next
function _G.TestCounterUnit.testGameBehavior()
    local mock = mcu:new(nil, 0, "counter 5")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "CounterUnit")

    assert(slot1.getCounterState() == 0, "Active out: "..slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 1, "Active out: "..slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 2, "Active out: "..slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 3, "Active out: "..slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 4, "Active out: "..slot1.getCounterState())

    slot1.next()
    assert(slot1.getCounterState() == 0, "Active out: "..slot1.getCounterState())

    system.print("Success")
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())