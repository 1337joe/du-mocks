#!/usr/bin/env lua
--- Tests on dumocks.WeaponUnit.
-- @see dumocks.WeaponUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mwu = require("dumocks.WeaponUnit")
require("test.Utilities")

TestWeaponUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Railgun XS, connected to Hovercraft Seat Controller on slot11
--
-- Note: Must be run on a dynamic core.
--
-- Exercises: getClass, getWidgetData
function _G.TestWeaponUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"railgun xs"}) do
        mock = mwu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestWeaponUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestWeaponUnit.gameBehaviorHelper(mock, slot11)
    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function(_)
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getReloadTime", "getUnloadTime", "getMaxDistance", "getTargetId", "getMaxAmmo",
                               "getOptimalTracking", "getOperationalState", "getOptimalDistance", "getMagazineVolume",
                               "isOperational", "isOutOfAmmo", "getContainerId", "getStatus", "getHitProbability",
                               "getCycleTime", "getAmmoCount", "getAmmo", "getOptimalAimingCone", "getBaseDamage"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot11, expectedFunctions)

    -- test element class and inherited methods
    local class = slot11.getClass()
    assert(string.match(class, "Weapon.+"), "Unexpected class: " .. class)
    assert(string.match(string.lower(slot11.getName()), "railgun %w+ %[%d+%]"), slot11.getName())
    local expectedIds = {[31327772] = true}
    assert(expectedIds[slot11.getItemId()], "Unexpected id: " .. slot11.getItemId())

    local data = slot11.getWidgetData()
    local expectedFields = {"helperId", "name", "type", "fireCounter", "fireReady", "hitProbability", "hitResult",
                            "operationalStatus", "outOfZone", "repeatedFire", "weaponStatus", "staticProperties",
                            "cycleTime", "magazineVolume", "optimalAimingCone", "optimalDistance", "optimalTracking",
                            "reloadTime", "size", "unloadTime", "targetConstruct", "elementId", "properties",
                            "ammoMax", "ammoName", "ammoTypeId", "cycleAnimationRemainingTime", "fireBlocked",
                            "ammoCount", "baseDamage", "constructId", "disableFire", "impactCounter", "maxDistance",
                            "missCounter"}
    local expectedValues = {}
    local ignoreFields = {}
    expectedValues["helperId"] = '"weapon"'
    expectedValues["type"] = '"weapon"'
    expectedValues["size"] = '"xs"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)

    assert(string.match(slot11.getWidgetDataId(), "e%d+"), "Expected dataId to match e%d pattern: " .. slot11.getWidgetDataId())
    assert(slot11.getMaxHitPoints() >= 300)
    assert(slot11.getMass() == 232.0)
    _G.Utilities.verifyBasicElementFunctions(slot11, 3, "weapon")

    system.print("Success")
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
