#!/usr/bin/env lua
--- Tests on dumocks.IndustryUnit.
-- @see dumocks.IndustryUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local miu = require("dumocks.IndustryUnit")

TestIndustryUnit = {}

--- Verify element class is correct.
function TestIndustryUnit.testGetElementClass()
    local element = miu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "IndustryUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestIndustryUnit.skipTestGameBehavior()
    local mock = miu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "IndustryUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())