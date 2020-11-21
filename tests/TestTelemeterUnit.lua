#!/usr/bin/env lua
--- Tests on dumocks.TelemeterUnit.
-- @see dumocks.TelemeterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mtu = require("dumocks.TelemeterUnit")
require("tests.Utilities")

_G.TestTelemeterUnit = {}

--- Verify constructor arguments properly handled.
function _G.TestTelemeterUnit.testConstructor()

    -- default element:
    -- ["telemeter"] = {mass = 49.79, maxHitPoints = 50.0}

    local telemeter0 = mtu:new()
    local telemeter1 = mtu:new(nil, 1, "Telemeter")
    local telemeter2 = mtu:new(nil, 2, "invalid")

    local telemeterClosure0 = telemeter0:mockGetClosure()
    local telemeterClosure1 = telemeter1:mockGetClosure()
    local telemeterClosure2 = telemeter2:mockGetClosure()

    lu.assertEquals(telemeterClosure0.getId(), 0)
    lu.assertEquals(telemeterClosure1.getId(), 1)
    lu.assertEquals(telemeterClosure2.getId(), 2)

    local defaultMass = 40.79
    lu.assertEquals(telemeterClosure0.getMass(), defaultMass)
    lu.assertEquals(telemeterClosure1.getMass(), defaultMass)
    lu.assertEquals(telemeterClosure2.getMass(), defaultMass)
end


-- Verify get distance works and respects max range.
function _G.TestTelemeterUnit.testGetDistance()
    local mock = mtu:new()
    local closure = mock:mockGetClosure()

    -- default
    lu.assertEquals(closure.getDistance(), -1)

    mock.maxDistance = 100

    -- in range
    mock.distance = 20
    lu.assertEquals(closure.getDistance(), 20)

    -- out of range
    mock.distance = 200
    lu.assertEquals(closure.getDistance(), -1)

    -- invalid
    mock.distance = -10
    lu.assertEquals(closure.getDistance(), -1)
end

-- Verify get max distance works.
function _G.TestTelemeterUnit.testGetMaxDistance()
    local mock = mtu:new()
    local closure = mock:mockGetClosure()

    -- default
    lu.assertEquals(closure.getMaxDistance(), 100)

    mock.maxDistance = 20
    lu.assertEquals(closure.getMaxDistance(), 20)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 3x Telemeter, connected to Programming Board on slot1, slot2, and slot3
-- 2. slot1 telemeter is pointed into open space
-- 3. slot2 telemeter is pointed at the floor mounted on the third voxel above it
-- 4. slot3 telemeter is pointed at an industry unit as close as it can be mounted pointing at it
--
-- Exercises: getElementClass, getDistance, getMaxDistance
function _G.TestTelemeterUnit.testGameBehavior()
    local mock1 = mtu:new(nil, 1)
    local slot1 = mock1:mockGetClosure()
    local mock2 = mtu:new()
    local slot2 = mock2:mockGetClosure()
    local mock3 = mtu:new()
    local slot3 = mock3:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    -- set ranges measured in test setup
    mock1.distance = -1
    mock2.distance = 0.5432398362334
    mock3.distance = 0.35531205231629

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getMaxDistance", "getDistance",
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "load"}
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "TelemeterUnit")
    assert(slot2.getElementClass() == "TelemeterUnit")
    assert(slot3.getElementClass() == "TelemeterUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 40.79)

    assert(slot1.getMaxDistance() == 100, "Telemeter 1 max distance: " .. slot1.getMaxDistance())

    local UNDEF_DISTANCE = -1

    local slot1Distance = slot1.getDistance()
    assert(slot1Distance == UNDEF_DISTANCE, "Telemeter 1 distance: " .. slot1Distance)
    local slot2Distance = slot2.getDistance()
    assert(slot2Distance > 0.5 and slot2Distance < 1.0, "Telemeter 2 distance: " .. slot2Distance)
    local slot3Distance = slot3.getDistance()
    assert(slot3Distance > 0 and slot3Distance < 0.5, "Telemeter 3 distance: " .. slot3Distance)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())