-- Draw basic elements to a layer then use layer operations to manipulate it
local font = loadFont("RobotoMono", 300)

local count = 0
local function drawLayer(layer, x, y, width, height)
    count = count + 1

    setNextFillColor(layer, 0, 0, 0, 1)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    setNextStrokeWidth(layer, height / 100)
    addBox(layer, x, y, width, height)

    setNextFillColor(layer, 1, 0, 0, 1)
    addBox(layer, x + width / 4, y + height / 2, width / 4, height * 3 / 8)

    setFontSize(font, math.min(height / 6, width / 6))
    setNextFillColor(layer, 0, 1, 0, 1)
    setNextTextAlign(layer, AlignH_Right, AlignV_Baseline)
    addText(layer, font, tostring(count), x + width / 4, y + height * 7 / 8)

    setFontSize(font, math.min(height / 2, width / 2))
    setNextFillColor(layer, 0, 1, 0, 1)
    addText(layer, font, "Up", x + width / 2, y + height * 7 / 8)

    setNextFillColor(layer, 1, 0, 0, 1)
    addTriangle(layer, x + width / 8, y + height / 2, x + width * 3 / 8, y + height / 10, x + width * 5 / 8,
        y + height / 2)
end

local xRes, yRes = getResolution()
local xC, yC = 0, 0

setBackgroundColor(0.5, 0.5, 0.5)

local xOff, yOff = 0, 0
local width, height = xRes / 4, yRes / 4
local layer

-- no transform / clipped
layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)

xOff = xOff + width
layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)
setLayerClipRect(layer, xOff + width / 8, yOff + height / 8, width * 3 / 4, height * 3 / 4)

-- translation / clipped
xOff = 0
yOff = 0
layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)
setLayerTranslation(layer, 0, height)

layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)
setLayerTranslation(layer, width, height)
setLayerClipRect(layer, xOff + width / 8, yOff + height / 8, width * 3 / 4, height * 3 / 4)

-- rotated (origin) / clipped
xOff = height * 2
yOff = -width
layer = createLayer()
drawLayer(layer, xOff, yOff, height, width)
setLayerRotation(layer, math.pi / 2)

yOff = yOff - width
layer = createLayer()
drawLayer(layer, xOff, yOff, height, width)
setLayerRotation(layer, math.pi / 2)
setLayerClipRect(layer, xOff + height / 8, yOff + width / 8, height * 3 / 4, width * 3 / 4)

-- rotated (local) / clipped
xOff = 0
yOff = height * 3
layer = createLayer()
drawLayer(layer, xOff - width, yOff - height, width, height)
setLayerOrigin(layer, xOff, yOff)
setLayerRotation(layer, -math.pi)

xOff = xOff + width
layer = createLayer()
drawLayer(layer, xOff - width, yOff - height, width, height)
setLayerOrigin(layer, xOff, yOff)
setLayerRotation(layer, -math.pi)
setLayerClipRect(layer, xOff - width * 7 / 8, yOff - height * 7 / 8, width * 3 / 4, height * 3 / 4)

-- scale (origin) / clipped
xOff = width * 2
yOff = 0
layer = createLayer()
drawLayer(layer, xOff * 2, yOff / 2, width * 2, height / 2)
setLayerScale(layer, 0.5, 2)

xOff = xOff + width
layer = createLayer()
drawLayer(layer, xOff * 2, yOff / 2, width * 2, height / 2)
setLayerScale(layer, 0.5, 2)
setLayerClipRect(layer, (xOff + width / 8) * 2, (yOff + height / 8) / 2, width * 3 / 2, height * 3 / 8)

-- scale (local) / clipped
xOff = width * 2
yOff = height
layer = createLayer()
drawLayer(layer, xOff, yOff, width * 2, height / 2)
setLayerOrigin(layer, xOff, yOff)
setLayerScale(layer, 0.5, 2)

xOff = xOff + width
layer = createLayer()
drawLayer(layer, xOff, yOff, width * 2, height / 2)
setLayerOrigin(layer, xOff, yOff)
setLayerScale(layer, 0.5, 2)
setLayerClipRect(layer, xOff + width / 4, yOff + height / 8 / 2, width * 3 / 2, height * 3 / 8)

-- scale-invert (local) / clipped
xOff = width * 2
yOff = height
layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)
setLayerScale(layer, 1, -1)
setLayerOrigin(layer, xOff, yOff + height)

xOff = xOff + width
layer = createLayer()
drawLayer(layer, xOff, yOff, width, height)
setLayerScale(layer, 1, -1)
setLayerOrigin(layer, xOff, yOff + height)
setLayerClipRect(layer, xOff + width / 8, yOff + height / 8, width * 3 / 4, height * 3 / 4)

-- scale + rotate (shared origin) + translate / clipped
xOff = 0
yOff = 0
layer = createLayer()
drawLayer(layer, xOff, yOff, width * 2, height * 2)
setLayerScale(layer, -0.5, -0.5)
setLayerRotation(layer, math.pi)
setLayerOrigin(layer, width, height)
setLayerTranslation(layer, width * 3 / 2, height * 5 / 2)

layer = createLayer()
drawLayer(layer, xOff, yOff, width * 2, height * 2)
setLayerScale(layer, -0.5, -0.5)
setLayerRotation(layer, math.pi)
setLayerOrigin(layer, width, height)
setLayerTranslation(layer, width * 5 / 2, height * 5 / 2)
setLayerClipRect(layer, xOff + width / 4, yOff + height / 4, width * 3 / 2, height * 3 / 2)
