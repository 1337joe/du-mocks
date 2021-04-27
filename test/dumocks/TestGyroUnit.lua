#!/usr/bin/env lua
--- Tests on dumocks.GyroUnit.
-- @see dumocks.GyroUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mgu = require("dumocks.GyroUnit")
require("test.Utilities")

_G.TestGyroUnit = {}

--- Verify constructor arguments properly handled.
function _G.TestGyroUnit.testConstructor()

    -- default element:
    -- ["gyroscope"] = {mass = 104.41, maxHitPoints = 50}

    local gyro0 = mgu:new()
    local gyro1 = mgu:new(nil, 1, "Gyroscope")
    local gyro2 = mgu:new(nil, 2, "invalid")

    local gyroClosure0 = gyro0:mockGetClosure()
    local gyroClosure1 = gyro1:mockGetClosure()
    local gyroClosure2 = gyro2:mockGetClosure()

    lu.assertEquals(gyroClosure0.getId(), 0)
    lu.assertEquals(gyroClosure1.getId(), 1)
    lu.assertEquals(gyroClosure2.getId(), 2)

    local defaultMass = 104.41
    lu.assertEquals(gyroClosure0.getMass(), defaultMass)
    lu.assertEquals(gyroClosure1.getMass(), defaultMass)
    lu.assertEquals(gyroClosure2.getMass(), defaultMass)
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
-- Exercises: getElementClass, getData, deactivate, activate, toggle, getState
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
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"worldForward", "getRoll", "worldRight", "worldUp", "getYaw", "localRight",
                               "localForward", "getPitch", "setYawWorldReference", "localUp"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "GyroUnit")

    local data = slot1.getData()
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
