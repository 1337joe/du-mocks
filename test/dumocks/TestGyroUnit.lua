#!/usr/bin/env lua
--- Tests on dumocks.GyroUnit.
-- @see dumocks.GyroUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mgu = require("dumocks.GyroUnit")
local utilities = require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestGyroUnit = AbstractTestElementWithToggle

function _G.TestGyroUnit.getTestElement()
    return mgu:new()
end

function _G.TestGyroUnit.getStateFunction(closure)
    return closure.isActive
end

function _G.TestGyroUnit.getActivateFunction(closure)
    return closure.activate
end

function _G.TestGyroUnit.getDeactivateFunction(closure)
    return closure.deactivate
end

--- Verify constructor arguments properly handled.
function _G.TestGyroUnit.testConstructor()

    -- default element:
    -- ["gyroscope xs"] = {mass = 104.41, maxHitPoints = 50, itemId = 2585415184}

    local gyro0 = mgu:new()
    local gyro1 = mgu:new(nil, 1, "Gyroscope XS")
    local gyro2 = mgu:new(nil, 2, "invalid")

    local gyroClosure0 = gyro0:mockGetClosure()
    local gyroClosure1 = gyro1:mockGetClosure()
    local gyroClosure2 = gyro2:mockGetClosure()

    lu.assertEquals(gyroClosure0.getLocalId(), 0)
    lu.assertEquals(gyroClosure1.getLocalId(), 1)
    lu.assertEquals(gyroClosure2.getLocalId(), 2)

    local defaultMass = 104.41
    lu.assertEquals(gyroClosure0.getMass(), defaultMass)
    lu.assertEquals(gyroClosure1.getMass(), defaultMass)
    lu.assertEquals(gyroClosure2.getMass(), defaultMass)

    local defaultId = 2585415184
    lu.assertEquals(gyroClosure0.getItemId(), defaultId)
    lu.assertEquals(gyroClosure1.getItemId(), defaultId)
    lu.assertEquals(gyroClosure2.getItemId(), defaultId)
end

function _G.TestGyroUnit.testDeprecatedLocal()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    local expected

    expected = {0.707, 0.707, 0}
    mock.up = expected
    assert(utilities.assertTableEquals(closure.getUp(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("localUp", closure.localUp), expected))

    expected = {0.707, 0, 0.707}
    mock.right = expected
    assert(utilities.assertTableEquals(closure.getRight(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("localRight", closure.localRight), expected))

    expected = {0, 0.707, 0.707}
    mock.forward = expected
    assert(utilities.assertTableEquals(closure.getForward(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("localForward", closure.localForward), expected))
end

function _G.TestGyroUnit.testDeprecatedWorld()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    local expected

    expected = {0.707, 0.707, 0}
    mock.upWorld = expected
    assert(utilities.assertTableEquals(closure.getWorldUp(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("worldUp", closure.worldUp), expected))

    expected = {0.707, 0, 0.707}
    mock.rightWorld = expected
    assert(utilities.assertTableEquals(closure.getWorldRight(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("worldRight", closure.worldRight), expected))

    expected = {0, 0.707, 0.707}
    mock.forwardWorld = expected
    assert(utilities.assertTableEquals(closure.getWorldForward(), expected))
    assert(utilities.assertTableEquals(utilities.verifyDeprecated("worldForward", closure.worldForward), expected))
end

--- Verify that get pitch retrieves pitch properly.
function _G.TestGyroUnit.testGetPitch()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.pitch = 10.5
    lu.assertEquals(closure.getPitch(), 10.5)

    mock.pitch = -45
    lu.assertEquals(closure.getPitch(), -45)
end

--- Verify that get roll retrieves pitch properly.
function _G.TestGyroUnit.testGetRoll()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.roll = 10.5
    lu.assertEquals(closure.getRoll(), 10.5)

    mock.roll = -45
    lu.assertEquals(closure.getRoll(), -45)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Gyroscope, connected to Programming Board on slot1
--
-- Note: Must be run on a dynamic core.
--
-- Exercises: getClass, getWidgetData, deactivate, activate, toggle, isActive
function _G.TestGyroUnit.testGameBehavior()
    local mock = mgu:new(nil, 1)
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
    local expectedFunctions = {"worldForward", "getRoll", "worldRight", "worldUp", "localRight", "localForward",
                               "getPitch", "localUp", "isActive"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "GyroUnit")
    assert(slot1.getItemId() == 2585415184)
    assert(string.match(string.lower(slot1.getName()), "gyroscope xs %[%d+%]"), slot1.getName())

    local data = slot1.getWidgetData()
    local expectedFields = {"pitch", "roll", "helperId", "name", "type"}
    local expectedValues = {}
    expectedValues["helperId"] = '"gyro"'
    expectedValues["type"] = '"gyro"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() == 50)
    assert(slot1.getMass() == 104.41)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "gyro")

    -- ensure initial state
    slot1.deactivate()
    assert(slot1.isActive() == 0)

    -- validate methods
    slot1.activate()
    assert(slot1.isActive() == 1)
    slot1.deactivate()
    assert(slot1.isActive() == 0)
    slot1.toggle()
    assert(slot1.isActive() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
