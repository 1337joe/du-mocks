#!/usr/bin/env lua
--- Tests on dumocks.DoorUnit.
-- @see dumocks.DoorUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdu = require("dumocks.DoorUnit")

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

--- Verify element class is correct.
function _G.TestDoorUnit.testGetElementClass()
    local element = mdu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "DoorUnit")
end

--- Verify that activate leaves the door open.
function _G.TestDoorUnit.testActivate()
    local mock = mdu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the door closed.
function _G.TestDoorUnit.testDeactivate()
    local mock = mdu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestDoorUnit.testToggle()
    local mock = mdu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestDoorUnit.testGetState()
    local mock = mdu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Door, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestDoorUnit.testGameBehavior()
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