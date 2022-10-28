#!/usr/bin/env lua
--- Tests on dumocks.FireworksUnit.
-- @see dumocks.FireworksUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mfu = require("dumocks.FireworksUnit")
local utilities = require("test.Utilities")

TestFireworksUnit = {}


--- Verify constructor arguments properly handled and independent between instances.
function _G.TestFireworksUnit.testConstructor()

    -- default element:
    -- elementDefinitions["fireworks launcher s"] = {mass = 78.12, maxHitPoints = 50.0, itemId = 3882559017}

    local fireworks1 = mfu:new(nil, 1, "Fireworks Launcher S")
    local fireworks2 = mfu:new(nil, 2, "invalid")
    local fireworks3 = mfu:new()

    local fireworks1Closure = fireworks1:mockGetClosure()
    local fireworks2Closure = fireworks2:mockGetClosure()
    local fireworks3Closure = fireworks3:mockGetClosure()

    lu.assertEquals(fireworks1Closure.getLocalId(), 1)
    lu.assertEquals(fireworks2Closure.getLocalId(), 2)
    lu.assertEquals(fireworks3Closure.getLocalId(), 0)

    -- prove default element is selected
    local defaultMass = 78.12
    lu.assertEquals(fireworks1Closure.getMass(), defaultMass)
    lu.assertEquals(fireworks2Closure.getMass(), defaultMass)
    lu.assertEquals(fireworks3Closure.getMass(), defaultMass)

    -- do some damage, max hit points is 50 (prove independance)
    fireworks1.hitPoints = 25.0
    fireworks2.hitPoints = 12.5
    fireworks3.hitPoints = 0.25

    lu.assertEquals(fireworks1Closure.getIntegrity(), 50.0)
    lu.assertEquals(fireworks2Closure.getIntegrity(), 25.0)
    lu.assertEquals(fireworks3Closure.getIntegrity(), 0.5)

    local defaultId = 3882559017
    lu.assertEquals(fireworks1Closure.getItemId(), defaultId)
    lu.assertEquals(fireworks2Closure.getItemId(), defaultId)
    lu.assertEquals(fireworks3Closure.getItemId(), defaultId)
end

--- Verify behavior of fire.
function _G.TestFireworksUnit.testFire()
    local mock = mfu:new()
    local closure = mock:mockGetClosure()

    lu.assertEquals(utilities.verifyDeprecated("activate", closure.activate))
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Fireworks Launcher, connected to Programming Board on slot1
--
-- Exercises: getClass, setExplosionDelay, getExplosionDelay, setLaunchSpeed, getLaunchSpeed, setType, getType,
--   setColor, getColor
function _G.TestFireworksUnit.testGameBehavior()
    local databank = mfu:new(nil, 1)
    local slot1 = databank:mockGetClosure()

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
    local expectedFunctions = {"fire", "setExplosionDelay", "getExplosionDelay", "setLaunchSpeed", "getLaunchSpeed",
                               "setType", "getType", "setColor", "getColor", "activate", "getSignalIn", "setSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "FireworksUnit")
    assert(string.match(string.lower(slot1.getName()), "fireworks launcher s %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 3882559017, slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 78.12)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    local initialExplosionDelay = slot1.getExplosionDelay()
    slot1.setExplosionDelay(3)
    assert(slot1.getExplosionDelay() == 3)
    slot1.setExplosionDelay(0)
    assert(slot1.getExplosionDelay() == 2)
    slot1.setExplosionDelay(10)
    assert(slot1.getExplosionDelay() == 5)
    slot1.setExplosionDelay(3.5)
    assert(slot1.getExplosionDelay() == 3.5)
    slot1.setExplosionDelay(3.0)
    assert(slot1.getExplosionDelay() == 3)
    slot1.setExplosionDelay(false)
    assert(slot1.getExplosionDelay() == 2)
    slot1.setExplosionDelay("Time")
    assert(slot1.getExplosionDelay() == 2)
    slot1.setExplosionDelay("3.0")
    assert(slot1.getExplosionDelay() == 3)
    slot1.setExplosionDelay(initialExplosionDelay)
    assert(slot1.getExplosionDelay() == initialExplosionDelay)

    local initialLaunchSpeed = slot1.getLaunchSpeed()
    slot1.setLaunchSpeed(150.0)
    assert(slot1.getLaunchSpeed() == 150.0)
    slot1.setLaunchSpeed(0)
    assert(slot1.getLaunchSpeed() == 50.0)
    slot1.setLaunchSpeed(300)
    assert(slot1.getLaunchSpeed() == 200.0)
    slot1.setLaunchSpeed(55.5)
    assert(slot1.getLaunchSpeed() == 55.5)
    slot1.setLaunchSpeed(60.0)
    assert(slot1.getLaunchSpeed() == 60.0)
    slot1.setLaunchSpeed(false)
    assert(slot1.getLaunchSpeed() == 50.0)
    slot1.setLaunchSpeed("Time")
    assert(slot1.getLaunchSpeed() == 50.0)
    slot1.setLaunchSpeed("130.5")
    assert(slot1.getLaunchSpeed() == 130.5)
    slot1.setLaunchSpeed(initialLaunchSpeed)
    assert(slot1.getLaunchSpeed() == initialLaunchSpeed)

    local initialType = slot1.getType()
    slot1.setType(2)
    assert(slot1.getType() == 2)
    slot1.setType(0)
    assert(slot1.getType() == 1)
    slot1.setType(10)
    assert(slot1.getType() == 4)
    slot1.setType(3.5)
    assert(slot1.getType() == 1)
    slot1.setType(3.0)
    assert(slot1.getType() == 3)
    slot1.setType(false)
    assert(slot1.getType() == 1)
    slot1.setType("Ball")
    assert(slot1.getType() == 1)
    slot1.setType("2.0")
    assert(slot1.getType() == 2)
    slot1.setType(initialType)
    assert(slot1.getType() == initialType)

    local initialColor = slot1.getColor()
    slot1.setColor(2)
    assert(slot1.getColor() == 2)
    slot1.setColor(0)
    assert(slot1.getColor() == 1)
    slot1.setColor(10)
    assert(slot1.getColor() == 6)
    slot1.setColor(3.5)
    assert(slot1.getColor() == 1)
    slot1.setColor(3.0)
    assert(slot1.getColor() == 3)
    slot1.setColor(false)
    assert(slot1.getColor() == 1)
    slot1.setColor("Red")
    assert(slot1.getColor() == 1)
    slot1.setColor("2.0")
    assert(slot1.getColor() == 2)
    slot1.setColor(initialColor)
    assert(slot1.getColor() == initialColor)

    system.print("Success")
    unit.exit()

    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())