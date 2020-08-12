#!/usr/bin/env lua
--- Tests on MockManualButtonUnit.
-- @see MockManualButtonUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mmbu = require("MockManualButtonUnit")

TestMockManualButtonUnit = {}

--- Verify element class is correct.
function TestMockManualButtonUnit.testGetElementClass()
    local element = mmbu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ManualButtonUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockManualButtonUnit.testGameBehavior()
    local mock = mmbu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "ManualButtonUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())