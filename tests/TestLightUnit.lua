#!/usr/bin/env lua
--- Tests on dumocks.LightUnit.
-- @see dumocks.LightUnit

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

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
-- 1. 1x Long Light Light L, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
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
    -- test element class and expected functions
    local expectedFunctions = {"activate", "deactivate", "toggle", "getState", 
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "setSignalIn", "getSignalIn",
                               "load"}
    local unexpectedFunctions = {}
    for key, value in pairs(slot1) do
        if type(value) == "function" then
            for index, funcName in pairs(expectedFunctions) do
                if key == funcName then
                    table.remove(expectedFunctions, index)
                    goto continueOuter
                end
            end

            table.insert(unexpectedFunctions, key)
        end

        ::continueOuter::
    end
    local message = ""
    if #expectedFunctions > 0 then
        message = message .. "Missing expected functions: " .. table.concat(expectedFunctions, ", ") .. "\n"
    end
    if #unexpectedFunctions > 0 then
        message = message .. "Found unexpected functions: " .. table.concat(unexpectedFunctions, ", ") .. "\n"
    end
    assert(message:len() == 0, message)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "LightUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 79.34)

    -- play with set signal, has no actual effect on light state when set programmatically
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
    -- copy to here to unit.start
    ---------------
end

os.exit(lu.LuaUnit.run())
