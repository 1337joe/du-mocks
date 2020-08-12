#!/usr/bin/env lua
--- Tests on dumocks.ManualButtonUnit.
-- @see dumocks.ManualButtonUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mmbu = require("dumocks.ManualButtonUnit")

TestManualButtonUnit = {}

--- Verify element class is correct.
function TestManualButtonUnit.testGetElementClass()
    local element = mmbu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ManualButtonUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestManualButtonUnit.testGameBehavior()
    local mock = mmbu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "ManualButtonUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())