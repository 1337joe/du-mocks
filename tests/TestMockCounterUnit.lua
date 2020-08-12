#!/usr/bin/env lua
--- Tests on MockCounterUnit.
-- @see MockCounterUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("MockCounterUnit")

TestMockCounterUnit = {}

--- Verify element class is correct.
function TestMockCounterUnit.testGetElementClass()
    local element = mcu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CounterUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockCounterUnit.testGameBehavior()
    local mock = mcu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "CounterUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())