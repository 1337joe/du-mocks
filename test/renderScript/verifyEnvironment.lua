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

-- Exercise functions
local fontCount = getAvailableFontCount()
if fontCount ~= 12 then
    message[#message + 1] = "Unepxected font count: " .. fontCount
    errorLines[#message] = true
end

local lineSize = 20
local layer = createLayer()
local font = loadFont("RobotoMono", lineSize * .75)

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

-- Report result
if #error > 0 then
    local outputString = table.concat(error, "\n")
    logMessage(outputString)
    setOutput(outputString)
end
