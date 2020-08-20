#!/usr/bin/env lua
--- Tests on dumocks.WarpDriveUnit.
-- @see dumocks.WarpDriveUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mwdu = require("dumocks.WarpDriveUnit")

TestWarpDriveUnit = {}

--- Verify element class is correct.
function TestWarpDriveUnit.testGetElementClass()
    local element = mwdu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "WarpDriveUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestWarpDriveUnit.skipTestGameBehavior()
    local mock = mwdu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "WarpDriveUnit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())