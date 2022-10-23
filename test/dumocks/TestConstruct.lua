#!/usr/bin/env lua
--- Tests on dumocks.Construct.
-- @see dumocks.Construct

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mc = require("dumocks.Construct")
require("test.Utilities")

_G.TestConstruct = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Programming Board, no connections
--
-- Exercises: getPvPTimer
function _G.TestConstruct.testGameBehavior()
    local mock = mc:new()
    local construct = mock:mockGetClosure()

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
    local expectedFunctions = {"getName", "getId", "getOwner", "getCreator", "isWarping", "getWarpState", "isInPvPZone",
                               "getDistanceToSafeZone", "getPvPTimer", "getMass", "getInertialMass",
                               "getInertialTensor", "getCenterOfMass", "getWorldCenterOfMass", "getCrossSection",
                               "getSize", "getBoundingBoxSize", "getBoundingBoxCenter", "getMaxSpeed",
                               "getMaxAngularSpeed", "getMaxSpeedPerAxis", "getMaxThrustAlongAxis", "getCurrentBrake",
                               "getMaxBrake", "getWorldPosition", "getVelocity", "getWorldVelocity",
                               "getAbsoluteVelocity", "getWorldAbsoluteVelocity", "getAcceleration",
                               "getWorldAcceleration", "getAngularVelocity", "getWorldAngularVelocity",
                               "getAngularAcceleration", "getWorldAngularAcceleration",
                               "getWorldAirFrictionAcceleration", "getWorldAirFrictionAngularAcceleration",
                               "getFrictionBurnSpeed", "getForward", "getRight", "getUp", "getWorldForward",
                               "getWorldRight", "getWorldUp", "getOrientationUnitId", "getOrientationForward",
                               "getOrientationRight", "getOrientationUp", "getWorldOrientationForward",
                               "getWorldOrientationRight", "getWorldOrientationUp", "getParent", "getClosestParent",
                               "getCloseParents", "getParentPosition", "getParentWorldPosition", "getParentForward",
                               "getParentRight", "getParentUp", "getParentWorldForward", "getParentWorldRight",
                               "getParentWorldUp", "getPlayersOnBoard", "getPlayersOnBoardInVRStation",
                               "isPlayerBoarded", "isPlayerBoardedInVRStation", "getBoardedPlayerMass",
                               "getBoardedInVRStationAvatarMass", "getDockedConstructs", "isConstructDocked",
                               "getDockedConstructMass", "setDockingMode", "getDockingMode", "dock", "undock",
                               "forceDeboard", "forceUndock", "forceInterruptVRSession", "load"}
    _G.Utilities.verifyExpectedFunctions(construct, expectedFunctions)

    assert(construct.getPvPTimer() == 0.0)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
