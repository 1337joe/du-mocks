#!/usr/bin/env lua
--- Tests on MockLaserEmitterUnit.
-- @see MockLaserEmitterUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mleu = require("MockLaserEmitterUnit")

TestMockLaserEmitterUnit = {}

--- Verify element class is correct.
function TestMockLaserEmitterUnit.testGetElementClass()
    local element = mleu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LaserEmitterUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestMockLaserEmitterUnit.testGameBehavior()
    local mock = mleu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LaserEmitterUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())