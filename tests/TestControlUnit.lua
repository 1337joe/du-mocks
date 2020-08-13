#!/usr/bin/env lua
--- Tests on dumocks.ControlUnit.
-- @see dumocks.ControlUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.ControlUnit")

TestControlUnit = {}

--- Verify element class is correct.
function TestControlUnit.testGetElementClass()
    local element = mcu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "Generic")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestControlUnit.skipTestGameBehavior()
    local mock = mcu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "Generic")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())