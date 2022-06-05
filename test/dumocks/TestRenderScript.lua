#!/usr/bin/env lua
--- Tests on dumocks.ScreenRenderer.
-- @see dumocks.ScreenRenderer

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

-- set file locations
local INPUT_DIR = "test/renderScript/"
local OUTPUT_FILE = "test/results/TestRenderScript.html"

local lu = require("luaunit")
local sr = require("dumocks.RenderScript")

local SVG_WRAPPER_TEMPLATE = [[<li><p>%s<br>%s</p></li>]]

_G.TestScreenRenderer = {
    allSvg = {
[[
<!DOCTYPE html>
<html>
<head>
    <style>
        ul.gallery {
            list-style-type: none;
            padding: 0;
            margin: 5px;
            display: grid;
            grid-gap: 20px 5px;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
        }
        
        ul.gallery svg {
            width: 100%;
            height: 100%;
        }
    </style>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Mono&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Play&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Condensed&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono&display=swap" rel="stylesheet">
</head>
<body>
    <ul class="gallery">
]]
    }
}

function _G.TestScreenRenderer:tearDown()
    local closingTags = [[

    </ul>
</body>
</html>
]]
    -- save as file
    local outputHandle, errorMsg = io.open(OUTPUT_FILE, "w")
    if errorMsg then
        error(errorMsg)
    else
        io.output(outputHandle):write(table.concat(self.allSvg, "\n"))
        io.output(outputHandle):write(closingTags)
        outputHandle:close()
    end
end

function _G.TestScreenRenderer.testParameterValidation()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local oldEnv = _ENV
    local _ENV = closure

        ---------------
    -- copy from here to renderer
    ---------------

    local layer = createLayer()
    local font = loadFont("FiraMono", 50)

    local success, result

    success, result = pcall(getAvailableFontName, 0)
    assert(not success)
    assert(string.find(result, "out%-of%-bounds font index"), "Unexpected error message- " .. result)

    success, result = pcall(loadFont, "invalid", 5)
    assert(not success)
    assert(string.find(result, "unknown font <invalid>"), "Unexpected error message- " .. result)

    success, result = pcall(addText)
    assert(not success)
    assert(string.find(result, "expected number for parameter 5"), "Unexpected error message- " .. result)

    success, result = pcall(addText, nil, nil, nil, nil, 2.3)
    assert(not success)
    assert(string.find(result, "expected number for parameter 4"), "Unexpected error message- " .. result)

    success, result = pcall(addText, nil, nil, nil, 1.2, 2.3)
    assert(not success)
    assert(string.find(result, "expected string for parameter 3"), "Unexpected error message- " .. result)

    success, result = pcall(addText, nil, nil, "text", 1.2, 2.3)
    assert(not success)
    assert(string.find(result, "expected integer for parameter 2"), "Unexpected error message- " .. result)

    success, result = pcall(addText, nil, 2, "text", 1.2, 2.3)
    assert(not success)
    assert(string.find(result, "expected integer for parameter 1"), "Unexpected error message- " .. result)

    success, result = pcall(addText, 5, 6, "text", 1.2, 2.3)
    assert(not success)
    assert(string.find(result, "invalid layer handle"), "Unexpected error message- " .. result)

    success, result = pcall(addText, layer, 6, "text", 1.2, 2.3)
    assert(not success)
    assert(string.find(result, "invalid font handle"), "Unexpected error message- " .. result)

    success, result = pcall(addText, layer, font, "Success", 50, 50)
    assert(success)

    ---------------
    -- copy to here to renderer
    ---------------

    _ENV = oldEnv
end

function _G.TestScreenRenderer.testGetLocale()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()
    local expected, actual

    -- English
    expected = "en-US"
    screenRenderer.locale = expected
    actual = closure.getLocale()
    lu.assertEquals(actual, expected)

    -- French
    expected = "fr-FR"
    screenRenderer.locale = expected
    actual = closure.getLocale()
    lu.assertEquals(actual, expected)

    -- German
    expected = "de-DE"
    screenRenderer.locale = expected
    actual = closure.getLocale()
    lu.assertEquals(actual, expected)
end

function _G.TestScreenRenderer.testGetInput()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()
    local expected, actual

    -- default: empty string
    expected = ""
    actual = closure.getInput()
    lu.assertEquals(actual, expected)

    -- non-default
    expected = "test"
    screenRenderer.input = expected
    actual = closure.getInput()
    lu.assertEquals(actual, expected)
end

function _G.TestScreenRenderer.testGetSetFontSize()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()
    local expected, actual

    -- set by loading font
    expected = 10
    local font = closure.loadFont(closure.getAvailableFontName(1), expected)
    actual = closure.getFontSize(font)
    lu.assertEquals(actual, expected)

    -- set by calling set
    expected = 20
    closure.setFontSize(font, expected)
    actual = closure.getFontSize(font)
    lu.assertEquals(actual, expected)
end

function _G.TestScreenRenderer.testSetOutput()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local oldEnv = _ENV
    local _ENV = closure

    setOutput("test")

    _ENV = oldEnv

    lu.assertEquals(screenRenderer.output, "test")
end

function _G.TestScreenRenderer:testShapes()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "shapes.lua", "t", closure))

    script()
    self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Shapes", screenRenderer:mockGenerateSvg())
end

function _G.TestScreenRenderer:testStrokeWidthTextAlign()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "strokeAlign.lua", "t", closure))

    script()
    self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Stroke Width/Text Align", screenRenderer:mockGenerateSvg())
end

function _G.TestScreenRenderer:testFontSampler()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "fontSampler.lua", "t", closure))

    -- script advances screens on mouse click, cursorDown will advance every repaint
    screenRenderer.cursorDown = true

    local page = 1
    local index, previousIndex
    index = 0
    repeat
        previousIndex = index
        screenRenderer:mockReset()

        script()
        self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Font Sampler " .. page, screenRenderer:mockGenerateSvg())

        page = page + 1
        index = closure.persistent.index
    until index < previousIndex
end

function _G.TestScreenRenderer:testLayerOperations()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "layerOperations.lua", "t", closure))

    script()
    self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Layer Operations", screenRenderer:mockGenerateSvg())
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Screen or Sign, paste relevent bit directly into render script
--
-- Exercises: ??TODO??
function _G.TestScreenRenderer:testGameBehavior()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "verifyEnvironment.lua", "t", closure))

    script()
    self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Verify Environment", screenRenderer:mockGenerateSvg())

    lu.assertEquals(screenRenderer.output, "")
end

os.exit(lu.LuaUnit.run())
