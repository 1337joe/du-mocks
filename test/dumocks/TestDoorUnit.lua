#!/usr/bin/env lua
--- Tests on dumocks.DoorUnit.
-- @see dumocks.DoorUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mdu = require("dumocks.DoorUnit")
require("test.Utilities")
local TestElementWithToggle = require("test.dumocks.TestElementWithToggle")

_G.TestDoorUnit = TestElementWithToggle

function _G.TestDoorUnit.getTestElement()
    return mdu:new()
end

function _G.TestDoorUnit.getStateFunction(closure)
    return closure.isOpen
end

function _G.TestDoorUnit.getActivateFunction(closure)
    return closure.open
end

function _G.TestDoorUnit.getDeactivateFunction(closure)
    return closure.close
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestDoorUnit.testConstructor()

    -- default element:
    -- ["sliding door s"] = {mass = 749.15, maxHitPoints = 56.0, itemId = 201196316}

    local door0 = mdu:new()
    local door1 = mdu:new(nil, 1, "Sliding Door S")
    local door2 = mdu:new(nil, 2, "invalid")
    local door3 = mdu:new(nil, 3, "reinforced sliding door")

    local doorClosure0 = door0:mockGetClosure()
    local doorClosure1 = door1:mockGetClosure()
    local doorClosure2 = door2:mockGetClosure()
    local doorClosure3 = door3:mockGetClosure()

    lu.assertEquals(doorClosure0.getLocalId(), 0)
    lu.assertEquals(doorClosure1.getLocalId(), 1)
    lu.assertEquals(doorClosure2.getLocalId(), 2)
    lu.assertEquals(doorClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 749.15
    lu.assertEquals(doorClosure0.getMass(), defaultMass)
    lu.assertEquals(doorClosure1.getMass(), defaultMass)
    lu.assertEquals(doorClosure2.getMass(), defaultMass)
    lu.assertNotEquals(doorClosure3.getMass(), defaultMass)

    local defaultId = 201196316
    lu.assertEquals(doorClosure0.getItemId(), defaultId)
    lu.assertEquals(doorClosure1.getItemId(), defaultId)
    lu.assertEquals(doorClosure2.getItemId(), defaultId)
    lu.assertNotEquals(doorClosure3.getItemId(), defaultId)
end

--- Tests to verify the inherited functionality of ElementWithToggle.
function _G.TestDoorUnit.testElementWithToggle()
    local mock = mdu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.open()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.open()
    lu.assertTrue(mock.state)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Sliding Door S, connected to Programming Board on slot1
--
-- Exercises: getElementClass, open, close, toggle, isOpen, setSignalIn, getSignalIn
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
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"open", "close", "isOpen", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "DoorUnit")
    assert(string.match(string.lower(slot1.getName()), "sliding door s %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 201196316, slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 56.0)
    assert(slot1.getMass() == 749.15)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.isOpen()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isOpen() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isOpen() == initialState)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isOpen() == initialState)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isOpen() == initialState)

    -- ensure initial state
    slot1.close()
    assert(slot1.isOpen() == 0)

    -- validate methods
    slot1.open()
    assert(slot1.isOpen() == 1)
    slot1.close()
    assert(slot1.isOpen() == 0)
    slot1.toggle()
    assert(slot1.isOpen() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
