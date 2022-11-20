#!/usr/bin/env lua
--- Tests on dumocks.AdjustorUnit.
-- @see dumocks.AdjustorUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mau = require("dumocks.AdjustorUnit")
require("test.Utilities")

TestAdjustorUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. adjustor of any size, connected to Programming Board on slot1
--
-- Exercises: getClass, getWidgetData
function _G.TestAdjustorUnit.testGameBehavior()
    local mock = mau:new(nil, 1)
    local slot1 = mock:mockGetClosure()

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
                               "getMaxThrust", "getThrustAxis", "getTorqueAxis", "getWorldThrustAxis",
                               "getWorldTorqueAxis", "getSignalIn", "setSignalIn",
                               "getObstructionFactor", "getTags", "setTags", "isIgnoringTags",
                               "getState", "getT50", "getFuelRateEfficiency", "getDistance", "getFuelConsumption",
                               "isOutOfFuel", "torqueAxis", "hasFunctionalFuelTank", "thrustAxis",
                               "getCurrentFuelRate", "getMaxThrustBase"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "Adjustor")
    assert(string.match(string.lower(slot1.getName()), "adjustor %w+ %[%d+%]"), slot1.getName())
    local expectedId = {[2648523849] = true, [47474508] = true, [3790013467] = true, [2818864930] = true}
    assert(expectedId[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())
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

    slot1.activate()

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
