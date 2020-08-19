#!/usr/bin/env lua
--- Tests on dumocks.LightUnit.
-- @see dumocks.LightUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mlu = require("dumocks.LightUnit")

_G.TestLightUnit = {}


--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLightUnit.testConstructor()

    -- default element:
    -- ["square light xs"] = {mass = 70.05, maxHitPoints = 50.0}

    local light0 = mlu:new()
    local light1 = mlu:new(nil, 1, "Square Light XS")
    local light2 = mlu:new(nil, 2, "invalid")
    local light3 = mlu:new(nil, 3, "square light l")

    local lightClosure0 = light0:mockGetClosure()
    local lightClosure1 = light1:mockGetClosure()
    local lightClosure2 = light2:mockGetClosure()
    local lightClosure3 = light3:mockGetClosure()

    lu.assertEquals(lightClosure0.getId(), 0)
    lu.assertEquals(lightClosure1.getId(), 1)
    lu.assertEquals(lightClosure2.getId(), 2)
    lu.assertEquals(lightClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 70.05
    lu.assertEquals(lightClosure0.getMass(), defaultMass)
    lu.assertEquals(lightClosure1.getMass(), defaultMass)
    lu.assertEquals(lightClosure2.getMass(), defaultMass)
    lu.assertNotEquals(lightClosure3.getMass(), defaultMass)
end

--- Verify element class is correct.
function _G.TestLightUnit.testGetElementClass()
    local element = mlu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LightUnit")
end

--- Verify that activate leaves the light on.
function _G.TestLightUnit.testActivate()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the light off.
function _G.TestLightUnit.testDeactivate()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestLightUnit.testToggle()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestLightUnit.testGetState()
    local mock = mlu:new()
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
-- 1. 1x Light, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestLightUnit.testGameBehavior()
    local mock = mlu:new()
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start
    ---------------
    assert(slot1.getElementClass() == "LightUnit")

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
    -- copy to here to unit.start
    ---------------
end

os.exit(lu.LuaUnit.run())