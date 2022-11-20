#!/usr/bin/env lua
--- Tests on dumocks.BrakeUnit.
-- @see dumocks.BrakeUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mbu = require("dumocks.BrakeUnit")
require("test.Utilities")

TestBrakeUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. brake of any size, connected to Programming Board on slot1
--
-- Exercises: getClass, getWidgetData
function _G.TestBrakeUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"atmospheric airbrake s", "retro-rocket brake s"}) do
        mock = mbu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestBrakeUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestBrakeUnit.gameBehaviorHelper(mock, slot1)
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
    local expectedFunctions = {"activate", "deactivate", "isActive", "toggle", "setThrust", "getThrust",
                               "getMaxThrust", "getCurrentMinThrust", "getCurrentMaxThrust", "getMaxThrustEfficiency",
                               "getThrustAxis", "getWorldThrustAxis",
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
    if class == "Airbrake" then
        expectedName = "atmospheric airbrake"
        expectedIds = {[65048663] = true, [2198271703] = true, [104971834] = true}
    elseif class == "Spacebrake" then
        expectedName = "retro%-rocket brake"
        expectedIds = {[3039211660] = true, [3243532126] = true, [1452351552] = true}
    else
        assert(false, "Unexpected class: " .. class)
    end
    expectedName = expectedName .. " %w %[%d+%]"
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
