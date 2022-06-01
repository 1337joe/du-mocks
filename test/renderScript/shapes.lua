-- Draws a sample of each shape/type
-- 4 rows:
--   - shape types with default values set
--   - shape types with all values set
--   - shapes of a single type overlapping (configured with defaults)
--   - shape types overlapping each other

local xRes, yRes = getResolution()

local ROW_COUNT = 4
local SHAPE_COUNT = 9
local COLOR_SEQUENCE = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
    {0, 1, 1},
    {1, 0, 1},
    {1, 1, 0},
    {0.5, 0.5, 0.5},
}

local size = math.min(yRes / ROW_COUNT / 2, xRes / SHAPE_COUNT / 2)
local layer = createLayer()
local image = loadImage("resources_generated/env/voxel/ore/aluminium-ore/icons/env_aluminium-ore_icon.png")
local font = loadFont("RobotoMono", size * 1.4)

local function drawImage(x, y)
    addImage(layer, image, x, y, size, size)
end
local function drawBezier(x, y)
    addBezier(layer, x, y + size, x + size / 2, y, x + size, y + size)
end
local function drawBox(x, y)
    addBox(layer, x, y, size, size)
end
local function drawBoxRounded(x, y)
    addBoxRounded(layer, x, y, size, size, size / 4)
end
local function drawCircle(x, y)
    addCircle(layer, x + size / 2, y + size / 2, size / 2)
end
local function drawLine(x, y)
    addLine(layer, x, y, x + size, y + size)
end
local function drawTriangle(x, y)
    addTriangle(layer, x, y, x + size, y, x, y + size)
end
local function drawQuad(x, y)
    addQuad(layer, x, y, x + size * 7 / 8, y + size / 8, x + size, y + size, x + size / 8, y + size * 7 / 8)
end
local function drawText(x, y)
    addText(layer, font, "E", x, y + size)
end

local function addAlpha(index, alpha)
    local color = {}
    for k,v in pairs(COLOR_SEQUENCE[index]) do
        color[k] = v
    end
    color[4] = alpha
    return color
end

