#!/usr/bin/env lua
--- Tests on dumocks.System.
-- @see dumocks.System

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local ms = require("dumocks.System")
require("tests.Utilities")

_G.TestSystem = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Programming Board, no connections
--
-- Exercises:
function _G.TestSystem.testGameBehavior()
    local mock = ms:new()
    local system = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getActionKeyName", "showScreen", "setScreen", "createWidgetPanel", "destroyWidgetPanel",
                               "createWidget", "destroyWidget", "createData", "destroyData", "updateData",
                               "addDataToWidget", "removeDataFromWidget", "getMouseWheel", "getMouseDeltaX",
                               "getMouseDeltaY", "getMousePosX", "getMousePosY", "getThrottleInputFromMouseWheel",
                               "getControlDeviceForwardInput", "getControlDeviceYawInput",
                               "getControlDeviceLeftRightInput", "lockView", "isViewLocked", "freeze", "isFrozen",
                               "getTime", "getActionUpdateDeltaTime", "getPlayerName", "getPlayerWorldPos", "print",
                               "load", "logInfo", "logWarning", "logError", "addMarker", "addMeasure",
                               "__NQ_returnFromRunPlayerLUA"}
    _G.Utilities.verifyExpectedFunctions(system, expectedFunctions)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
