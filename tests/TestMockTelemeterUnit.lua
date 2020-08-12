#!/usr/bin/env lua
--- Tests on MockTelemeterUnit.
-- @see MockTelemeterUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mtu = require("MockTelemeterUnit")

TestMockTelemeterUnit = {}

--- Verify element class is correct.
function TestMockTelemeterUnit.testGetElementClass()
    local element = mtu:new():mockGetClosure()
    lu.fail("Not Yet Implemented")
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockTelemeterUnit.testGameBehavior()
    local mock = mtu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())