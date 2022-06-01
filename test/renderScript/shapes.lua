-- Draws a sample of each shape/type
-- 4 rows:
--   - shape types with default values set
--   - shape types with all values set
--   - shape types overlapping each other
--   - shapes of a single type overlapping

local xRes, yRes = getResolution()

local ROW_COUNT = 4
local SHAPE_COUNT = 9
local COLOR_SEQUENCE = {
    {1, 0, 0, 1},
    {0, 1, 0, 1},
    {0, 0, 1, 1},
    {0, 1, 1, 1},
    {1, 0, 1, 1},
    {1, 1, 0, 1},
    {0.5, 0.5, 0.5, 1},
}

local size = math.min(yRes / ROW_COUNT / 2, xRes / SHAPE_COUNT / 2)

local layer = createLayer()

local xStep, xOff, yOff, colorIndex
local image = loadImage("resources_generated/env/voxel/ore/aluminium-ore/icons/env_aluminium-ore_icon.png")
local font = loadFont("RobotoMono", size * 1.4)

-- ----------------------- --
-- Sample Shapes - Default --
-- ----------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT / 2 - size / 2

addImage(layer, image, xOff, yOff, size, size)
xOff = xOff + xStep

addBezier(layer, xOff, yOff + size, xOff + size / 2, yOff, xOff + size, yOff + size)
xOff = xOff + xStep

addBox(layer, xOff, yOff, size, size)
xOff = xOff + xStep

addBoxRounded(layer, xOff, yOff, size, size, size / 4)
xOff = xOff + xStep

addCircle(layer, xOff + size / 2, yOff + size / 2, size / 2)
xOff = xOff + xStep

addLine(layer, xOff, yOff, xOff + size, yOff + size)
xOff = xOff + xStep

addTriangle(layer, xOff, yOff, xOff + size, yOff, xOff, yOff + size)
xOff = xOff + xStep

addQuad(layer, xOff, yOff, xOff + size, yOff, xOff + size, yOff + size, xOff, yOff + size)
xOff = xOff + xStep

addText(layer, font, "E", xOff, yOff + size)
xOff = xOff + xStep

-- ---------------------- --
-- Sample Shapes - Custom --
-- ---------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT + yRes / ROW_COUNT / 2 - size / 2
colorIndex = 1
local rotation = math.pi / 4

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextRotation(layer, rotation)
addImage(layer, image, xOff, yOff, size, size)
xOff = xOff + xStep

setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addBezier(layer, xOff, yOff + size, xOff + size / 2, yOff, xOff + size, yOff + size)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextRotation(layer, rotation)
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addBox(layer, xOff, yOff, size, size)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextRotation(layer, rotation)
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addBoxRounded(layer, xOff, yOff, size, size, size / 4)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addCircle(layer, xOff + size / 2, yOff + size / 2, size / 2)
xOff = xOff + xStep

setNextRotation(layer, rotation)
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addLine(layer, xOff, yOff, xOff + size, yOff + size)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextRotation(layer, rotation)
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addTriangle(layer, xOff, yOff, xOff + size, yOff, xOff, yOff + size)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextRotation(layer, rotation)
setNextShadow(layer, size / 4, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
setNextStrokeWidth(layer, size / 8)
addQuad(layer, xOff, yOff, xOff + size, yOff, xOff + size, yOff + size, xOff, yOff + size)
xOff = xOff + xStep

setNextFillColor(layer, table.unpack(COLOR_SEQUENCE[colorIndex]))
colorIndex = colorIndex % #COLOR_SEQUENCE + 1
addText(layer, font, "E", xOff, yOff + size)
xOff = xOff + xStep

-- ---------------------- --
-- Shape Type Overlapping --
-- ---------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT * 2 + yRes / ROW_COUNT / 2 - size / 2

-- draw in order of overlap

addImage(layer, image, xOff, yOff, size, size)
xOff = xOff + size / 2

setNextStrokeColor(layer, 1, 1, 1, 1)
setNextStrokeWidth(layer, size / 10)
addBezier(layer, xOff, yOff + size, xOff + size / 2, yOff, xOff + size, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 1, 0, 0, 1)
addBox(layer, xOff, yOff, size, size)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 1, 0, 1)
addBoxRounded(layer, xOff, yOff, size, size, size / 4)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 0, 1, 1)
addCircle(layer, xOff + size / 2, yOff + size / 2, size / 2)
xOff = xOff + size / 2

setNextStrokeColor(layer, 1, 1, 0, 1)
setNextStrokeWidth(layer, size / 10)
addLine(layer, xOff, yOff, xOff + size, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 1, 1, 1)
addTriangle(layer, xOff, yOff, xOff + size, yOff, xOff, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 1, 0, 1, 1)
addQuad(layer, xOff, yOff, xOff + size, yOff, xOff + size, yOff + size, xOff, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 1, 1, 1, 1)
addText(layer, font, "E", xOff, yOff + size)
xOff = xOff + size / 2

-- reverse draw order
xOff = xOff + size

setNextFillColor(layer, 1, 1, 1, 1)
addText(layer, font, "E", xOff, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 1, 0, 1, 1)
addQuad(layer, xOff, yOff, xOff + size, yOff, xOff + size, yOff + size, xOff, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 1, 1, 1)
addTriangle(layer, xOff, yOff, xOff + size, yOff, xOff, yOff + size)
xOff = xOff + size / 2

setNextStrokeColor(layer, 1, 1, 0, 1)
setNextStrokeWidth(layer, size / 10)
addLine(layer, xOff, yOff, xOff + size, yOff + size)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 0, 1, 1)
addCircle(layer, xOff + size / 2, yOff + size / 2, size / 2)
xOff = xOff + size / 2

setNextFillColor(layer, 0, 1, 0, 1)
addBoxRounded(layer, xOff, yOff, size, size, size / 4)
xOff = xOff + size / 2

setNextFillColor(layer, 1, 0, 0, 1)
addBox(layer, xOff, yOff, size, size)
xOff = xOff + size / 2

setNextStrokeColor(layer, 1, 1, 1, 1)
setNextStrokeWidth(layer, size / 10)
addBezier(layer, xOff, yOff + size, xOff + size / 2, yOff, xOff + size, yOff + size)
xOff = xOff + size / 2

addImage(layer, image, xOff, yOff, size, size)
xOff = xOff + size / 2

-- ----------------------- --
-- Single Type Overlapping --
-- ----------------------- --

xOff = size
yOff = yOff + size * 2

setNextFillColor(layer, 1, 0, 0, 1)
addBox(layer, xOff, yOff, size, size)

setNextFillColor(layer, 0, 1, 0, 1)
addBox(layer, xOff - size * 3 / 4, yOff, size, size)

setNextFillColor(layer, 0, 0, 1, 1)
addBox(layer, xOff, yOff - size * 3 / 4, size, size)

setNextFillColor(layer, 1, 1, 0, 1)
addBox(layer, xOff + size * 3 / 4, yOff, size, size)

setNextFillColor(layer, 1, 0, 1, 0.8)
addBox(layer, xOff, yOff + size * 3 / 4, size, size)

