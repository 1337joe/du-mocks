#!/usr/bin/env lua
--- Tests on dumocks.ForceFieldUnit.
-- @see dumocks.ForceFieldUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mffu = require("dumocks.ForceFieldUnit")

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

--- Verify element class is correct.
function _G.TestForceFieldUnit.testGetElementClass()
    local element = mffu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ForceFieldUnit")
end

--- Verify that activate leaves the force field on.
function _G.TestForceFieldUnit.testActivate()
    local mock = mffu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the force field off.
function _G.TestForceFieldUnit.testDeactivate()
    local mock = mffu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestForceFieldUnit.testToggle()
    local mock = mffu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestForceFieldUnit.testGetState()
    local mock = mffu:new()
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
-- 1. 1x Force Field, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestForceFieldUnit.testGameBehavior()
    local mock = mffu:new()
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "ForceFieldUnit")

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