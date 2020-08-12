#!/usr/bin/env lua
--- Tests on dumocks.ForceFieldUnit.
-- @see dumocks.ForceFieldUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mffu = require("dumocks.ForceFieldUnit")

TestForceFieldUnit = {}

--- Verify element class is correct.
function TestForceFieldUnit.testGetElementClass()
    local element = mffu:new():mockGetClosure()
    lu.fail("Not Yet Implemented")
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestForceFieldUnit.testGameBehavior()
    local mock = mffu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())