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

_G.TestScreenRenderer = {}

function _G.TestScreenRenderer:setUp()
    self.allSvg = {}
    self.allSvg[#self.allSvg + 1] = [[
<html>
<head>
    <style>
        ul.gallery {
            list-style-type: none;
            padding: 0;
            margin: 5px;
            display: grid;
            grid-gap: 20px 5px;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        }
        
        ul.gallery svg {
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
    <ul class="gallery">
]]
end

function _G.TestScreenRenderer:tearDown()
    self.allSvg[#self.allSvg + 1] = [[
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
        outputHandle:close()
    end
end

function _G.TestScreenRenderer:testShapes()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "shapes.lua", "t", closure))
    script()

    self.allSvg[#self.allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, "Shapes", screenRenderer:mockGenerateSvg())
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Screen or Sign, paste relevent bit directly into render script
--
-- Exercises: ??TODO??
function _G.TestScreenRenderer.testGameBehavior()
    local screenRenderer = sr:new()
    local closure = screenRenderer:mockGetEnvironment()

    local script = assert(loadfile(INPUT_DIR .. "verifyEnvironment.lua", "t", closure))
    script()
end

os.exit(lu.LuaUnit.run())
