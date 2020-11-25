#!/usr/bin/env lua
--- Tests on dumocks.RadarUnit.
-- @see dumocks.RadarUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mru = require("dumocks.RadarUnit")
require("tests.Utilities")

TestRadarUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Radar S (atmo or space), connected to Hovercraft Seat Controller on slot1
--
-- Note: Must be run on a dynamic core.
--
-- Exercises: getElementClass, getData
function _G.TestRadarUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _,element in pairs({"atmospheric radar s", "space radar s"}) do
        mock = mru:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestRadarUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestRadarUnit.gameBehaviorHelper(mock, radar_1)
    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getEntries", "getConstructSize", "getConstructType", "getConstructPos",
                               "getConstructName", "getRange", "hasMatchingTransponder",
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "load"}
    _G.Utilities.verifyExpectedFunctions(radar_1, expectedFunctions)

    -- test element class and inherited methods
    local class = radar_1.getElementClass()
    local isAtmo, isSpace
    if  class == "RadarPvPAtmospheric" then
        isAtmo = true
    elseif class == "RadarPvPSpace" then
        isSpace = true
    else
        assert(false, "Unexpected class: " .. class)
    end

    local data = radar_1.getData()
    local expectedFields = {"helperId", "name", "type", "constructsList", "elementId", "properties"}
    local expectedValues = {}
    local ignoreFields = {"errorMessage", "identifiedConstructs", "identifyConstructs", "radarStatus",
                            "selectedConstruct", "worksInEnvironment", "staticProperties", "ranges", "identify16m",
                            "identify32m", "identify64m", "scan", "worksInAtmosphere", "worksInSpace"}
    expectedValues["helperId"] = '"radar"'
    expectedValues["type"] = '"radar"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)

    assert(string.match(radar_1.getDataId(), "e%d+"), "Expected dataId to match e%d pattern: " .. radar_1.getDataId())
    assert(radar_1.getWidgetType() == "radar")
    radar_1.show()
    radar_1.hide()
    assert(radar_1.getIntegrity() == 100.0 * radar_1.getHitPoints() / radar_1.getMaxHitPoints())
    assert(radar_1.getMaxHitPoints() >= 88)
    assert(radar_1.getId() > 0)
    assert(radar_1.getMass() == 486.72)

    system.print("Success")
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())