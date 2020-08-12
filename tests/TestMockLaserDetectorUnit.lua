#!/usr/bin/env lua
--- Tests on MockLaserDetectorUnit.
-- @see MockLaserDetectorUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mldu = require("MockLaserDetectorUnit")

TestMockLaserDetectorUnit = {}

--- Verify element class is correct.
function TestMockLaserDetectorUnit.testGetElementClass()
    local element = mldu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LaserDetectorUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockLaserDetectorUnit.testGameBehavior()
    local mock = mldu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LaserDetectorUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())