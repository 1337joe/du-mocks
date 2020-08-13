#!/usr/bin/env lua
--- Tests on dumocks.DoorUnit.
-- @see dumocks.DoorUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdu = require("dumocks.DoorUnit")

TestDoorUnit = {}

--- Verify element class is correct.
function TestDoorUnit.testGetElementClass()
    local element = mdu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "DoorUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestDoorUnit.skipTestGameBehavior()
    local mock = mdu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "DoorUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())