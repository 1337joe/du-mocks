#!/usr/bin/env lua
--- Tests on MockLandingGearUnit.
-- @see MockLandingGearUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mlgu = require("MockLandingGearUnit")

TestMockLandingGearUnit = {}

--- Verify element class is correct.
function TestMockLandingGearUnit.testGetElementClass()
    local element = mlgu:new():mockGetClosure()
    lu.fail("Not Yet Implemented")
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockLandingGearUnit.testGameBehavior()
    local mock = mlgu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())