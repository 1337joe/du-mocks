#!/usr/bin/env lua
--- Tests on dumocks.AntiGravityGeneratorUnit.
-- @see dumocks.AntiGravityGeneratorUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local maggu = require("dumocks.AntiGravityGeneratorUnit")

_G.TestAntiGravityGeneratorUnit = {}

--- Verify element class is correct.
function _G.TestAntiGravityGeneratorUnit.skipTestGetElementClass()
    local element = maggu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "Unit")
end

--- Verify that activate leaves the AGG on.
function _G.TestAntiGravityGeneratorUnit.testActivate()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the AGG off.
function _G.TestAntiGravityGeneratorUnit.testDeactivate()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestAntiGravityGeneratorUnit.testToggle()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestAntiGravityGeneratorUnit.testGetState()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
end

--- Verify that set base altitude properly sets a value.
function _G.TestAntiGravityGeneratorUnit.testSetBaseAltitude()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    local expected

    mock.targetAltitude = 1000

    expected = 1600
    closure.setBaseAltitude(expected)
    lu.assertEquals(mock.targetAltitude, expected)
    lu.assertNotEquals(mock.baseAltitude, expected)

    expected = 16000
    closure.setBaseAltitude(expected)
    lu.assertEquals(mock.targetAltitude, expected)
    lu.assertNotEquals(mock.baseAltitude, expected)
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestAntiGravityGeneratorUnit.skipTestGameBehavior()
    local mock = maggu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "Unit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())