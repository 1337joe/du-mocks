#!/usr/bin/env lua
--- Tests on dumocks.EngineUnit.
-- @see dumocks.EngineUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local meu = require("dumocks.EngineUnit")

TestEngineUnit = {}

--- Verify element class is correct.
function TestEngineUnit.testGetElementClass()
    local element = meu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "Hovercraft")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestEngineUnit.skipTestGameBehavior()
    local mock = meu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())