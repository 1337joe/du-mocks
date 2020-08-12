#!/usr/bin/env lua
--- Tests on dumocks.PressureTileUnit.
-- @see dumocks.PressureTileUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mptu = require("dumocks.PressureTileUnit")

TestPressureTileUnit = {}

--- Verify element class is correct.
function TestPressureTileUnit.testGetElementClass()
    local element = mptu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "PressureTileUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestPressureTileUnit.testGameBehavior()
    local mock = mptu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "PressureTileUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())