#!/usr/bin/env lua
--- Tests on dumocks.TelemeterUnit.
-- @see dumocks.TelemeterUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mtu = require("dumocks.TelemeterUnit")
local utilities = require("test.Utilities")

_G.TestTelemeterUnit = {}

--- Verify constructor arguments properly handled.
function _G.TestTelemeterUnit.testConstructor()

    -- default element:
    -- ["telemeter xs"] = {mass = 40.79, maxHitPoints = 50.0, itemId = 1722901246}

    local telemeter0 = mtu:new()
    local telemeter1 = mtu:new(nil, 1, "Telemeter XS")
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

    local defaultId = 1722901246
    lu.assertEquals(telemeterClosure0.getItemId(), defaultId)
    lu.assertEquals(telemeterClosure1.getItemId(), defaultId)
    lu.assertEquals(telemeterClosure2.getItemId(), defaultId)
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
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    -- set ranges measured in test setup
    mock1.distance = -1
    mock2.distance = 0.5432398362334
    mock3.distance = 0.35531205231629

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getMaxDistance", "getDistance", "raycast", "getRayWorldAxis", "getRayAxis",
                               "getRayOrigin", "getRayWorldOrigin"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "TelemeterUnit")
    assert(slot2.getClass() == "TelemeterUnit")
    assert(slot3.getClass() == "TelemeterUnit")
    assert(string.match(string.lower(slot1.getName()), "telemeter xs %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 1722901246, "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 40.79)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

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
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
