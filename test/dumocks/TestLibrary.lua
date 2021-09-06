#!/usr/bin/env lua
--- Tests on dumocks.Library.
-- @see dumocks.Library

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local ml = require("dumocks.Library")
require("test.Utilities")

_G.TestLibrary = {}

--- Verify results pre-load properly for systemResolution3.
function _G.TestLibrary.testSystemResolution3()
    local library = ml:new()
    local closure = library:mockGetClosure()
    local expected, actual

    local resultSequence = {}
    resultSequence[1] = {1, 2, 3}
    resultSequence[2] = {2, 3, 4}

    -- load results in order into solutions list
    table.insert(library.systemResolution3Solutions, resultSequence[1])
    table.insert(library.systemResolution3Solutions, resultSequence[2])

    expected = resultSequence[1]
    actual = closure.systemResolution3({1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {0, 1, 2})
    lu.assertEquals(actual, expected)

    expected = resultSequence[2]
    actual = closure.systemResolution3({1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {0, 1, 2})
    lu.assertEquals(actual, expected)
end

--- Verify error when attempting to run without loading results.
function _G.TestLibrary.testSystemResolution3Error()
    local library = ml:new()
    local closure = library:mockGetClosure()

    -- no results primed
    lu.assertErrorMsgContains("Solution 1 not loaded.", closure.systemResolution3, {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {0, 1, 2})
end

--- Verify results pre-load properly for systemResolution2.
function _G.TestLibrary.testSystemResolution2()
    local library = ml:new()
    local closure = library:mockGetClosure()
    local expected, actual

    local resultSequence = {}
    resultSequence[1] = {1, 2}
    resultSequence[2] = {2, 3}

    -- load results in order into solutions list
    table.insert(library.systemResolution2Solutions, resultSequence[1])
    table.insert(library.systemResolution2Solutions, resultSequence[2])

    expected = resultSequence[1]
    actual = closure.systemResolution2({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
    lu.assertEquals(actual, expected)

    expected = resultSequence[2]
    actual = closure.systemResolution2({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
    lu.assertEquals(actual, expected)
end

--- Verify error when attempting to run without loading results.
function _G.TestLibrary.testSystemResolution2Error()
    local library = ml:new()
    local closure = library:mockGetClosure()

    -- no results primed
    lu.assertErrorMsgContains("Solution 1 not loaded.", closure.systemResolution2, {1, 2, 3}, {4, 5, 6}, {7, 8, 9})
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Programming Board, no connections
--
-- Exercises:
function _G.TestLibrary.testGameBehavior()
    local mock = ml:new()
    local library = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"systemResolution3", "systemResolution2", "load"}
    _G.Utilities.verifyExpectedFunctions(library, expectedFunctions)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())