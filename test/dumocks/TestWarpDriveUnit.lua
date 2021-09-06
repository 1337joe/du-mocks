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
-- Exercises: getElementClass, getData
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
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "WarpDriveUnit")

    local data = slot1.getData()
    local expectedFields = {"buttonMsg", "cellCount", "destination", "distance", "elementId", "errorMsg", "showError",
                            "helperId", "name", "type"}
    local expectedValues = {}
    expectedValues["helperId"] = '"warpdrive"'
    expectedValues["type"] = '"warpdrive"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() == 43117.0)
    assert(slot1.getMass() == 31360.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "warpdrive")

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
