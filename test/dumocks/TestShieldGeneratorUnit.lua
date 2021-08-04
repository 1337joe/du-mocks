#!/usr/bin/env lua
--- Tests on dumocks.ShieldGeneratorUnit.
-- @see dumocks.ShieldGeneratorUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local msgu = require("dumocks.ShieldGeneratorUnit")
require("test.Utilities")

_G.TestShieldGeneratorUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestShieldGeneratorUnit.testConstructor()

    -- default element:
    -- ["shield generator xs"] = {mass = 670.0, maxHitPoints = 1400.0, maxShieldHitPoints = 300000.0}

    local mock0 = msgu:new()
    local mock1 = msgu:new(nil, 1, "Shield Generator XS")
    local mock2 = msgu:new(nil, 2, "invalid")
    local mock3 = msgu:new(nil, 3, "shield generator s")

    local mockClosure0 = mock0:mockGetClosure()
    local mockClosure1 = mock1:mockGetClosure()
    local mockClosure2 = mock2:mockGetClosure()
    local mockClosure3 = mock3:mockGetClosure()

    lu.assertEquals(mockClosure0.getId(), 0)
    lu.assertEquals(mockClosure1.getId(), 1)
    lu.assertEquals(mockClosure2.getId(), 2)
    lu.assertEquals(mockClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 670.0
    lu.assertEquals(mockClosure0.getMass(), defaultMass)
    lu.assertEquals(mockClosure1.getMass(), defaultMass)
    lu.assertEquals(mockClosure2.getMass(), defaultMass)
    lu.assertNotEquals(mockClosure3.getMass(), defaultMass)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Shield Generator, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, getShieldHitPoints, getMaxShieldHitPoints
function _G.TestShieldGeneratorUnit.testGameBehavior()
    local mock = msgu:new(nil, 1)
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
    local expectedFunctions = {"getShieldHitPoints", "getMaxShieldHitPoints"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "ShieldGeneratorUnit")

    local data = slot1.getData()
    local expectedFields = {"elementId", "helperId", "isActive", "name", "shieldHp", "shieldMaxHp", "type"}
    local expectedValues = {}
    expectedValues["helperId"] = '"shield_generator"'
    expectedValues["type"] = '"shield_generator"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() >= 1400)
    assert(slot1.getMass() >= 670.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "shield_generator")

    assert(slot1.getShieldHitPoints() >= 300000)
    assert(slot1.getMaxShieldHitPoints() >= 300000)

    -- TODO wait between state changes, how long?
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
