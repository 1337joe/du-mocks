#!/usr/bin/env lua
--- Tests on dumocks.LaserEmitterUnit.
-- @see dumocks.LaserEmitterUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mleu = require("dumocks.LaserEmitterUnit")
require("test.Utilities")

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

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Laser Emitter, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, setSignalIn, getSignalIn
function _G.TestLaserEmitterUnit.testGameBehavior()
    local mock = mleu:new(nil, 1)
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
    local expectedFunctions = {"setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "LaserEmitterUnit")
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 7.47 or slot1.getMass() == 9.93)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == 1)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(slot1.getState() == 1)
    slot1.setSignalIn("in", "0.5")
    assert(slot1.getSignalIn("in") == 0.5)
    assert(slot1.getState() == 1)
    slot1.setSignalIn("in", "0.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", "7.0")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == 1)
    -- invalid sets to 0
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == 0)

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

    -- ensure final state
    slot1.deactivate()
    assert(slot1.getState() == 0)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start
    ---------------
end

os.exit(lu.LuaUnit.run())
