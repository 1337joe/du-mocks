#!/usr/bin/env lua
--- Test the utilties for running tests.
-- @see tests.Utilities

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")
require("tests.Utilities")

_G.TestUtilities = {}

--- Verify verifyExpectedFunctions finds problems.
function _G.TestUtilities.testVerifyExpectedFunctions()
    local expected, actual
    local result, message

    -- unexpected
    expected = {}
    actual = {
        activate = function() end
    }
    local result, message = pcall(_G.Utilities.verifyExpectedFunctions, actual, expected)
    lu.assertFalse(result)
    lu.assertStrContains(message, "Found unexpected functions: activate")
    lu.assertNotStrContains(message, "Missing expected functions:")

    -- missing
    expected = {"activate"}
    actual = {}
    local result, message = pcall(_G.Utilities.verifyExpectedFunctions, actual, expected)
    lu.assertFalse(result)
    lu.assertNotStrContains(message, "Found unexpected functions:")
    lu.assertStrContains(message, "Missing expected functions: activate")

    -- both unexpected and missing
    expected = {"deactivate"}
    actual = {
        activate = function() end
    }
    local result, message = pcall(_G.Utilities.verifyExpectedFunctions, actual, expected)
    lu.assertFalse(result)
    lu.assertStrContains(message, "Found unexpected functions: activate")
    lu.assertStrContains(message, "Missing expected functions: deactivate")

    -- no error
    expected = {"activate"}
    actual = {
        activate = function() end
    }
    _G.Utilities.verifyExpectedFunctions(actual, expected)
end

--- Verify verifyWidgetData finds problems.
function _G.TestUtilities.testVerifyWidgetData()
    local data, expectedFields, expectedValues
    local result, message

    -- missing field
    local data = '{}'
    local expectedFields = {"helperId"}
    local expectedValues = {}
    expectedValues["helperId"] = '"gyro"'
    lu.assertErrorMsgContains("Missing expected data fields: helperId", _G.Utilities.verifyWidgetData, data, expectedFields, expectedValues)

    -- wrong value
    local data = '{"helperId":"something else"}'
    local expectedFields = {"helperId"}
    local expectedValues = {}
    expectedValues["helperId"] = '"gyro"'
    lu.assertErrorMsgContains("Unexpected value for helperId, expected \"gyro\"", _G.Utilities.verifyWidgetData, data, expectedFields, expectedValues)

    -- unexpected field
    local data = '{"helperId":"gyro","type":"gyro"}'
    local expectedFields = {"helperId"}
    local expectedValues = {}
    expectedValues["helperId"] = '"gyro"'
    lu.assertErrorMsgContains("Found unexpected data fields: type", _G.Utilities.verifyWidgetData, data, expectedFields, expectedValues)

    -- no error, all checks hit
    local data = '{"helperId":"gyro"}'
    local expectedFields = {"helperId"}
    local expectedValues = {}
    expectedValues["helperId"] = '"gyro"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)
end

os.exit(lu.LuaUnit.run())