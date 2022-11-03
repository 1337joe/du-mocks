#!/usr/bin/env lua
--- Tests on dumocks.LandingGearUnit.
-- @see dumocks.LandingGearUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mlgu = require("dumocks.LandingGearUnit")
require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestLandingGearUnit = AbstractTestElementWithToggle

function _G.TestLandingGearUnit.getTestElement()
    return mlgu:new()
end

function _G.TestLandingGearUnit.getStateFunction(closure)
    return closure.isDeployed
end

function _G.TestLandingGearUnit.getActivateFunction(closure)
    return closure.deploy
end

function _G.TestLandingGearUnit.getDeactivateFunction(closure)
    return closure.retract
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLandingGearUnit.testConstructor()

    -- default element:
    -- ["landing gear s"] = {mass = 258.76, maxHitPoints = 5000.0, itemId = 1884031929}

    local gear0 = mlgu:new()
    local gear1 = mlgu:new(nil, 1, "Landing Gear S")
    local gear2 = mlgu:new(nil, 2, "invalid")
    local gear3 = mlgu:new(nil, 3, "landing gear m")

    local gearClosure0 = gear0:mockGetClosure()
    local gearClosure1 = gear1:mockGetClosure()
    local gearClosure2 = gear2:mockGetClosure()
    local gearClosure3 = gear3:mockGetClosure()

    lu.assertEquals(gearClosure0.getLocalId(), 0)
    lu.assertEquals(gearClosure1.getLocalId(), 1)
    lu.assertEquals(gearClosure2.getLocalId(), 2)
    lu.assertEquals(gearClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 258.76
    lu.assertEquals(gearClosure0.getMass(), defaultMass)
    lu.assertEquals(gearClosure1.getMass(), defaultMass)
    lu.assertEquals(gearClosure2.getMass(), defaultMass)
    lu.assertNotEquals(gearClosure3.getMass(), defaultMass)

    local defaultId = 1884031929
    lu.assertEquals(gearClosure0.getItemId(), defaultId)
    lu.assertEquals(gearClosure1.getItemId(), defaultId)
    lu.assertEquals(gearClosure2.getItemId(), defaultId)
    lu.assertNotEquals(gearClosure3.getItemId(), defaultId)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Landing Gear, connected to Programming Board on slot1
--
-- Exercises: getClass, retract, deploy, toggle, isDeployed, setSignalIn, getSignalIn
function _G.TestLandingGearUnit.testGameBehavior()
    local mock = mlgu:new(nil, 1, "landing gear xs")
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
    local expectedFunctions = {"deploy", "retract", "isDeployed", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "LandingGearUnit")
    assert(string.match(string.lower(slot1.getName()), "landing gear %w+ %[%d+%]"), slot1.getName())
    local expectedId = {[4078067869] = true, [1884031929] = true, [1899560165] = true, [2667697870] = true}
    assert(expectedId[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 1250.0)
    assert(slot1.getMass() == 49.88)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.isDeployed()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == initialState)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == initialState)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == initialState)

    -- ensure initial state
    slot1.retract()
    assert(slot1.isDeployed() == 0)

    -- validate methods
    slot1.deploy()
    assert(slot1.isDeployed() == 1)
    slot1.retract()
    assert(slot1.isDeployed() == 0)
    slot1.toggle()
    assert(slot1.isDeployed() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
