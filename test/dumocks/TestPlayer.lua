#!/usr/bin/env lua
--- Tests on dumocks.Player.
-- @see dumocks.Player

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mp = require("dumocks.Player")
require("test.Utilities")

_G.TestPlayer = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Programming Board, no connections
--
-- Exercises: getId, getMass, getNanopackVolume, getNanopackMaxVolume, isSeated, isSprinting, setHeadlightOn,
--   isHeadlightOn, freeze, isFrozen, hasDRMAutorization
function _G.TestPlayer.testGameBehavior()
    local mock = mp:new()
    local player = mock:mockGetClosure()

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
    local expectedFunctions = {"getName", "getId", "getMass", "getNanopackMass", "getNanopackVolume",
                               "getNanopackMaxVolume", "getOrgIds", "getPosition", "getWorldPosition",
                               "getHeadPosition", "getWorldHeadPosition", "getVelocity", "getWorldVelocity",
                               "getAbsoluteVelocity", "getForward", "getRight", "getUp", "getWorldForward",
                               "getWorldRight", "getWorldUp", "getPlanet", "getParent", "isSeated", "getSeatId",
                               "isParentedTo", "isSprinting", "isJetpackOn", "isHeadlightOn", "setHeadlightOn",
                               "freeze", "isFrozen", "hasDRMAutorization", "load"}
    _G.Utilities.verifyExpectedFunctions(player, expectedFunctions)

    assert(player.getId() > 0)
    assert(player.getMass() == 90.0, "Unexpected player mass: " .. player.getMass())
    local nanopackMaxVolume = player.getNanopackMaxVolume()
    assert(nanopackMaxVolume >= 4000 and nanopackMaxVolume <= 6250, "Unexpected max nanopack volume: " .. nanopackMaxVolume)
    local nanopackVolume = player.getNanopackVolume()
    assert(nanopackVolume >= 0 and nanopackVolume <= nanopackMaxVolume)

    assert(player.isSeated() == 0)
    assert(player.isSprinting() == 0)
    --assert(player.isJetpackOn() == 0) returns 1 on planets?

    player.setHeadlightOn(false)
    assert(player.isHeadlightOn() == 0)
    player.setHeadlightOn(true)
    assert(player.isHeadlightOn() == 1)
    player.setHeadlightOn(false)
    assert(player.isHeadlightOn() == 0)
    player.setHeadlightOn(1)
    assert(player.isHeadlightOn() == 1)
    player.setHeadlightOn(0)
    assert(player.isHeadlightOn() == 0)

    -- reports state as expected but doesn't actually freeze player from a programming board?
    player.freeze(false)
    assert(player.isFrozen() == 0)
    player.freeze(true)
    assert(player.isFrozen() == 1)
    player.freeze(false)
    assert(player.isFrozen() == 0)
    player.freeze(1)
    assert(player.isFrozen() == 1)
    player.freeze(0)
    assert(player.isFrozen() == 0)

    assert(player.hasDRMAutorization() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