local colorIndex, rotation
local function setAllNext(alpha)
    if not alpha then
        alpha = 1.0
    end

    setNextFillColor(layer, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setNextRotation(layer, rotation)

    setNextShadow(layer, size / 4, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setNextStrokeColor(layer, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setNextStrokeWidth(layer, size / 8)
end
local function setAllDefault(shapeType)
    local alpha = 1.0

    setDefaultFillColor(layer, shapeType, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setDefaultRotation(layer, shapeType, rotation)

    setDefaultShadow(layer, shapeType, size / 4, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setDefaultStrokeColor(layer, shapeType, table.unpack(addAlpha(colorIndex, alpha)))
    colorIndex = colorIndex % #COLOR_SEQUENCE + 1

    setDefaultStrokeWidth(layer, shapeType, size / 8)
end

local xStep, xOff, yOff

-- ----------------------- --
-- Sample Shapes - Default --
-- ----------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT / 2 - size / 2

drawImage(xOff + xStep * 0, yOff)
drawBezier(xOff + xStep * 1, yOff)
drawBox(xOff + xStep * 2, yOff)
drawBoxRounded(xOff + xStep * 3, yOff)
drawCircle(xOff + xStep * 4, yOff)
drawLine(xOff + xStep * 5, yOff)
drawTriangle(xOff + xStep * 6, yOff)
drawQuad(xOff + xStep * 7, yOff)
drawText(xOff + xStep * 8, yOff)


-- ---------------------- --
-- Sample Shapes - Custom --
-- ---------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT + yRes / ROW_COUNT / 2 - size / 2

colorIndex = 1
rotation = math.pi / 4

setAllNext()
drawImage(xOff + xStep * 0, yOff)

setAllNext()
drawBezier(xOff + xStep * 1, yOff)

setAllNext()
drawBox(xOff + xStep * 2, yOff)

setAllNext()
drawBoxRounded(xOff + xStep * 3, yOff)

setAllNext()
drawCircle(xOff + xStep * 4, yOff)

setAllNext()
drawLine(xOff + xStep * 5, yOff)

setAllNext()
drawTriangle(xOff + xStep * 6, yOff)

setAllNext()
drawQuad(xOff + xStep * 7, yOff)

setAllNext()
drawText(xOff + xStep * 8, yOff)


-- ----------------------- --
-- Single Type Overlapping --
-- ----------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT * 2 + yRes / ROW_COUNT / 2 - size / 2

colorIndex = 2
rotation = math.pi / 8
setAllDefault(Shape_Image)
setAllDefault(Shape_Bezier)
setAllDefault(Shape_Box)
setAllDefault(Shape_BoxRounded)
setAllDefault(Shape_Circle)
setAllDefault(Shape_Line)
setAllDefault(Shape_Polygon)
setAllDefault(Shape_Text)

colorIndex = 3
rotation = -math.pi / 8

drawImage(xOff - size / 4, yOff - size / 4)
drawImage(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawImage(xOff, yOff)
xOff = xOff + xStep

drawBezier(xOff - size / 4, yOff - size / 4)
drawBezier(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawBezier(xOff, yOff)
xOff = xOff + xStep

drawBox(xOff - size / 4, yOff - size / 4)
drawBox(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawBox(xOff, yOff)
xOff = xOff + xStep

drawBoxRounded(xOff - size / 4, yOff - size / 4)
drawBoxRounded(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawBoxRounded(xOff, yOff)
xOff = xOff + xStep

drawCircle(xOff - size / 4, yOff - size / 4)
drawCircle(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawCircle(xOff, yOff)
xOff = xOff + xStep

drawLine(xOff - size / 4, yOff - size / 4)
drawLine(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawLine(xOff, yOff)
xOff = xOff + xStep

drawTriangle(xOff - size / 4, yOff - size / 4)
drawTriangle(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawTriangle(xOff, yOff)
xOff = xOff + xStep

drawQuad(xOff - size / 4, yOff - size / 4)
drawQuad(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawQuad(xOff, yOff)
xOff = xOff + xStep

drawText(xOff - size / 4, yOff - size / 4)
drawText(xOff + size / 4, yOff + size / 4)
setAllNext(0.8)
drawText(xOff, yOff)
xOff = xOff + xStep


-- ---------------------- --
-- Shape Type Overlapping --
-- ---------------------- --

xStep = xRes / SHAPE_COUNT
xOff = xRes / SHAPE_COUNT - (xStep + size) / 2
yOff = yRes / ROW_COUNT * 3 + yRes / ROW_COUNT / 2 - size / 2

-- draw in order of overlap

drawImage(xOff, yOff)
xOff = xOff + size / 2

drawBezier(xOff, yOff)
xOff = xOff + size / 2

drawBox(xOff, yOff)
xOff = xOff + size / 2

drawBoxRounded(xOff, yOff)
xOff = xOff + size / 2

drawCircle(xOff, yOff)
xOff = xOff + size / 2

drawLine(xOff, yOff)
xOff = xOff + size / 2

drawTriangle(xOff, yOff)
xOff = xOff + size / 2

drawQuad(xOff, yOff)
xOff = xOff + size / 2

drawText(xOff, yOff)
xOff = xOff + size / 2

-- reverse draw order
xOff = xOff + size

drawText(xOff, yOff)
xOff = xOff + size / 2

drawQuad(xOff, yOff)
xOff = xOff + size / 2

drawTriangle(xOff, yOff)
xOff = xOff + size / 2

drawLine(xOff, yOff)
xOff = xOff + size / 2

drawCircle(xOff, yOff)
xOff = xOff + size / 2

drawBoxRounded(xOff, yOff)
xOff = xOff + size / 2

drawBox(xOff, yOff)
xOff = xOff + size / 2

drawBezier(xOff, yOff)
xOff = xOff + size / 2

drawImage(xOff, yOff)
xOff = xOff + size / 2
