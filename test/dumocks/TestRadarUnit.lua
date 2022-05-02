#!/usr/bin/env lua
--- Tests on dumocks.RadarUnit.
-- @see dumocks.RadarUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mru = require("dumocks.RadarUnit")
require("test.Utilities")

TestRadarUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Radar S (atmo or space), connected to Programming Board on slot1
--
-- Note: Must be run on a dynamic core.
--
-- Exercises: getElementClass, getData
function _G.TestRadarUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"atmospheric radar s", "space radar s"}) do
        mock = mru:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestRadarUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestRadarUnit.gameBehaviorHelper(mock, slot1)
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
    -- verify expected functions
    local expectedFunctions = {"getEntries", "getConstructSize", "getConstructType", "getConstructPos",
                               "getConstructName", "getRange", "hasMatchingTransponder", "isConstructAbandoned",
                               "isOperational", "isConstructIdentified", "getConstructIds", "getIdentifyRanges",
                               "getConstructAngularSpeed", "getTargetId", "getConstructDistance",
                               "getConstructCoreSize", "getConstructInfos", "getConstructRadialSpeed",
                               "getConstructSpeed", "getIdentifiedConstructIds", "getConstructWorldVelocity",
                               "getConstructVelocity", "getConstructOwner", "getConstructWorldPos", "getThreatFrom",
                               "getThreatTo", "getConstructMass"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getElementClass()
    local isAtmo, isSpace
    if string.match(class, "RadarPvPAtmospheric") then
        isAtmo = true
    elseif string.match(class, "RadarPVPSpace") then
        isSpace = true
    else
        assert(false, "Unexpected class: " .. class)
    end

    local data = slot1.getData()
    local expectedFields = {"helperId", "name", "type", "constructsList", "elementId", "properties", "currentTargetId"}
    local expectedValues = {}
    local ignoreFields = {"errorMessage", "identifiedConstructs", "identifyConstructs", "radarStatus",
                          "selectedConstruct", "worksInEnvironment", "staticProperties", "ranges", "identify16m",
                          "identify32m", "identify64m", "identify128m", "scan", "worksInAtmosphere", "worksInSpace",
                          "maxIdentifiedTargets","broken"}
    expectedValues["helperId"] = '"radar"'
    expectedValues["type"] = '"radar"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)

    assert(slot1.getMaxHitPoints() >= 88)
    assert(slot1.getMass() == 486.72)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "radar")

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
