#!/usr/bin/env lua
--- Tests on dumocks.EngineUnit.
-- @see dumocks.EngineUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local meu = require("dumocks.EngineUnit")
require("test.Utilities")

TestEngineUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. atmo, space, or rocket engine of any size, connected to Programming Board on slot1
--
-- Exercises: getClass, getWidgetData
function _G.TestEngineUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"basic atmospheric engine xs", "basic space engine xs", "rocket engine s"}) do
        mock = meu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestEngineUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestEngineUnit.gameBehaviorHelper(mock, slot1)
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
    local expectedFunctions = {"isTorqueEnabled", "enableTorque", "getFuelId", "getFuelTankId",
                               "getWarmupTime", "hasBrokenFuelTank",
                               "activate", "deactivate", "isActive", "toggle", "setThrust", "getThrust",
                               "getMaxThrust", "getCurrentMinThrust", "getCurrentMaxThrust", "getMaxThrustEfficiency",
                               "getThrustAxis", "getTorqueAxis", "getWorldThrustAxis", "getWorldTorqueAxis",
                               "getObstructionFactor", "getTags", "setTags", "isIgnoringTags",
                               "getMinThrust",
                               "getSignalIn", "setSignalIn", "getState", "getT50",
                               "getFuelRateEfficiency", "getDistance", "getFuelConsumption", "isOutOfFuel",
                               "torqueAxis", "hasFunctionalFuelTank", "thrustAxis", "getCurrentFuelRate",
                               "getMaxThrustBase"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getClass()
    local expectedName, expectedIds
    if string.match(class, "AtmosphericEngine%w+Group") then
        expectedName = "%w+ atmospheric engine"
        expectedIds = {[710193240] = true}
    elseif string.match(class, "SpaceEngine%w+Group") then
        expectedName = "%w+ space engine"
        expectedIds = {[2243775376] = true}
    elseif class == "RocketEngine" then
        expectedName = "rocket engine"
        expectedIds = {[2112772336] = true, [3623903713] = true, [359938916] = true}
    else
        assert(false, "Unexpected class: " .. class)
    end
    expectedName = expectedName .. " %w+ %[%d+%]"
    assert(string.match(string.lower(slot1.getName()), expectedName), slot1.getName())
    assert(expectedIds[slot1.getItemId()], "Unexpected ID: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() >= 100.0)

    -- test inherited methods
    local data = slot1.getWidgetData()
    local expectedFields = {"helperId", "name", "type", "currentMaxThrust", "currentThrust", "maxThrustBase"}
    local expectedValues = {}
    expectedValues["type"] = '"engine_unit"'
    expectedValues["helperId"] = '"engine_unit"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() > 7.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "engine_unit")

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
