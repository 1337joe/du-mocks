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
function TestDoorUnit.testGameBehavior()
    local mock = mdu:new()
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "DoorUnit")

    -- ensure initial state, set up globals
    slot1.deactivate()
    assert(slot1.getState() == 0)

    -- validate methods
    slot1.activate()
    assert(slot1.getState() == 1)
    slot1.deactivate()
    assert(slot1.getState() == 0)
    slot1.toggle()
    assert(slot1.getState() == 1)

    system.print("Success")
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())