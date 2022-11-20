#!/usr/bin/env lua
--- Tests on dumocks.AirfoilUnit.
-- @see dumocks.AirfoilUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mau = require("dumocks.AirfoilUnit")
require("test.Utilities")

TestAirfoilUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. airfoil of any size, connected to Programming Board on slot1
--
-- Exercises: getClass, getWidgetData
function _G.TestAirfoilUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"wing xs", "compact aileron xs", "aileron xs", "stabilizer xs"}) do
        mock = mau:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestAirfoilUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestAirfoilUnit.gameBehaviorHelper(mock, slot1)
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
    local expectedFunctions = {"getLift", "getMaxLift", "getDrag", "getDragRatio", "getCurrentMinLift",
                               "getMaxLiftEfficiency", "getLiftAxis", "getTorqueAxis", "getWorldLiftAxis",
                               "getWorldTorqueAxis", "isStalled", "getStallAngle", "getMinAngle", "getMaxAngle",
                               "getCurrentMaxLift",
                               "getObstructionFactor", "getTags", "setTags", "isIgnoringTags",
                               "setThrust", "getThrust", "getMinThrust", "getMaxThrust", "getMaxThrustEfficiency",
                               "getSignalIn", "setSignalIn", "activate", "deactivate", "toggle", "getState", "getT50",
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
    if class == "Stabilizer" then
        expectedName = "stabilizer"
        expectedIds = {[1455311973] = true, [1234961120] = true, [3474622996] = true, [1090402453] = true}
    elseif class == "Aileron2" then
        expectedName = "aileron"
        expectedIds = {[2334843027] = true, [2292270972] = true, [1923840124] = true, [2737703104] = true, [4017253256] = true, [1856288931] = true}
    elseif class == "Wing2" then
        expectedName = "wing"
        expectedIds = {[1727614690] = true, [2532454166] = true, [404188468] = true, [4179758576] = true}
    else
        assert(false, "Unexpected class: " .. class)
    end
    expectedName = expectedName .. " %w+ %[%d+%]"
    assert(string.match(string.lower(slot1.getName()), expectedName), slot1.getName())
    assert(expectedIds[slot1.getItemId()], "Unexpected ID: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() >= 25.0)

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
