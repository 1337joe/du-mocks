#!/usr/bin/env lua
--- Tests on dumocks.DetectionZoneUnit.
-- @see dumocks.DetectionZoneUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdzu = require("dumocks.DetectionZoneUnit")

TestDetectionZoneUnit = {}

--- Verify element class is correct.
function TestDetectionZoneUnit.testGetElementClass()
    local element = mdzu:new():mockGetClosure()
    lu.fail("Not Yet Implemented")
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestDetectionZoneUnit.testGameBehavior()
    local mock = mdzu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())