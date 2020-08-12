#!/usr/bin/env lua
--- Tests on MockDoorUnit.
-- @see MockDoorUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdu = require("MockDoorUnit")

TestMockDoorUnit = {}

--- Verify element class is correct.
function TestMockDoorUnit.testGetElementClass()
    local element = mdu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "DoorUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockDoorUnit.testGameBehavior()
    local mock = mdu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "DoorUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())