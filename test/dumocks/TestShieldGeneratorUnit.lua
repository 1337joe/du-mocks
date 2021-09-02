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

--- Verify behavior of autoCallback.
function _G.TestShieldGeneratorUnit.testAutoCallback()
    local mock = msgu:new()
    local closure = mock:mockGetClosure()

    -- automatically applies state change
    mock.autoCallback = true

    mock.state = false
    lu.assertEquals(closure.getState(), 0)
    closure.toggle()
    lu.assertEquals(closure.getState(), 1)

    mock.state = false
    lu.assertEquals(closure.getState(), 0)
    closure.activate()
    lu.assertEquals(closure.getState(), 1)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
    closure.deactivate()
    lu.assertEquals(closure.getState(), 0)

    -- waits to apply state change until requested
    mock.autoCallback = false

    mock.state = false
    lu.assertEquals(closure.getState(), 0)
    closure.toggle()
    lu.assertEquals(closure.getState(), 0)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.getState(), 1)

    mock.state = false
    lu.assertEquals(closure.getState(), 0)
    closure.activate()
    lu.assertEquals(closure.getState(), 0)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.getState(), 1)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
    closure.deactivate()
    lu.assertEquals(closure.getState(), 1)
    mock:mockTriggerCallback()
    lu.assertEquals(closure.getState(), 0)
end

--- Verify shield hitpoints considers state.
function _G.TestShieldGeneratorUnit.testGetShieldHitPoints()
    local mock = msgu:new()
    mock.shieldHitPoints = 100
    local closure = mock:mockGetClosure()

    mock.state = true
    lu.assertEquals(closure.getShieldHitPoints(), 100)

    mock.state = false
    lu.assertEquals(closure.getShieldHitPoints(), 0)
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
    mock.autoCallback = false
    local slot1 = mock:mockGetClosure()

    -- fake coroutine: uncomment to allow errors to immediately propagate up
    -- coroutine = {}
    -- function coroutine.create(func)
    --     coroutine.myFunc = func
    -- end
    -- function coroutine.resume()
    --     coroutine.myFunc()
    --     coroutine.resume = function() end
    -- end
    -- function coroutine.yield()
    -- end

    local finished = false

    -- stub this in directly to suppress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
        finished = true
    end
    unit.setTimer = function()
    end
    local system = {}
    system.print = function(msg)
    end

    -- not called by mock
    local tickFail = function()
        ---------------
        -- copy from here to unit.tick(timerId) fail
        ---------------
        -- should hit exit call from coroutine before this ticks
        system.print("Failed")
        unit.exit()
        ---------------
        -- copy to here to unit.tick(timerId) fail
        ---------------
    end
    local tickDelay = function()
        ---------------
        -- copy from here to unit.tick(timerId) delay
        ---------------
        _G.resumeCoroutine()
        ---------------
        -- copy to here to unit.tick(timerId) delay
        ---------------
    end

    local absorbedListener = function()
        ---------------
        -- copy from here to slot1.absorbed(hitpoints) *
        ---------------
        assert(false, "Not expecting absorbed to be called.")
        ---------------
        -- copy to here to slot1.absorbed(hitpoints) *
        ---------------
    end
    --mock:mockRegisterAbsorbed(absorbedListener)

    local downListener = function()
        ---------------
        -- copy from here to slot1.down()
        ---------------
        assert(slot1.getState() == 0, "Expected off before calling")
        assert(slot1.getShieldHitPoints() == 0, "Expected 0 HP when off")

        -- give element time to settle before changing
        unit.setTimer("delay", 0.5)
        ---------------
        -- copy to here to slot1.down()
        ---------------
    end
    mock:mockRegisterDown(downListener)

    local restoredListener = function()
        ---------------
        -- copy from here to slot1.restored()
        ---------------
        assert(slot1.getState() == 1, "Expected on before calling")
        assert(slot1.getShieldHitPoints() == slot1.getMaxShieldHitPoints(), "Expected max HP when on")

        -- give element time to settle before changing
        unit.setTimer("delay", 0.5)
        ---------------
        -- copy to here to slot1.restored()
        ---------------
    end
    mock:mockRegisterRestored(restoredListener)

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

    assert(slot1.getMaxShieldHitPoints() >= 300000)

    local function stateChangeTest()
        -- ensure initial state on
        if slot1.getState() == 0 then
            slot1.activate()
            coroutine.yield()
            assert(slot1.getState() == 1)
        end

        -- full hp when on
        assert(slot1.getShieldHitPoints() >= 300000)

        -- validate methods
        slot1.deactivate()
        coroutine.yield()
        assert(slot1.getState() == 0)
        slot1.activate()
        coroutine.yield()
        assert(slot1.getState() == 1)
        slot1.toggle()
        coroutine.yield()
        assert(slot1.getState() == 0)

        -- no hp when off
        assert(slot1.getShieldHitPoints() == 0)

        system.print("Success")
        unit.exit()
    end

    _G.shieldStateCoroutine = coroutine.create(stateChangeTest)
    coroutine.resume(_G.shieldStateCoroutine)

    _G.resumeCoroutine = function()
        assert(_G.shieldStateCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.shieldStateCoroutine) ~= "dead", "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.shieldStateCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
    end

    -- report failure if coroutine has not reached success within 5 seconds
    unit.setTimer("fail", 5)

    ---------------
    -- copy to here to unit.start()
    ---------------

    -- autoCallback disabled, manually call each time
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()
    mock:mockTriggerCallback()
    tickDelay()

    lu.assertTrue(finished)
end

os.exit(lu.LuaUnit.run())
