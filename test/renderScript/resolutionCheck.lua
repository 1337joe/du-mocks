-- Display the provided input string and the screen resolution
local xRes, yRes = getResolution()
local input = getInput() or "<undefined>"

local layer = createLayer()
local font = loadFont("RobotoMono", 30)

addText(layer, font, input, 0, yRes / 2)
addText(layer, font, string.format("%d x %d", xRes, yRes), 0, yRes)

setDefaultStrokeColor(layer, Shape_Line, 1, 0, 0, 1)
setDefaultStrokeWidth(layer, Shape_Line, 10)
addLine(layer, 0, 0, xRes, 0)
addLine(layer, xRes, 0, xRes, yRes)
addLine(layer, xRes, yRes, 0, yRes)
addLine(layer, 0, yRes, 0, 0)
