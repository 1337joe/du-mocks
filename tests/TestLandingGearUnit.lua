#!/usr/bin/env lua
--- Tests on dumocks.LandingGearUnit.
-- @see dumocks.LandingGearUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mlgu = require("dumocks.LandingGearUnit")

_G.TestLandingGearUnit = {}


--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLandingGearUnit.testConstructor()

    -- default element:
    -- ["landing gear s"] = {mass = 258.76, maxHitPoints = 1045.0}

    local gear0 = mlgu:new()
    local gear1 = mlgu:new(nil, 1, "Landing Gear S")
    local gear2 = mlgu:new(nil, 2, "invalid")
    local gear3 = mlgu:new(nil, 3, "landing gear m")

    local gearClosure0 = gear0:mockGetClosure()
    local gearClosure1 = gear1:mockGetClosure()
    local gearClosure2 = gear2:mockGetClosure()
    local gearClosure3 = gear3:mockGetClosure()

    lu.assertEquals(gearClosure0.getId(), 0)
    lu.assertEquals(gearClosure1.getId(), 1)
    lu.assertEquals(gearClosure2.getId(), 2)
    lu.assertEquals(gearClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 258.76
    lu.assertEquals(gearClosure0.getMass(), defaultMass)
    lu.assertEquals(gearClosure1.getMass(), defaultMass)
    lu.assertEquals(gearClosure2.getMass(), defaultMass)
    lu.assertNotEquals(gearClosure3.getMass(), defaultMass)
end

--- Verify element class is correct.
function _G.TestLandingGearUnit.testGetElementClass()
    local element = mlgu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LandingGearUnit")
end

--- Verify that activate leaves the gear down.
function _G.TestLandingGearUnit.testActivate()
    local mock = mlgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the gear up.
function _G.TestLandingGearUnit.testDeactivate()
    local mock = mlgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestLandingGearUnit.testToggle()
    local mock = mlgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestLandingGearUnit.testGetState()
    local mock = mlgu:new()
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
-- 1. 1x Landing Gear, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestLandingGearUnit.testGameBehavior()
    local mock = mlgu:new()
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "LandingGearUnit")

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