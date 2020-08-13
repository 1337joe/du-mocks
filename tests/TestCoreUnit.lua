#!/usr/bin/env lua
--- Tests on dumocks.CoreUnit.
-- @see dumocks.CoreUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.CoreUnit")

TestCoreUnit = {}

--- Verify element class is correct.
function TestCoreUnit.testGetElementClass()
    local element = mcu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CoreUnitDynamic")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestCoreUnit.skipTestGameBehavior()
    local mock = mcu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "CoreUnitDynamic")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())