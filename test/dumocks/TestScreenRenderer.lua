#!/usr/bin/env lua
--- Tests on dumocks.ScreenRenderer.
-- @see dumocks.ScreenRenderer

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")
local sr = require("dumocks.ScreenRenderer")

_G.TestScreenRenderer = {}

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Screen or Sign, paste relevent bit directly into render script
--
-- Exercises: ??TODO??
function _G.TestScreenRenderer.testGameBehavior()

    local screenRenderer = sr:new()

    local oldEnv = _ENV

    local closure = screenRenderer:mockGetEnvironment()
    local _ENV = closure
    ---------------
    -- copy from here to renderer
    ---------------

    local expectedFunctions = {"getCursor", "createLayer", "getResolution", "addCircle", "setNextFillColor",
                               "setNextStrokeColor", "getDeltaTime", "addImage", "loadImage", "setNextRotation",
                               "loadFont", "setNextRotationDegrees", "addTriangle", "requestAnimationFrame", "addQuad",
                               "setNextStrokeWidth", "addText", "getRenderCostMax", "addLine", "getRenderCost",
                               "addBox", "getInput", "setOutput", "setDefaultRotation", "isImageLoaded",
                               "setDefaultShadow", "setDefaultStrokeColor", "setNextTextAlign", "setNextShadow",
                               "isFontLoaded", "setDefaultStrokeWidth", "addBoxRounded", "setBackgroundColor",
                               "getCursorPressed", "getCursorReleased", "getCursorDown", "setDefaultFillColor",
                               "getFontMetrics", "getTextBounds", "logMessage", "getTime", "getAvailableFontName",
                               "getAvailableFontCount",
                               "next", "pairs", "ipairs", "select", "type", "tostring", "tonumber", "pcall", "xpcall",
                               "assert", "error", "load", "require", "setmetatable", "getmetatable"}
    local unexpectedFunctions = {}

    local expectedTables = {"table", "string", "math"}
    local unexpectedTables = {}

    local expectedStrings = {
        ["_VERSION"] = "Lua 5.3"
    }
    local unexpectedStrings = {}

    local expectedNumbers = {
        Shape_Box = 0,
        Shape_BoxRounded = 1,
        Shape_Circle = 2,
        Shape_Image = 3,
        Shape_Line = 4,
        Shape_Polygon = 5,
        Shape_Text = 6,

        AlignH_Left = 0,
        AlignH_Center = 1,
        AlignH_Right = 2,

        AlignV_Ascender = 0,
        AlignV_Top = 1,
        AlignV_Middle = 2,
        AlignV_Baseline = 3,
        AlignV_Bottom = 4,
        AlignV_Descender = 5,
    }
    local unexpectedNumbers = {}

    local other = {}
    for key, value in pairs(_ENV) do
        if type(value) == "function" then
            for index, name in pairs(expectedFunctions) do
                if key == name then
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
        elseif type(value) == "table" then
            for index, name in pairs(expectedTables) do
                if key == name then
                    table.remove(expectedTables, index)
                    goto continueOuter
                end
            end
            table.insert(unexpectedTables, key)
        elseif type(value) == "string" then
            local expected = expectedStrings[key]
            if expected then
                expectedStrings[key] = nil
                if expected == value then
                    goto continueOuter
                end
            end
            table.insert(unexpectedStrings, string.format("%s=%s (%s)", key, value, expected))
        elseif type(value) == "number" then
            local expected = expectedNumbers[key]
            if expected then
                expectedNumbers[key] = nil
                if expected == value then
                    goto continueOuter
                end
            end
            table.insert(unexpectedNumbers, string.format("%s=%s (%s)", key, value, expected))
        else
            table.insert(other, string.format("%s(%s)", key, type(value)))
        end

        ::continueOuter::
    end

    local message = ""

    if #expectedFunctions > 0 then
        message = message .. "Missing expected functions. " .. table.concat(expectedFunctions, ", ") .. "\n"
    end
    if #unexpectedFunctions > 0 then
        message = message .. "Found unexpected functions. " .. table.concat(unexpectedFunctions, ", ") .. "\n"
    end

    if #expectedTables > 0 then
        message = message .. "Missing expected tables. " .. table.concat(expectedTables, ", ") .. "\n"
    end
    if #unexpectedTables > 0 then
        message = message .. "Found unexpected tables. " .. table.concat(unexpectedTables, ", ") .. "\n"
    end

    -- table with keys set has to be iterated
    local function tableLength(input)
        local count = 0
        for _ in pairs(input) do
            count = count + 1
        end
        return count
    end

    if tableLength(expectedStrings) > 0 then
        message = message .. "Missing expected strings. "
        for key, value in pairs(expectedNumbers) do
            message = message .. string.format("%s=%s, ", key, value)
        end
        message = message .. "\n"
    end
    if #unexpectedStrings > 0 then
        message = message .. "Found unexpected strings. " .. table.concat(unexpectedStrings, ", ") .. "\n"
    end

    if tableLength(expectedNumbers) > 0 then
        message = message .. "Missing expected numbers. "
        for key, value in pairs(expectedNumbers) do
            message = message .. string.format("%s=%s, ", key, value)
        end
        message = message .. "\n"
    end
    if #unexpectedNumbers > 0 then
        message = message .. "Found unexpected numbers. " .. table.concat(unexpectedNumbers, ", ") .. "\n"
    end

    if #other > 0 then
        message = message .. "Found other entries. " .. table.concat(other, ", ") .. "\n"
    end

    -- Exercise functions
    local fontCount = getAvailableFontCount()
    if fontCount ~= 12 then
        message = message .. "Unepxected font count: " .. fontCount .. "\n"
    end

    if message:len() > 0 then
        logMessage(message)
        error(message)
    end

    ---------------
    -- copy from here to renderer
    ---------------
    _ENV = oldEnv
end

os.exit(lu.LuaUnit.run())
