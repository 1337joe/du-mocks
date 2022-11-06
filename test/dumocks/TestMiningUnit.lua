#!/usr/bin/env lua
--- Tests on dumocks.MiningUnit.
-- @see dumocks.MiningUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mmu = require("dumocks.MiningUnit")
require("test.Utilities")

_G.TestMiningUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestMiningUnit.testConstructor()

    -- default element:
    -- ["basic mining unit s"] = {mass = 180.0, maxHitPoints = 2500.0, itemId = 1949562989}

    local miner0 = mmu:new()
    local miner1 = mmu:new(nil, 1, "Basic Mining Unit S")
    local miner2 = mmu:new(nil, 2, "invalid")
    local miner3 = mmu:new(nil, 3, "Basic Mining Unit L")

    local minerClosure0 = miner0:mockGetClosure()
    local minerClosure1 = miner1:mockGetClosure()
    local minerClosure2 = miner2:mockGetClosure()
    local minerClosure3 = miner3:mockGetClosure()

    lu.assertEquals(minerClosure0.getLocalId(), 0)
    lu.assertEquals(minerClosure1.getLocalId(), 1)
    lu.assertEquals(minerClosure2.getLocalId(), 2)
    lu.assertEquals(minerClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 180.0
    lu.assertEquals(minerClosure0.getMass(), defaultMass)
    lu.assertEquals(minerClosure1.getMass(), defaultMass)
    lu.assertEquals(minerClosure2.getMass(), defaultMass)
    lu.assertNotEquals(minerClosure3.getMass(), defaultMass)

    local defaultId = 1949562989
    lu.assertEquals(minerClosure0.getItemId(), defaultId)
    lu.assertEquals(minerClosure1.getItemId(), defaultId)
    lu.assertEquals(minerClosure2.getItemId(), defaultId)
    lu.assertNotEquals(minerClosure3.getItemId(), defaultId)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Basic Mining Unit S, connected to Programming Board on slot1
--
-- Exercises: getClass
function _G.TestMiningUnit.testGameBehavior()
    local mock = mmu:new(nil, 1, "basic mining unit s")
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
    local expectedFunctions = {"getStatus", "getRemainingTime", "getActiveOre", "getOrePools", "getBaseRate",
                               "getEfficiency", "getAdjacencyBonus", "getCalibrationRate", "getOptimalRate",
                               "getProductionRate", "getLastExtractionPosition", "getLastExtractingPlayerId",
                               "getLastExtractionTime", "getLastExtractedVolume", "getLastExtractedOre", "getState"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "MiningUnit")
    assert(string.match(string.lower(slot1.getName()), "%w+ mining unit %w %[%d+%]"), slot1.getName())
    local expectedIds = {[1949562989] = true, [3204140760] = true, [3204140761] = true, [3204140766] = true,
                         [3204140767] = true, [3204140764] = true}
    assert(expectedIds[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 2500.0)
    assert(slot1.getMass() == 180.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- assert(slot1.getAdjacencyBonus() <= 60.0)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
