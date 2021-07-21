#!/usr/bin/env lua
--- Tests on dumocks.LightUnit.
-- @see dumocks.LightUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mlu = require("dumocks.LightUnit")
require("test.Utilities")

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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Long Light Light L, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, setSignalIn, getSignalIn, setRGBColor,
-- getRGBColor
function _G.TestLightUnit.testGameBehavior()
    local mock = mlu:new(nil, 1, "long light m")
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
    -- verify expected functions
    local expectedFunctions = {"setRGBColor", "getRGBColor", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "LightUnit")
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 79.34)
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

    -- rounds to nearest number but leaves small decimal value
    local epsilon = 0.0001
    local colorVec
    slot1.setRGBColor(-1, "bad", nil)
    colorVec = slot1.getRGBColor()
    assert(math.abs(-1 - colorVec[1]) < epsilon, "r: " ..colorVec[1]) -- unexpected, light ranges aren't validated
    assert(colorVec[2] == 0, "g: " ..colorVec[2])
    assert(colorVec[3] == 0, "b: " ..colorVec[3])
    slot1.setRGBColor(1.123, 128.512, 600)
    colorVec = slot1.getRGBColor()
    assert(math.abs(1 - colorVec[1]) < epsilon, "r: " ..colorVec[1])
    assert(math.abs(129 - colorVec[2]) < epsilon, "g: " ..colorVec[2])
    assert(math.abs(600 - colorVec[3]) < epsilon, "b: " ..colorVec[3]) -- unexpected, light ranges aren't validated

    system.print("Success")
    slot1.deactivate();
    unit.exit()
    ---------------
    -- copy to here to unit.start
    ---------------
end

os.exit(lu.LuaUnit.run())
