#!/usr/bin/env lua
--- Tests on MockAntiGravityGeneratorUnit.
-- @see MockAntiGravityGeneratorUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local maggu = require("MockAntiGravityGeneratorUnit")

TestMockAntiGravityGeneratorUnit = {}

--- Verify element class is correct.
function TestMockAntiGravityGeneratorUnit.testGetElementClass()
    local element = maggu:new():mockGetClosure()
    lu.fail("Not Yet Implemented")
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockAntiGravityGeneratorUnit.testGameBehavior()
    local mock = maggu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())