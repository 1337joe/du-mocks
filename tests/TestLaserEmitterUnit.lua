#!/usr/bin/env lua
--- Tests on dumocks.LaserEmitterUnit.
-- @see dumocks.LaserEmitterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mleu = require("dumocks.LaserEmitterUnit")

_G.TestLaserEmitterUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLaserEmitterUnit.testConstructor()

    -- default element:
    -- ["laser emitter"] = {mass = 7.47, maxHitPoints = 50.0}

    local emitter0 = mleu:new()
    local emitter1 = mleu:new(nil, 1, "Laser Emitter")
    local emitter2 = mleu:new(nil, 2, "invalid")
    local emitter3 = mleu:new(nil, 3, "infrared laser emitter")

    local emitterClosure0 = emitter0:mockGetClosure()
    local emitterClosure1 = emitter1:mockGetClosure()
    local emitterClosure2 = emitter2:mockGetClosure()
    local emitterClosure3 = emitter3:mockGetClosure()

    lu.assertEquals(emitterClosure0.getId(), 0)
    lu.assertEquals(emitterClosure1.getId(), 1)
    lu.assertEquals(emitterClosure2.getId(), 2)
    lu.assertEquals(emitterClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 7.47
    lu.assertEquals(emitterClosure0.getMass(), defaultMass)
    lu.assertEquals(emitterClosure1.getMass(), defaultMass)
    lu.assertEquals(emitterClosure2.getMass(), defaultMass)
    lu.assertNotEquals(emitterClosure3.getMass(), defaultMass)
end

--- Verify element class is correct.
function _G.TestLaserEmitterUnit.testGetElementClass()
    local element = mleu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "LaserEmitterUnit")
end

--- Verify that activate leaves the laser off.
function _G.TestLaserEmitterUnit.testActivate()
    local mock = mleu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the laser on.
function _G.TestLaserEmitterUnit.testDeactivate()
    local mock = mleu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestLaserEmitterUnit.testToggle()
    local mock = mleu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

--- Verify that get state retrieves the state properly.
function _G.TestLaserEmitterUnit.testGetState()
    local mock = mleu:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestLaserEmitterUnit.skipTestGameBehavior()
    local mock = mleu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "LaserEmitterUnit")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())