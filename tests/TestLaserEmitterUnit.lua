#!/usr/bin/env lua
--- Tests on dumocks.LaserEmitterUnit.
-- @see dumocks.LaserEmitterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mleu = require("dumocks.LaserEmitterUnit")

TestLaserEmitterUnit = {}

--- Verify element class is correct.
function TestLaserEmitterUnit.testGetElementClass()
    local element = mleu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LaserEmitterUnit")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestLaserEmitterUnit.testGameBehavior()
    local mock = mleu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LaserEmitterUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())