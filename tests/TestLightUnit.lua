#!/usr/bin/env lua
--- Tests on dumocks.LightUnit.
-- @see dumocks.LightUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mlu = require("dumocks.LightUnit")

TestLightUnit = {}

--- Verify element class is correct.
function TestLightUnit.testGetElementClass()
    local element = mlu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LightUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestLightUnit.testGameBehavior()
    local mock = mlu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LightUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())