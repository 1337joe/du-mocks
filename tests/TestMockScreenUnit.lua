#!/usr/bin/env lua
--- Tests on MockScreenUnit.
-- @see MockScreenUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local msu = require("MockScreenUnit")

TestMockScreenUnit = {}

--- Verify element class is correct.
function TestMockScreenUnit.testGetElementClass()
    local element = msu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ScreenUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockScreenUnit.testGameBehavior()
    local mock = msu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "ScreenUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())