#!/usr/bin/env lua
--- Tests on dumocks.GyroUnit.
-- @see dumocks.GyroUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mgu = require("dumocks.GyroUnit")

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

--- Verify element class is correct.
function _G.TestGyroUnit.testGetElementClass()
    local element = mgu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "GyroUnit")
end


--- Verify that activate leaves the gyro enabled.
function _G.TestGyroUnit.testActivate()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the gyro disabled.
function _G.TestGyroUnit.testDeactivate()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestGyroUnit.testToggle()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestGyroUnit.testGetState()
    local mock = mgu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
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

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestGyroUnit.skipTestGameBehavior()
    local mock = mgu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "GyroUnit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())