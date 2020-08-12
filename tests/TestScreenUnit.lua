#!/usr/bin/env lua
--- Tests on dumocks.ScreenUnit.
-- @see dumocks.ScreenUnit

-- set search path to include root of project
package.path = package.path..";../dumocks/?.lua"

local lu = require("luaunit")

local msu = require("dumocks.ScreenUnit")

TestScreenUnit = {}

--- Verify element class is correct.
function TestScreenUnit.testGetElementClass()
    local element = msu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ScreenUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestScreenUnit.testGameBehavior()
    local mock = msu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "ScreenUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())