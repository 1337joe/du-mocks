#!/usr/bin/env lua
--- Test the utilties for running tests.
-- @see tests.Utilities

local lu = require("luaunit")
require("test.Utilities")

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

--- Verify verifyBasicElementFunctions finds problems.
function _G.TestUtilities.testVerifyBasicElementFunctions()
    local element
    local result, message

    local function createSampleElement()
        local sample = {}
        sample.id = 1
        sample.integrity = 50
        sample.hitPoints = 75
        sample.maxHitPoints = 150
        sample.maxRestorations = 3
        sample.remainingRestorations = 3
        sample.widgetType = ""
        sample.dataId = ""
        sample.data = "{}"

        sample.getId = function()
            return sample.id
        end
        sample.getIntegrity = function()
            return sample.integrity
        end
        sample.getHitPoints = function()
            return sample.hitPoints
        end
        sample.getMaxHitPoints = function()
            return sample.maxHitPoints
        end
        sample.getMaxRestorations = function()
            return sample.maxRestorations
        end
        sample.getRemainingRestorations = function()
            return sample.remainingRestorations
        end
        sample.getWidgetType = function()
            return sample.widgetType
        end
        sample.getDataId = function()
            return sample.dataId
        end
        sample.getData = function()
            return sample.data
        end
        sample.show = function()
        end
        sample.hide = function()
        end
        return sample
    end

    -- id not set
    element = createSampleElement()
    element.id = nil
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    lu.assertStrIContains(message, "invalid id")

    -- integrity/hp/max hp relationship broken
    element = createSampleElement()
    element.integrity = 100
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    element = createSampleElement()
    element.hitPoints = 100
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    element = createSampleElement()
    element.maxHitPoints = 100
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)

    -- max restorations is different
    element = createSampleElement()
    element.maxRestorations = 4
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    lu.assertStrIContains(message, "max restorations")

    -- remaining restorations is different
    element = createSampleElement()
    element.remainingRestorations = 2
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    lu.assertStrIContains(message, "remaining restorations")

    -- widget not set but expected
    element = createSampleElement()
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, "unknown_widget")
    lu.assertFalse(result)
    lu.assertStrIContains(message, "expected widget type unknown_widget")

    -- widget set but not expected
    element = createSampleElement()
    element.widgetType = "unexpected_widget"
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    lu.assertStrIContains(message, "unexpected widget type")
    -- widget set but mismatched
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, "unknown_widget")
    lu.assertFalse(result)
    lu.assertStrIContains(message, "expected widget type unknown_widget")

    -- data id missing/wrong
    element = createSampleElement()
    element.widgetType = "expected_widget"
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, "expected_widget")
    lu.assertFalse(result)
    lu.assertStrIContains(message, "expected dataid to match")
    element.dataId = 5
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, "expected_widget")
    lu.assertFalse(result)
    lu.assertStrIContains(message, "expected dataid to match")
    -- data id unexpected
    element.widgetType = ""
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)
    lu.assertStrIContains(message, "unexpected data id")

    -- unexpected data
    element = createSampleElement()
    element.data = [[{"text":"blah"}]]
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, "")
    lu.assertFalse(result)
    lu.assertStrIContains(message, "unexpected data:")

    -- show fails
    element = createSampleElement()
    element.show = function()
        error("bad show")
    end
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)

    -- hide fails
    element = createSampleElement()
    element.hide = function()
        error("bad hide")
    end
    result, message = pcall(_G.Utilities.verifyBasicElementFunctions, element, 3, nil)
    lu.assertFalse(result)

    -- no error
    element = createSampleElement()
    _G.Utilities.verifyBasicElementFunctions(element, 3, nil)
    _G.Utilities.verifyBasicElementFunctions(element, 3, "")
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