-- Render a sampling of line stroke widths and text alignments.
-- 3 columns:
--   - line with custom stroke width/line with default stroke width
--   - AlignH values
--   - AlignV values

local xRes, yRes = getResolution()
local layer = createLayer()

-- Compare default stroke width to various sizes
local values = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 50}

local spacing = yRes / (#values + 1)
local xStart, xEnd = spacing, xRes / 2 - spacing
local xJoin = (xStart + xEnd) / 2

addLine(layer, 0, 0, xRes / 2, 0)
addLine(layer, 0, yRes, xRes / 2, yRes)

for k,v in pairs(values) do
    setNextStrokeWidth(layer, v)
    addLine(layer, xStart, spacing * k, xJoin, spacing * k)
    addLine(layer, xJoin, spacing * k, xEnd, spacing * k)
end

-- Test various font alignment values
setDefaultStrokeColor(layer, Shape_Line, 0.3, 0.3, 0.3, 1)
local font = loadFont("RobotoMono", 30)

local x, y, yStep

-- AlignH
yStep = yRes / 5
x = xRes * 5 / 8
y = yStep

addLine(layer, x, 0, x, yRes)

addLine(layer, xRes / 2, y, xRes * 3 / 4, y)
addText(layer, font, "Default", x, y)
y = y + yStep

addLine(layer, xRes / 2, y, xRes * 3 / 4, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Baseline)
addText(layer, font, "Left", x, y)
y = y + yStep

addLine(layer, xRes / 2, y, xRes * 3 / 4, y)
setNextTextAlign(layer, AlignH_Center, AlignV_Baseline)
addText(layer, font, "Center", x, y)
y = y + yStep

addLine(layer, xRes / 2, y, xRes * 3 / 4, y)
setNextTextAlign(layer, AlignH_Right, AlignV_Baseline)
addText(layer, font, "Right", x, y)
y = y + yStep

-- AlignV
yStep = yRes / 8
x = xRes * 13 / 16
y = yStep

addLine(layer, x, 0, x, yRes)

addLine(layer, xRes * 3 / 4, y, xRes, y)
addText(layer, font, "Default", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Ascender)
addText(layer, font, "Ascender", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Top)
addText(layer, font, "Top", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
addText(layer, font, "Middle", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Baseline)
addText(layer, font, "Baseline", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
addText(layer, font, "Bottom", x, y)
y = y + yStep

addLine(layer, xRes * 3 / 4, y, xRes, y)
setNextTextAlign(layer, AlignH_Left, AlignV_Descender)
addText(layer, font, "Descender", x, y)
y = y + yStep
