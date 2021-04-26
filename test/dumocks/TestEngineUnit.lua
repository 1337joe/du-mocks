#!/usr/bin/env lua
--- Tests on dumocks.EngineUnit.
-- @see dumocks.EngineUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local meu = require("dumocks.EngineUnit")
require("test.Utilities")

TestEngineUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. engine unit of any type, connected to Programming Board on slot1
--
-- Exercises: getElementClass, getData, isRemoteControlled
function _G.TestEngineUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"hover engine s", "vertical booster s", "retro-rocket brake s", "atmospheric airbrake s",
                             "atmospheric airbrake l", "wing xs", "compact aileron xs", "aileron xs", "stabilizer xs",
                             "adjustor xs", "basic atmospheric engine xs", "basic space engine xs",
                             "basic space engine s", "rocket engine s"}) do
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
    system.print = function()
    end

    ---------------
    -- copy from here to unit.start()
    ---------------
    local class = slot1.getElementClass()
    local validClasses = {"Hovercraft", "VerticalBooster", "Spacebrake", "Airbrake", "Wing2", "Aileron2", "Stabilizer",
                          "Adjustor", "AtmosphericEngine.+Group", "SpaceEngine.+Group", "RocketEngine"}
    local valid = false
    for _, vClass in pairs(validClasses) do
        if string.match(class, vClass) then
            valid = true
            break
        end
    end
    assert(valid, "Unexpected class: " .. class)

    -- verify expected functions
    local expectedFunctions = {"setThrust", "getMaxThrustBase", "getMaxThrust", "getMinThrust", "getFuelRate",
                               "getMaxThrustEfficiency", "getThrust", "torqueAxis", "thrustAxis", "distance",
                               "isOutOfFuel", "hasBrokenFuelTank", "getCurrentFuelRate", "getFuelRateEfficiency",
                               "getT50", "isObstructed", "getObstructionFactor", "getTags", "setTags",
                               "getFuelConsumption", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test inherited methods
    local data = slot1.getData()
    local expectedFields = {"helperId", "name", "type", "currentMaxThrust", "currentThrust", "maxThrustBase"}
    local expectedValues = {}
    expectedValues["type"] = '"engine_unit"'
    expectedValues["helperId"] = '"engine_unit"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)
    assert(slot1.getWidgetType() == "engine_unit")

    assert(string.match(slot1.getDataId(), "e%d+"), "Expected dataId to match e%d pattern: " .. slot1.getDataId())

    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() > 7.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
