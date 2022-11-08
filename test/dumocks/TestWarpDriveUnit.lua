#!/usr/bin/env lua
--- Tests on dumocks.WarpDriveUnit.
-- @see dumocks.WarpDriveUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mwdu = require("dumocks.WarpDriveUnit")
require("test.Utilities")

TestWarpDriveUnit = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Warp Drive, connected to Programming Board on slot1
--
-- Exercises: getClass, getData
function _G.TestWarpDriveUnit.testGameBehavior()
    local mock = mwdu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

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
    local expectedFunctions = {"initiate", "getStatus", "getDistance", "getDestination", "getDestinationName",
                               "getContainerId", "getAvailableWarpCells", "getRequiredWarpCells"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "WarpDriveUnit")
    assert(string.match(string.lower(slot1.getName()), "warp drive l %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 4015850440, "Unexpected id: " .. slot1.getItemId())

    local data = slot1.getWidgetData()
    local expectedFields = {"buttonText", "cellCount", "destination", "distance", "elementId", "showError",
                            "helperId", "name", "type", "enableButton", "statusText"}
    local expectedValues = {}
    expectedValues["helperId"] = '"warpdrive"'
    expectedValues["type"] = '"warpdrive"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() == 43117.0)
    assert(slot1.getMass() == 75000.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "warpdrive")

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
