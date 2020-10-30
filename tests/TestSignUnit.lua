#!/usr/bin/env lua
--- Tests on dumocks.SignUnit.
-- @see dumocks.SignUnit

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local msu = require("dumocks.SignUnit")

_G.TestSignUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestSignUnit.testConstructor()

    -- default element:
    -- ["sign xs"] = {mass = 18.67, maxHitPoints = 50.0}

    local sign0 = msu:new()
    local sign1 = msu:new(nil, 1, "Sign XS")
    local sign2 = msu:new(nil, 2, "invalid")
    local sign3 = msu:new(nil, 3, "vertical sign m")

    local signClosure0 = sign0:mockGetClosure()
    local signClosure1 = sign1:mockGetClosure()
    local signClosure2 = sign2:mockGetClosure()
    local signClosure3 = sign3:mockGetClosure()

    lu.assertEquals(signClosure0.getId(), 0)
    lu.assertEquals(signClosure1.getId(), 1)
    lu.assertEquals(signClosure2.getId(), 2)
    lu.assertEquals(signClosure3.getId(), 3)

    -- all signs share attributes, can't verify element selection
end

--- Verify element class is correct.
function _G.TestSignUnit.testGetElementClass()
    local element = msu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ScreenSignUnit")
end

--- Verify that activate leaves the sign on.
function _G.TestSignUnit.testActivate()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the sign off.
function _G.TestSignUnit.testDeactivate()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestSignUnit.testToggle()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestSignUnit.testGetState()
    local mock = msu:new()
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
-- 1. 1x sign, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestSignUnit.testGameBehavior()
    local mock = msu:new()
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.start
    ---------------
    assert(slot1.getElementClass() == "ScreenSignUnit")

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
    unit.exit()
    ---------------
    -- copy to here to unit.start
    ---------------
end

os.exit(lu.LuaUnit.run())
