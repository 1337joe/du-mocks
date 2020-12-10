--- Utilties for running tests.
-- @module Utilities

local lu = require("luaunit")

---------------
-- copy from here to library.start()
---------------
_G.Utilities = {}

_G.Utilities.elementFunctions = {"show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity",
                                 "getHitPoints", "getMaxHitPoints", "getId", "getMass", "getElementClass",
                                 "load", "getRemainingRestorations", "getMaxRestorations"}
_G.Utilities.toggleFunctions = {"activate", "deactivate", "toggle", "getState"}

--- Verifies that exactly the expected functions are found in the target element.
-- @param element The element to test.
-- @tparam table expectedFunctions A list of the functions expected to be found in the element.
function _G.Utilities.verifyExpectedFunctions(element, expectedFunctions)
    local unexpectedFunctions = {}
    for key, value in pairs(element) do
        if key:match("library_.+") or key:match("system_.+") or key:match("unit_.+") then
            -- skip - function is a slot filter
        elseif type(value) == "function" then
            for index, funcName in pairs(expectedFunctions) do
                if key == funcName then
                    table.remove(expectedFunctions, index)
                    goto continueOuter
                end
            end

            local functionDescription = key

            -- unknown function, try to get parameters
            -- taken from hdparm's global dump script posted on forum
            local dump_success, dump_result = pcall(string.dump, value)
            if dump_success then
                local params = string.match(dump_result, "function%s+[^%s)]*" .. key .. "%s*%(([^)]*)%)")
                if params then
                    params = params:gsub(",%s+", ",") -- remove whitespace after function parameter names
                    functionDescription = string.format("%s(%s)", functionDescription, params)
                end
            end

            table.insert(unexpectedFunctions, functionDescription)
        end

        ::continueOuter::
    end
    local message = ""
    if #expectedFunctions > 0 then
        message = message .. "Missing expected functions: " .. table.concat(expectedFunctions, ", ") .. "\n"
    end
    if #unexpectedFunctions > 0 then
        message = message .. "Found unexpected functions: " .. table.concat(unexpectedFunctions, ", ") .. "\n"
    end
    if message:len() > 0 then
        if system and system.print and type(system.print) == "function" then
            system.print(message)
        end
        assert(false, message)
    end
end

--- Verify basic element functions.
-- @tparameter Element slot The element to test.
-- @tparameter int expectedRestorations The expected max (and remaining) restorations for the element.
function _G.Utilities.verifyBasicElementFunctions(slot, expectedRestorations)
    assert(slot.getMaxRestorations() == expectedRestorations, string.format("Max restorations: %d", slot.getMaxRestorations()))
    assert(slot.getRemainingRestorations() == expectedRestorations,
        string.format("Remaining restorations: %d", slot.getRemainingRestorations()))
end

--- Verifies exactly the expected fields and values are found within the widget data.
-- @tparam string data The widget data to test.
-- @tparam table expectedFields The list of fields to look for.
-- @tparam table expectedValues A mapping from field to value for any specific values that should be found.
-- @tparam table ignoreFields Optional list of fields which may or may not be present.
function _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)
    ignoreFields = ignoreFields or {}
    local unexpectedFields = {}
    for key, value in string.gmatch(data, "\"(.-)\":(.-)[},]") do
        if expectedValues[key] then
            assert(expectedValues[key] == value,
                "Unexpected value for " .. key .. ", expected " .. expectedValues[key] .. " but was " .. value)
        end

        -- skip ignored fields, don't add to list, don't remove
        for index, field in pairs(ignoreFields) do
            if key == field then
                goto continueOuter
            end
        end

        for index, field in pairs(expectedFields) do
            if key == field then
                table.remove(expectedFields, index)
                goto continueOuter
            end
        end

        table.insert(unexpectedFields, key)

        ::continueOuter::
    end
    assert(#expectedFields == 0, "Missing expected data fields: " .. table.concat(expectedFields, ", "))
    assert(#unexpectedFields == 0, "Found unexpected data fields: " .. table.concat(unexpectedFields, ", "))
end
---------------
-- copy to here to library.start()
---------------

return _G.Utilities
