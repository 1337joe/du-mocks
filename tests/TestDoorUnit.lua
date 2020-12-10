#!/usr/bin/env lua
--- Tests on dumocks.DoorUnit.
-- @see dumocks.DoorUnit

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local mdu = require("dumocks.DoorUnit")
require("tests.Utilities")

_G.TestDoorUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestDoorUnit.testConstructor()

    -- default element:
    -- ["sliding door s"] = {mass = 749.15, maxHitPoints = 56.0}

    local door0 = mdu:new()
    local door1 = mdu:new(nil, 1, "Sliding Door S")
    local door2 = mdu:new(nil, 2, "invalid")
    local door3 = mdu:new(nil, 3, "reinforced sliding door")

    local doorClosure0 = door0:mockGetClosure()
    local doorClosure1 = door1:mockGetClosure()
    local doorClosure2 = door2:mockGetClosure()
    local doorClosure3 = door3:mockGetClosure()

    lu.assertEquals(doorClosure0.getId(), 0)
    lu.assertEquals(doorClosure1.getId(), 1)
    lu.assertEquals(doorClosure2.getId(), 2)
    lu.assertEquals(doorClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 749.15
    lu.assertEquals(doorClosure0.getMass(), defaultMass)
    lu.assertEquals(doorClosure1.getMass(), defaultMass)
    lu.assertEquals(doorClosure2.getMass(), defaultMass)
    lu.assertNotEquals(doorClosure3.getMass(), defaultMass)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Sliding Door S, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, setSignalIn, getSignalIn
function _G.TestDoorUnit.testGameBehavior()
    local mock = mdu:new(nil, 1)
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
    assert(slot1.getElementClass() == "DoorUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 56.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 749.15)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.getState()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.5")
    assert(slot1.getSignalIn("in") == 0.5)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "7.0")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- invalid sets to 0
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)

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
