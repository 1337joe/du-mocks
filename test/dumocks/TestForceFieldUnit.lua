#!/usr/bin/env lua
--- Tests on dumocks.ForceFieldUnit.
-- @see dumocks.ForceFieldUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mffu = require("dumocks.ForceFieldUnit")
require("test.Utilities")

_G.TestForceFieldUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestForceFieldUnit.testConstructor()

    -- default element:
    -- ["force field xs"] = {mass = 110.62, maxHitPoints = 50.0}

    local field0 = mffu:new()
    local field1 = mffu:new(nil, 1, "Force Field XS")
    local field2 = mffu:new(nil, 2, "invalid")
    local field3 = mffu:new(nil, 3, "force field s")

    local fieldClosure0 = field0:mockGetClosure()
    local fieldClosure1 = field1:mockGetClosure()
    local fieldClosure2 = field2:mockGetClosure()
    local fieldClosure3 = field3:mockGetClosure()

    lu.assertEquals(fieldClosure0.getId(), 0)
    lu.assertEquals(fieldClosure1.getId(), 1)
    lu.assertEquals(fieldClosure2.getId(), 2)
    lu.assertEquals(fieldClosure3.getId(), 3)

    -- all force fields share attributes, can't verify element selection
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Force Field, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, setSignalIn, getSignalIn
function _G.TestForceFieldUnit.testGameBehavior()
    local mock = mffu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "ForceFieldUnit")
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 110.62)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == 1)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(slot1.getState() == 1)
    slot1.setSignalIn("in", "0.5")
    assert(slot1.getSignalIn("in") == 0.5)
    assert(slot1.getState() == 1)
    slot1.setSignalIn("in", "0.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", "7.0")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == 1)
    -- invalid sets to 0
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)

    -- ensure initial state
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
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
