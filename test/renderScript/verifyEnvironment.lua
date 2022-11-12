local expectedFunctions = {"getCursor", "createLayer", "getResolution", "addCircle", "setNextFillColor",
                           "setNextStrokeColor", "getDeltaTime", "addImage", "loadImage", "setNextRotation", "loadFont",
                           "setNextRotationDegrees", "addTriangle", "requestAnimationFrame", "addQuad",
                           "setNextStrokeWidth", "addText", "getRenderCostMax", "addLine", "getRenderCost", "addBox",
                           "getInput", "setOutput", "setDefaultRotation", "isImageLoaded", "setDefaultShadow",
                           "setDefaultStrokeColor", "setNextTextAlign", "setNextShadow", "isFontLoaded",
                           "setDefaultStrokeWidth", "addBoxRounded", "setBackgroundColor", "getCursorPressed",
                           "getCursorReleased", "getCursorDown", "setDefaultFillColor", "getFontMetrics",
                           "getTextBounds", "logMessage", "getTime", "getAvailableFontName", "getAvailableFontCount",
                           "setLayerClipRect", "setFontSize", "getImageSize", "addBezier", "addImageSub",
                           "setDefaultTextAlign", "getLocale", "setLayerRotation", "setLayerScale",
                           "setLayerTranslation", "setLayerOrigin", "getFontSize", "rawget", "rawset", "rawequal",
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
    _RSVERSION = 2,

    Shape_Bezier = 0,
    Shape_Box = 1,
    Shape_BoxRounded = 2,
    Shape_Circle = 3,
    Shape_Image = 4,
    Shape_Line = 5,
    Shape_Polygon = 6,
    Shape_Text = 7,

    AlignH_Left = 0,
    AlignH_Center = 1,
    AlignH_Right = 2,

    AlignV_Ascender = 0,
    AlignV_Top = 1,
    AlignV_Middle = 2,
    AlignV_Baseline = 3,
    AlignV_Bottom = 4,
    AlignV_Descender = 5
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
        table.insert(unexpectedStrings, string.format("%s=\"%s\" (expected \"%s\")", key, value, expected))
    elseif type(value) == "number" then
        local expected = expectedNumbers[key]
        if expected then
            expectedNumbers[key] = nil
            if expected == value then
                goto continueOuter
            end
        end
        table.insert(unexpectedNumbers, string.format("%s=%s (expected %s)", key, value, expected))
    else
        table.insert(other, string.format("%s(%s)", key, type(value)))
    end

    ::continueOuter::
end

local message = {}
local errorLines = {}

if #expectedFunctions == 0 and #unexpectedFunctions == 0 then
    message[#message + 1] = "Expected functions: Found"
else
    if #expectedFunctions > 0 then
        message[#message + 1] = "Missing functions: " .. table.concat(expectedFunctions, ", ")
        errorLines[#message] = true
    end
    if #unexpectedFunctions > 0 then
        message[#message + 1] = "Unexpected functions: " .. table.concat(unexpectedFunctions, ", ")
        errorLines[#message] = true
    end
end

if #expectedTables == 0 and #unexpectedTables == 0 then
    message[#message + 1] = "Expected tables: Found"
else
    if #expectedTables > 0 then
        message[#message + 1] = "Missing tables: " .. table.concat(expectedTables, ", ")
        errorLines[#message] = true
    end
    if #unexpectedTables > 0 then
        message[#message + 1] = "Unexpected tables: " .. table.concat(unexpectedTables, ", ")
        errorLines[#message] = true
    end
end

-- table with keys set has to be iterated
local function tableLength(input)
    local count = 0
    for _ in pairs(input) do
        count = count + 1
    end
    return count
end

if tableLength(expectedStrings) == 0 and #unexpectedStrings == 0 then
    message[#message + 1] = "Expected strings: Found"
else
    if tableLength(expectedStrings) > 0 then
        local strings = {}
        for key, value in pairs(expectedStrings) do
            strings[#strings + 1] = string.format("%s=%s, ", key, value)
        end
        message[#message + 1] = "Missing strings: " .. table.concat(strings, ", ")
        errorLines[#message] = true
    end
    if #unexpectedStrings > 0 then
        message[#message + 1] = "Unexpected strings: " .. table.concat(unexpectedStrings, ", ")
        errorLines[#message] = true
    end
end

if tableLength(expectedNumbers) == 0 and #unexpectedNumbers == 0 then
    message[#message + 1] = "Expected numbers: Found"
else
    if tableLength(expectedNumbers) > 0 then
        local numbers = {}
        for key, value in pairs(expectedNumbers) do
            numbers[#numbers + 1] = string.format("%s=%s, ", key, value)
        end
        message[#message + 1] = "Missing numbers: " .. table.concat(numbers, ", ")
        errorLines[#message] = true
    end
    if #unexpectedNumbers > 0 then
        message[#message + 1] = "Unexpected numbers: " .. table.concat(unexpectedNumbers, ", ")
        errorLines[#message] = true
    end
end

if #other > 0 then
    message[#message + 1] = "Found other entries: " .. table.concat(other, ", ")
    errorLines[#message] = true
end

local function verifyCost(cost, funcName, func, ...)
    local before = getRenderCost()
    local result1, result2 = func(...)
    local after = getRenderCost()
    if after - before ~= cost then
        message[#message + 1] = string.format("Expected %s to cost %d but was %d", funcName, cost, after - before)
        errorLines[#message] = true
    end
    return result1, result2
end

-- Exercise functions
local costMax = getRenderCostMax()
if costMax ~= 4000000 then
    message[#message + 1] = "Unepxected render cost max: " .. costMax
    errorLines[#message] = true
else
    message[#message + 1] = "Expected render cost max: " .. costMax
end

local fontCount = getAvailableFontCount()
if fontCount ~= 12 then
    message[#message + 1] = "Unepxected font count: " .. fontCount
    errorLines[#message] = true
else
    message[#message + 1] = "Expected font count: " .. fontCount
end

local lineSize = 20
local layer = createLayer()
local font = loadFont("RobotoMono", lineSize * .75)

local MAX_FONTS = 8
local testFont = verifyCost(0, "loadFont", loadFont, "Play", 20)
for fontCount = 3, MAX_FONTS do
    loadFont(getAvailableFontName(fontCount), 10)
end
if pcall(loadFont, getAvailableFontName(1), 10) then
    message[#message + 1] = "Loaded more than MAX_FONTS: " .. MAX_FONTS + 1
    errorLines[#message] = true
else
    message[#message + 1] = "Expected max fonts: " .. MAX_FONTS
end

verifyCost(0, "getRenderCost", getRenderCost)
verifyCost(0, "getCursor", getCursor)
verifyCost(0, "getCursorDown", getCursorDown)
verifyCost(0, "getCursorPressed", getCursorPressed)
verifyCost(0, "getCursorReleased", getCursorReleased)
verifyCost(0, "getDeltaTime", getDeltaTime)
verifyCost(0, "getTime", getTime)
verifyCost(0, "getLocale", getLocale)
verifyCost(0, "getRenderCostMax", getRenderCostMax)
local rx, ry = verifyCost(0, "getResolution", getResolution)
verifyCost(0, "logMessage", logMessage, "test message")
local image = verifyCost(0, "loadImage", loadImage, "resources_generated/env/voxel/ore/aluminium-ore/icons/env_aluminium-ore_icon.png")
verifyCost(0, "isImageLoaded", isImageLoaded, image)
verifyCost(0, "getImageSize", getImageSize, image)
verifyCost(0, "getAvailableFontCount", getAvailableFontCount)
verifyCost(0, "getAvailableFontName", getAvailableFontName, 1)
verifyCost(0, "getTextBounds .", getTextBounds, testFont, ".")
verifyCost(0, "getTextBounds many words", getTextBounds, testFont, "many words")
verifyCost(0, "getFontMetrics", getFontMetrics, testFont)
verifyCost(0, "getFontSize", getFontSize, testFont)
verifyCost(0, "setFontSize", setFontSize, testFont, 30)
verifyCost(0, "setBackgroundColor", setBackgroundColor, 0, 0, .2)
local testLayer = verifyCost(75000, "createLayer", createLayer)
verifyCost(100, "addBox 1", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(200, "addBox 2", addBox, testLayer, rx / 2, ry / 2, 10, 20)
verifyCost(200, "addBox off-screen", addBox, testLayer, rx / 2, -10, 10, 20)
verifyCost(16, "addBox pixel", addBox, testLayer, rx / 2, ry / 2, 1, 1)
verifyCost(16, "addBox zero height", addBox, testLayer, rx / 2, ry / 2, 100, 0)
verifyCost(111, "addText . 30", addText, testLayer, testFont, ".", rx / 2, ry / 2)
verifyCost(815, "addText % 30", addText, testLayer, testFont, "%", rx / 2, ry / 2)
verifyCost(2211, "addText %%% 30", addText, testLayer, testFont, "%%%", rx / 2, ry / 2)
verifyCost(0, "setFontSize", setFontSize, testFont, 20)
verifyCost(362, "addText % 20", addText, testLayer, testFont, "%", rx / 2, ry / 2)
verifyCost(0, "setNextFillColor", setNextFillColor, testLayer, 1, 0, 0, 1)
verifyCost(100, "addBox colored", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextFillColor alpha", setNextFillColor, testLayer, 1, 1, 0, 0.5)
verifyCost(100, "addBox colored alpha", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextRotation", setNextRotation, testLayer, 1)
verifyCost(100, "addBox rotated 1", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextRotationDegrees", setNextRotationDegrees, testLayer, 45)
verifyCost(100, "addBox rotated 2", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextShadow", setNextShadow, testLayer, 5, 0, 1, 1, 1)
verifyCost(400, "addBox shadow 1", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextShadow", setNextShadow, testLayer, 1, 0, 1, 1, 1)
verifyCost(144, "addBox shadow 2", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextShadow", setNextShadow, testLayer, 1, 0, 1, 1, 1)
verifyCost(484, "addBox shadow 3", addBox, testLayer, rx / 2, ry / 2, 20, 20)
verifyCost(0, "setNextStrokeColor", setNextStrokeColor, testLayer, 0, 1, 1, 1)
verifyCost(100, "addBox stroke color", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextStrokeWidth", setNextStrokeWidth, testLayer, 1)
verifyCost(144, "addBox stroke 1", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextStrokeWidth", setNextStrokeWidth, testLayer, 1)
verifyCost(442, "addText % stroke", addText, testLayer, testFont, "%", rx / 2, ry / 2)
verifyCost(0, "setNextStrokeWidth", setNextStrokeWidth, testLayer, 5)
verifyCost(400, "addBox stroke 2", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextStrokeWidth", setNextStrokeWidth, testLayer, 5)
verifyCost(0, "setNextShadow", setNextShadow, testLayer, 5, 0, 1, 1, 1)
verifyCost(900, "addBox stroke shadow", addBox, testLayer, rx / 2, ry / 2, 10, 10)
verifyCost(0, "setNextStrokeWidth", setNextStrokeWidth, testLayer, 5)
verifyCost(0, "setNextShadow", setNextShadow, testLayer, 5, 0, 1, 1, 1)
verifyCost(1525, "addText % stroke shadow", addText, testLayer, testFont, "%", rx / 2, ry / 2)
message[#message + 1] = "Final cost: " .. getRenderCost()

-- Report result
local error = {}
for line, text in pairs(message) do
    if errorLines[line] then
        error[#error + 1] = text
        setNextFillColor(layer, 1, 0, 0, 1)
    else
        setNextFillColor(layer, 0, 1, 0, 1)
    end
    addText(layer, font, text, 10, lineSize * line)
end

if #error > 0 then
    local outputString = table.concat(error, "\n")
    logMessage(outputString)
    setOutput(outputString)
end

