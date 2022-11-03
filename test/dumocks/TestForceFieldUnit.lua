#!/usr/bin/env lua
--- Tests on dumocks.ForceFieldUnit.
-- @see dumocks.ForceFieldUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mffu = require("dumocks.ForceFieldUnit")
require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestForceFieldUnit = AbstractTestElementWithToggle

function _G.TestForceFieldUnit.getTestElement()
    return mffu:new()
end

function _G.TestForceFieldUnit.getStateFunction(closure)
    return closure.isDeployed
end

function _G.TestForceFieldUnit.getActivateFunction(closure)
    return closure.deploy
end

function _G.TestForceFieldUnit.getDeactivateFunction(closure)
    return closure.retract
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestForceFieldUnit.testConstructor()

    -- default element:
    -- ["force field xs"] = {mass = 110.62, maxHitPoints = 50.0, itemId = 3686074288}

    local field0 = mffu:new()
    local field1 = mffu:new(nil, 1, "Force Field XS")
    local field2 = mffu:new(nil, 2, "invalid")
    local field3 = mffu:new(nil, 3, "force field s")

    local fieldClosure0 = field0:mockGetClosure()
    local fieldClosure1 = field1:mockGetClosure()
    local fieldClosure2 = field2:mockGetClosure()
    local fieldClosure3 = field3:mockGetClosure()

    lu.assertEquals(fieldClosure0.getLocalId(), 0)
    lu.assertEquals(fieldClosure1.getLocalId(), 1)
    lu.assertEquals(fieldClosure2.getLocalId(), 2)
    lu.assertEquals(fieldClosure3.getLocalId(), 3)

    local defaultId = 3686074288
    lu.assertEquals(fieldClosure0.getItemId(), defaultId)
    lu.assertEquals(fieldClosure1.getItemId(), defaultId)
    lu.assertEquals(fieldClosure2.getItemId(), defaultId)
    lu.assertNotEquals(fieldClosure3.getItemId(), defaultId)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Force Field, connected to Programming Board on slot1
--
-- Exercises: getClass, retract, deploy, toggle, isDeployed, setSignalIn, getSignalIn
function _G.TestForceFieldUnit.testGameBehavior()
    local mock = mffu:new(nil, 1)
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
    assert(slot1.getClass() == "ForceFieldUnit")
    assert(string.match(string.lower(slot1.getName()), "force field %w+ %[%d+%]"), slot1.getName())
    local expectedId = {[3686074288] = true, [3685998465] = true, [3686006062] = true, [3685982092] = true}
    assert(expectedId[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 110.62)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

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

    -- play with set signal, appears to cause the element to refresh state to match actual input signal when it doesn't already
    slot1.deploy()
    assert(slot1.isDeployed() == 1)
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == 0)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == 0)

    slot1.deploy()
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isDeployed() == 0)

    slot1.deploy()
    assert(slot1.isDeployed() == 1)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)

    slot1.deploy()
    assert(slot1.isDeployed() == 1)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
