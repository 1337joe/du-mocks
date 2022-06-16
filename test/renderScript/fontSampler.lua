-- Render a range of text in each font as well as some measurements.
-- persistent data, only clears when screen fully reloaded
persistent = persistent or {
    index = 1
}

local MAX_FONTS_LOADED = 8

local xRes, yRes = getResolution()
local layer = createLayer()

local fontCount = getAvailableFontCount()

local yStep = yRes / MAX_FONTS_LOADED
local xOff, yOff

local index, fontName, font
local size, ascender, descender
local CHARACTER_STRING = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
local width, height
for i = 1, MAX_FONTS_LOADED do
    index = persistent.index + i - 1
    fontName = getAvailableFontName(index)
    font = loadFont(fontName, yStep / 2)
    xOff, yOff = 20, yStep * i

    addText(layer, font, string.format("%d: %s", index, fontName), xOff, yOff - yStep / 3)

    setFontSize(font, yStep / 3)
    addText(layer, font, "012345ABCDEFGHIjklmnop", xOff, yOff)

    -- characterize font data
    size = 20
    setFontSize(font, size)

    ascender, descender = getFontMetrics(font)
    ascender = ascender / size
    descender = descender / size

    local data = {}
    for i = 1, #CHARACTER_STRING do
        width, height = getTextBounds(font, CHARACTER_STRING:sub(i, i))
        data[i] = {width / size, height / size}
    end
    width = {
        sum = 0
    }
    height = {
        sum = 0
    }
    for _, metrics in pairs(data) do
        if not width.min then
            width.min = metrics[1]
        else
            width.min = math.min(width.min, metrics[1])
        end
        if not height.min then
            height.min = metrics[2]
        else
            height.min = math.min(height.min, metrics[2])
        end

        if not width.max then
            width.max = metrics[1]
        else
            width.max = math.max(width.max, metrics[1])
        end
        if not height.max then
            height.max = metrics[2]
        else
            height.max = math.max(height.max, metrics[2])
        end

        width.sum = width.sum + metrics[1]
        height.sum = height.sum + metrics[2]
    end

    xOff = xRes / 2
    setFontSize(font, yStep / 3)
    addText(layer, font, "FM: " .. ascender .. "/" .. descender, xOff, yOff - yStep * 2 / 3)
    -- addText(layer, font, "W: " .. width.min .. "/" .. width.max .. "/" .. (width.sum / #data), xOff, yOff - yStep * 1 / 3)
    -- addText(layer, font, "H: " .. height.min .. "/" .. height.max .. "/" .. (height.sum / #data), xOff, yOff)
    addText(layer, font, "W: " .. (width.sum / #data), xOff, yOff - yStep * 1 / 3)
    addText(layer, font, "H: " .. (height.sum / #data), xOff, yOff)

    if index >= fontCount then
        break
    end
end

if getCursorDown() then
    persistent.index = persistent.index + 8
    if persistent.index > fontCount then
        persistent.index = 1
    end
end
