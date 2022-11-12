--- RenderScript is a new technology for creating screen unit contents using Lua (also referred to as "Lua Screen
-- Units"), rather than HTML/CSS. In general, this technology causes less performance drops in the game, while
-- simultaneously allowing significantly more complex animaged and interactive screens.
--
-- Render scripts are Lua scripts residing inside screen units that provide rendering instructions for the screen. To
-- use RenderScript, simply switch the screen mode from 'HTML' to 'Lua' in the screen unit content editor interface,
-- then start writing a render script! Render scripts work by building up layers of geometric shapes, images, and text,
-- that are then rendered sequentially to the screen.
--
-- The short example script below demonstrates drawing a box and some text on the screen.
--
-- <blockquote><code>
-- local layer = createLayer() -- create a new layer<br>
-- local rx, ry = getResolution() -- get the resolution of the screen<br>
-- local font = loadFont("Play", 20) -- load the "Play" font at size 20pain
--
-- setNextFillColor(layer, 1, 0, 0, 1) -- set the fill color (red, green, blue, alpha) for the next shape<br>
-- addBox(layer, rx/4, ry/4, rx/2, ry/2) -- add a box in the center of the screen<br>
-- addText(layer, font, "Hello World!", rx/3, ry/2) -- add a text string using font
-- </code></blockquote>
--
-- <h2>Animation</h2>
--
-- It is entirely possible to create animated screens with RenderScript; in fact, the technology really shines for
-- complex animations, where the performance of HTML/CSS is generally low.
--
-- Animations are made possible by using the @{requestAnimationFrame} function to re-run in some number of frames, then
-- changing the positioning of geometry within the layers, based on some variable such as time. Effectively, you will
-- simply draw one frame of your animation at a time, but since RenderScript is fast enough to execute at 60 frames per
-- second, the result will look smooth.
--
-- The minimal example script below demonstrates using the @{getTime} function to animate the location of a circle on
-- the screen:
--
-- <blockquote><code>
-- local layer = createLayer()<br>
-- local rx, ry = getResolution()<br>
-- local t = getTime()<br>
-- local r = math.min(rx/4, ry/4)<br>
-- local x = rx/2 + r * math.cos(t)<br>
-- local y = ry/2 + r * math.sin(t)<br>
--
-- addCircle(layer, x, y, 16)<br>
-- requestAnimationFrame(1)
-- </code></blockquote>
--
-- <h2>Coordinate Space</h2>
--
-- All render script coordinates are in screen pixels, ranging from <code>(0, 0)</code> at the top-left of the screen,
-- to <code>(width, height)</code> at the bottom-right. The width and height of the screen in pixels can be retrieved
-- by calling @{getResolution}.
--
-- For maximal robustness, scripts should be written so as to adapt to the resolution, as screens with different sizes
-- or aspect ratios will use different display resolutions.
--
-- <h2>Render Cost</h2>
--
-- Since render script is intended to solve screen unit performance problems, we impose relatively harsh restrictions
-- on content compared to HTML. This does not mean you won't be able to create amazing, detailed, high-framerate screen
-- contents; it just means that you'll need to be aware of the budgeting mechanism.
--
-- Any render script call that draws a shape (box, circle, line, text...) adds to a cost metric that consumes some of
-- the screen's total rendering budget. Although the exact cost metric is subject to change, roughly-speaking, the
-- render cost incurred by any shape is proportional to the screen-space area of the shape, plus a constant factor.
-- This means that a box of dimension 16 x 16 consumes roughly four times as much render cost as a box of 8 x 8. This
-- is fairly intuitive when you realize that the number of pixels filled by the larger box is four times that of the
-- smaller box.
--
-- For most render scripts, it is unlikely that the maximum cost will ever be exceeded, so most users probably don't
-- need to worry too much about this mechanism. However, drawing lots of large text or lots of large, overlapping
-- images may cause you to exceed the budget.
--
-- To learn more about your script's use of this budget, use the built-in API functions @{getRenderCost} and
-- @{getRenderCostMax}. @{getRenderCost} can be called at any point during a render script to see how much all the
-- contents added so far cost.
--
-- Below is an example of how to add a simple render cost progile to your screen so that you can see cost information
-- in real-time:
--
-- <blockquote><code>
-- local rx, ry = getResolution()<br>
-- local layer = createLayer()<br>
-- local font = loadFont('FiraMono-Bold', 16)<br>
-- local text = string.format('render cost: %d / %d', getRenderCost(), getRenderCostMax())<br>
-- setNextFillColor(layer, 1, 1, 1, 1)<br>
-- setNextTextAlign(layer, AlignH_Left, AlignV_Descender)<br>
-- addText(layer, font, text, 16, ry - 8)
-- </code></blockquote>
--
-- <h2>Render Order</h2>
--
-- When you need explicit control over the top-to-bottom ordering of rendered elements, you should use layers. As
-- stated in the @{createLayer} documentation, each layer that is created within a script will be rendered on top of
-- each previous layer, such that the first layer created appears at the bottom, while the last layer created appears
-- at the top.
--
-- Shapes that live on the same layer do not offer as much control. Among the same type of shape, instances rendered
-- later will appear on top of those rendered before, so if you add two boxes to a layer, the last box added will
-- appear on top. However, the situation is more complex when mixing different shapes. For rendering efficiency, all
-- instances of a shape type on the same layer are drawn at the same time. This means that all instances of one shape
-- will appear below or above all instances of other shapes, regardless of the relative order in which they were added
-- to the layer. Currently, the ordering is as follows, from top to bottom:
--
-- <ul>
--   <li>Text</li>
--   <li>Quads</li>
--   <li>Triangles</li>
--   <li>Lines</li>
--   <li>Circles</li>
--   <li>Rounded Boxes</li>
--   <li>Boxes</li>
--   <li>Beziers</li>
--   <li>Images</li>
-- </ul>
--
-- Thus, all boxes will always render below all circles on the same layer, and text on the same layer will appear on
-- top of both. It is not possible to control this behavior, nor is it a good idea to rely on it, as it is subject to
-- change. If you need to rely on something appearing in front of something else, you should use multiple layers.
--
-- <h2>Additional Functions</h2>
--
-- Additional funcionality is provided in the @{game_data_lua.rslib|rslib.lua} library in your Dual Universe\Game\data\lua directory,
-- accessible by calling <code>local rslib = require('rslib')</code>.
--
-- Lua calls available within the screen renderer environment:
-- <ul>
--   <li><b>Libraries</b>
--     <ul>
--       <li>table</li>
--       <li>string</li>
--       <li>math</li>
--     </ul>
--   </li>
--   <li><b>Functions</b>
--     <ul>
--       <li>next</li>
--       <li>select</li>
--       <li>pairs</li>
--       <li>ipairs</li>
--       <li>type</li>
--       <li>tostring</li>
--       <li>tonumber</li>
--       <li>pcall</li>
--       <li>xpcall</li>
--       <li>assert</li>
--       <li>error</li>
--       <li>require</li>
--       <li>load</li>
--       <li>setmetatable</li>
--       <li>getmetatable</li>
--     </ul>
--   </li>
-- </ul>
--
-- @see ScreenUnit.setRenderScript
-- @see game_data_lua.rslib
-- @module renderScript
-- @alias M

-- define class fields
local M = {
    renderCostMax = 4000000,
}

--- Shape constants for shapeType. Used to set default properties by shape.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table Shape
M.Shape = {
    Shape_Bezier = 0,
    Shape_Box = 1,
    Shape_BoxRounded = 2,
    Shape_Circle = 3,
    Shape_Image = 4,
    Shape_Line = 5,
    Shape_Polygon = 6, -- Applies to both Triangle and Quad.
    Shape_Text = 7,
}

--- Horizontal alignment constants for alignH. Used by @{setNextTextAlign}.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table AlignH
M.AlignH = {
    AlignH_Left = 0, -- (<b>Default</b>) Align to the start of the text.
    AlignH_Center = 1, -- Align to the middle of the text.
    AlignH_Right = 2, -- Align to the end of the text.
}

--- Vertical alignment constants for alignV. Used by @{setNextTextAlign}.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table AlignV
M.AlignV = {
    AlignV_Ascender = 0, -- Align to top of ascender.
    AlignV_Top = 1, -- Align to height of capital characters.
    AlignV_Middle = 2, -- Align to middle of characters.
    AlignV_Baseline = 3, -- (<b>Default</b>) Align to text baseline.
    AlignV_Bottom = 4,
    AlignV_Descender = 5, -- Align to bottom of descender.
}

function M:new(o, xRes, yRes, prefix)
    -- define default instance fields
    o = o or {
    }
    setmetatable(o, self)
    self.__index = self

    o.resolution = {
        x = xRes or 1024,
        y = yRes or 613,
    }

    -- prefix applied to svg defs to allow multiple SVGs to be rendered in the same html document
    o.prefix = prefix

    o.input = ""
    o.mouseX, o.mouseY = -1, -1
    o.cursorDown, o.cursorPressed, o.cursorReleased = false, false, false
    o.deltaTime = 0.0
    o.time = 0.0
    o.locale = "en-US"

    o.layers = {}
    o.fonts = {}
    o.backgroundColor = {0, 0, 0}
    o.renderCost = 0

    o.output = ""

    o.fontStrings = {}

    return o
end

-- ---------------- --
-- Helper Functions --
-- ---------------- --

local function validateParameters(expected, ...)
    local args = table.pack(...)
    local expectedType, value
    for i = args.n, 1, -1 do
        value = args[i]
        expectedType = expected[i]
        if expectedType == "integer" then
            expectedType = "number"
        elseif expectedType == "string" and type(value) == "number" then
            value = tostring(value)
        end

        assert(type(value) == expectedType,
            string.format("expected %s for parameter %d", expected[i], i))

        if expectedType == "integer" then
            assert(value // 1 == value,
                string.format("expected %s for parameter %d", expected[i], i))
        end
    end
end

-- Get the requested layer with error handling.
-- @tparam table self The RenderScript to act on.
-- @tparam int layer The layer reference to retrieve.
-- @treturn table The requested layer object.
local function getLayer(self, layer)
    local layerRef = self.layers[layer]
    if not layerRef then
        error("invalid layer handle")
    end
    return layerRef
end

-- Get the requested font with error handling.
-- @tparam table self The RenderScript to act on.
-- @tparam int layer The font reference to retrieve.
-- @treturn table The requested font object.
local function getFont(self, font)
    local fontRef = self.fonts[font]
    if not fontRef then
        error("invalid font handle")
    end
    return fontRef
end

local Property = {
    FillColor = {
        next = "nextFillColor",
        default = "defaultFillColor",
        missing = {1.0, 1.0, 1.0, 1.0}
    },
    Rotation = {
        next = "nextRotation",
        default = "defaultRotation",
        missing = 0
    },
    Shadow = {
        next = "nextShadow",
        default = "defaultShadow",
        missing = {0, 1.0, 1.0, 1.0, 1.0}
    },
    StrokeColor = {
        next = "nextStrokeColor",
        default = "defaultStrokeColor",
        missing = {1.0, 1.0, 1.0, 1.0}
    },
    StrokeWidth = {
        next = "nextStrokeWidth",
        default = "defaultStrokeWidth",
        missing = 0
    },
    TextAlign = {
        next = "nextTextAlign",
        default = "defaultTextAlign",
        missing = {M.AlignH.AlignH_Left, M.AlignV.AlignV_Baseline}
    }
}

-- Get the requested property for the provided layer.
-- @tparam table layer The layer object to extract the property from.
-- @tparam table property The Property reference to look up.
-- @tparam int shapeType The shape type to look up.
-- @return The selected (or default) value for property.
local function getPropertyValue(layer, property, shapeType)
    local value

    if layer[property.next] then
        value = layer[property.next]
    elseif layer[property.default][shapeType] then
        value = layer[property.default][shapeType]
    else
        value = property.missing
    end

    return value
end

-- Clear the "next" properties, for use when an item is added.
-- @tparam table layer The layer object to reset "next" on.
local function clearNext(layer)
    for _, keys in pairs(Property) do
        layer[keys.next] = nil
    end
end

-- ------ --
-- Shapes --
-- ------ --

--- Add a quadratic bezier curve to the given layer.
--
-- Supported properties: shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x1 X coordinate of the first point of the curve (the starting point).
-- @tparam float y1 Y coordinate of the first point of the curve (the starting point).
-- @tparam float x2 X coordinate of the second point of the curve (the control point).
-- @tparam float y2 Y coordinate of the second point of the curve (the control point).
-- @tparam float x3 X coordinate of the third point of the curve (the ending point).
-- @tparam float y3 Y coordinate of the third point of the curve (the ending point).
function M:addBezier(layer, x1, y1, x2, y2, x3, y3)
    validateParameters({"integer", "number", "number", "number", "number", "number", "number"}
        , layer, x1, y1, x2, y2, x3, y3)
    local layerRef = getLayer(self, layer)
    if not layerRef.bezier then
        layerRef.bezier = {}
    end
    local layerShape = layerRef.bezier

    layerShape[#layerShape + 1] = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        x3 = x3,
        y3 = y3,
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Bezier),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Bezier),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Bezier)
    }

    clearNext(layerRef)
end

--- Add a rectangle to the given layer with top-left corner (x,y) and dimensions width x height.
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x The x coordinate (in pixels) of the left side of the box.
-- @tparam float y The y coordinate (in pixels) of the top side of the box.
-- @tparam float width The width of the box in pixels.
-- @tparam float height The height of the box in pixels.
function M:addBox(layer, x, y, width, height)
    validateParameters({"integer", "number", "number", "number", "number"}
        , layer, x, y, width, height)
    local layerRef = getLayer(self, layer)
    if not layerRef.box then
        layerRef.box = {}
    end
    local layerShape = layerRef.box

    local shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Box)
    local strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Box)
    layerShape[#layerShape + 1] = {
        x = x,
        y = y,
        width = width,
        height = height,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Box),
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_Box),
        shadow = shadow,
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Box),
        strokeWidth = strokeWidth
    }

    clearNext(layerRef)

    -- cost equal to the size of the screen area changed
    local sizeBump = ((shadow and shadow[1] or 0) + (strokeWidth or 0)) * 2
    self.renderCost = self.renderCost + math.max(16, (width + sizeBump) * (height + sizeBump))
end

--- Add a rectangle to the given layer with top-left corner (x,y) and dimensions width x height with each corner
-- rounded to radius.
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x The x coordinate (in pixels) of the left side of the box.
-- @tparam float y The y coordinate (in pixels) of the top side of the box.
-- @tparam float width The width of the box in pixels.
-- @tparam float height The height of the box in pixels.
-- @tparam float radius The corner radius of the box in pixels.
function M:addBoxRounded(layer, x, y, width, height, radius)
    validateParameters({"integer", "number", "number", "number", "number", "number"}
        , layer, x, y, width, height, radius)
    local layerRef = getLayer(self, layer)
    if not layerRef.boxRounded then
        layerRef.boxRounded = {}
    end
    local layerShape = layerRef.boxRounded

    layerShape[#layerShape + 1] = {
        x = x,
        y = y,
        width = width,
        height = height,
        radius = radius,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_BoxRounded),
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_BoxRounded),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_BoxRounded),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_BoxRounded),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_BoxRounded)
    }

    clearNext(layerRef)
end

--- Add a circle to the given layer with center (x, y) and radius radius.
--
-- Supported properties: fillColor, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x The x coordinate (in pixels) of the center of the circle.
-- @tparam float y The y coordinate (in pixels) of the center of the circle.
-- @tparam float radius The radius of the circle in pixels.
function M:addCircle(layer, x, y, radius)
    validateParameters({"integer", "number", "number", "number"}
        , layer, x, y, radius)
    local layerRef = getLayer(self, layer)
    if not layerRef.circle then
        layerRef.circle = {}
    end
    local layerShape = layerRef.circle

    layerShape[#layerShape + 1] = {
        x = x,
        y = y,
        radius = radius,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Circle),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Circle),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Circle),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Circle)
    }

    clearNext(layerRef)
end

--- Add image reference to layer as a rectangle with top-left corner x, y) and dimensions width x height.
--
-- Supported properties: fillColor, rotation
-- @tparam int layer The id of the layer to which to add.
-- @tparam int image The handle for the image to add.
-- @tparam float x The x coordinate (in pixels) of the image's top-left corner.
-- @tparam float y The y coordinate (in pixels) of the image's top-left corner.
-- @tparam float width The width of the image in pixels.
-- @tparam float height The height of the image in pixels.
-- @see loadImage
function M:addImage(layer, image, x, y, width, height)
    validateParameters({"integer", "integer", "number", "number", "number", "number"}
        , layer, image, x, y, width, height)
    local layerRef = getLayer(self, layer)

    -- TODO Implement

    clearNext(layerRef)
end

--- Add image reference to layer as a rectangle with top-left corner x, y) and dimensions width x height.
--
-- Supported properties: fillColor, rotation
-- @tparam int layer The id of the layer to which to add.
-- @tparam int image The id of the image to add.
-- @tparam float x The x coordinate (in pixels) of the image's top-left corner.
-- @tparam float y The y coordinate (in pixels) of the image's top-left corner.
-- @tparam float sx Width of the image.
-- @tparam float sy Height of the image.
-- @tparam float subX X coordinate of the top-left corner of the sub-region to draw.
-- @tparam float subY Y coordinate of the top-left corner of the sub-region to draw.
-- @tparam float subSx Width of the sub-region within the image to draw.
-- @tparam float subSy Height of the sub-region within the image to draw.
-- @see loadImage
function M:addImageSub(layer, image, x, y, sx, sy, subX, subY, subSx, subSy)
    validateParameters({"integer", "integer", "number", "number", "number", "number", "number", "number", "number", "number"}
        , layer, image, x, y, sx, sy, subX, subY, subSx, subSy)
    local layerRef = getLayer(self, layer)

    -- TODO Implement

    clearNext(layerRef)
end

--- Add a line to layer from (x1, y1) to (x2, y2).
--
-- Supported properties: rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x1 The x coordinate (in pixels) of the start of the line.
-- @tparam float y1 The y coordinate (in pixels) of the start of the line.
-- @tparam float x2 The x coordinate (in pixels) of the end of the line.
-- @tparam float y2 The y coordinate (in pixels) of the end of the line.
function M:addLine(layer, x1, y1, x2, y2)
    validateParameters({"integer", "number", "number", "number", "number"}
        , layer, x1, y1, x2, y2)
    local layerRef = getLayer(self, layer)
    if not layerRef.line then
        layerRef.line = {}
    end
    local layerShape = layerRef.line

    layerShape[#layerShape + 1] = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_Line),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Line),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Line),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Line)
    }

    clearNext(layerRef)
end

--- Add a quadrilateral to the given layer with vertices (x1, y1), (x2, y2), (x3, y3), (x4, y4).
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x1 The x coordinate (in pixels) of the first corner.
-- @tparam float y1 The y coordinate (in pixels) of the first corner.
-- @tparam float x2 The x coordinate (in pixels) of the second corner.
-- @tparam float y2 The y coordinate (in pixels) of the second corner.
-- @tparam float x3 The x coordinate (in pixels) of the third corner.
-- @tparam float y3 The y coordinate (in pixels) of the third corner.
-- @tparam float x4 The x coordinate (in pixels) of the final corner.
-- @tparam float y4 The y coordinate (in pixels) of the final corner.
function M:addQuad(layer, x1, y1, x2, y2, x3, y3, x4, y4)
    validateParameters({"integer", "number", "number", "number", "number", "number", "number", "number", "number"}
        , layer, x1, y1, x2, y2, x3, y3, x4, y4)
    local layerRef = getLayer(self, layer)
    if not layerRef.quad then
        layerRef.quad = {}
    end
    local layerShape = layerRef.quad

    layerShape[#layerShape + 1] = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        x3 = x3,
        y3 = y3,
        x4 = x4,
        y4 = y4,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Polygon),
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_Polygon),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Polygon),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Polygon),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Polygon)
    }

    clearNext(layerRef)
end

--- Add text to layer using font, with top-left baseline starting at (x, y). Note that each glyph in text counts as one
-- shape toward the total rendered shape limit.
--
-- Supported properties: fillColor, shadow, strokeColor, strokeWidth, textAlign
-- @tparam int layer The id of the layer to which to add.
-- @tparam int font The id of the font to use.
-- @tparam string text The text to add.
-- @tparam float x The x coordinate (in pixels) of the top-left baseline.
-- @tparam float y The y coordinate (in pixels) of the top-left baseline.
-- @see loadFont
function M:addText(layer, font, text, x, y)
    validateParameters({"integer", "integer", "string", "number", "number"}
        , layer, font, text, x, y)
    local layerRef = getLayer(self, layer)
    if not layerRef.text then
        layerRef.text = {}
    end
    local layerShape = layerRef.text
    local fontRef = getFont(self, font)

    local shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Box)
    local strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Box)
    layerShape[#layerShape + 1] = {
        x = x,
        y = y,
        text = text,
        font = fontRef.name,
        size = fontRef.size,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Text),
        shadow = shadow,
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Text),
        strokeWidth = strokeWidth,
        textAlign = getPropertyValue(layerRef, Property.TextAlign, M.Shape.Shape_Text)
    }

    clearNext(layerRef)

    -- cost equal to the size of the getTextBounds box with decimal truncated
    local width, height = self:getTextBounds(font, text)
    local sizeBump = ((shadow and shadow[1] or 0) + (strokeWidth or 0)) * 2
    self.renderCost = self.renderCost + math.floor((width + sizeBump) * (height + sizeBump))
end

--- Add a triangle to the given layer with vertices (x1, y1), (x2, y2), (x3, y3).
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x1 The x coordinate (in pixels) of the first corner.
-- @tparam float y1 The y coordinate (in pixels) of the first corner.
-- @tparam float x2 The x coordinate (in pixels) of the second corner.
-- @tparam float y2 The y coordinate (in pixels) of the second corner.
-- @tparam float x3 The x coordinate (in pixels) of the third corner.
-- @tparam float y3 The y coordinate (in pixels) of the third corner.
function M:addTriangle(layer, x1, y1, x2, y2, x3, y3)
    validateParameters({"integer", "number", "number", "number", "number", "number", "number"}
        , layer, x1, y1, x2, y2, x3, y3)
    local layerRef = getLayer(self, layer)
    if not layerRef.triangle then
        layerRef.triangle = {}
    end
    local layerShape = layerRef.triangle

    layerShape[#layerShape + 1] = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        x3 = x3,
        y3 = y3,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Polygon),
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_Polygon),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Polygon),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Polygon),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Polygon)
    }

    clearNext(layerRef)
end

-- ------ --
-- Layers --
-- ------ --

--- Create a new layer that will be rendered on top of all previously-created layers.
-- @treturn int The id that can be used to uniquely identify the layer for use with other API functions.
function M:createLayer()
    self.layers[#self.layers + 1] = {
        defaultFillColor = {},
        defaultRotation = {},
        defaultShadow = {},
        defaultStrokeColor = {},
        defaultStrokeWidth = {
            [M.Shape.Shape_Bezier] = 1,
            [M.Shape.Shape_Line] = 1
        },
        defaultTextAlign = {}
    }

    self.renderCost = self.renderCost + 75000

    return #self.layers
end

--- Set a clipping rectangle applied to the layer as a whole. Layer contents that fall outside the clipping rectangle
-- will not be rendered, and those that are partially within the rectangle will be 'clipped' against it. The clipping
-- rectangle is applied before layer transformations. Note that clipped contents still count toward the render cost.
-- @tparam int layer The id of the layer for which the clipping rectangle will be set.
-- @tparam float x The X coordinate of the clipping rectangle's top-left corner.
-- @tparam float y The Y coordinate of the clipping rectangle's top-left corner.
-- @tparam float sx The width of the clipping rectangle.
-- @tparam float sy The height of the clipping rectangle.
function M:setLayerClipRect(layer, x, y, sx, sy)
    validateParameters({"integer", "number", "number", "number", "number"}
        , layer, x, y, sx, sy)
    local layerRef = getLayer(self, layer)
    layerRef.clipRect = {
        x = x,
        y = y,
        width = sx,
        height = sy}

    self.renderCost = self.renderCost + 0
end

--- Set the transform origin of a layer; layer scaling and rotation are applied relative to this origin.
-- @tparam int layer The id of the layer for which the origin will be set.
-- @tparam float x The X coordinate of the layer's transform origin.
-- @tparam float y The Y coordinate of the layer's transform origin.
function M:setLayerOrigin(layer, x, y)
    validateParameters({"integer", "number", "number"}
        , layer, x, y)
    local layerRef = getLayer(self, layer)
    layerRef.origin = {x, y}
end

--- Set a rotation applied to the layer as a whole, relative to the layer's transform origin.
-- @tparam int layer The id of the layer for which the rotation will be set.
-- @tparam float rotation Rotation, in radians; positive is counter-clockwise, negative is clockwise.
function M:setLayerRotation(layer, rotation)
    validateParameters({"integer", "number"}
        , layer, rotation)
    local layerRef = getLayer(self, layer)
    layerRef.rotation = math.deg(rotation)

    self.renderCost = self.renderCost + 0
end

--- Set a scale factor applied to the layer as a whole, relative to the layer's transform origin. Scale factors are
-- multiplicative, so that a scale >1 enlarges the size of the layer, 1.0 does nothing, and <1 reduces the size of the
-- layer.
-- @tparam int layer The id of the layer for which the scale factor will be set.
-- @tparam float sx The scale factor along the X axis.
-- @tparam float sy The scale factor along the Y axis.
function M:setLayerScale(layer, sx, sy)
    validateParameters({"integer", "number", "number"}
        , layer, sx, sy)
    local layerRef = getLayer(self, layer)
    layerRef.scale = {sx, sy}
end

--- Set a translation applied to the layer as a whole.
-- @tparam int layer The id of the layer for which the translation will be set.
-- @tparam float tx The translation along the X axis.
-- @tparam float ty The translation along the Y axis.
function M:setLayerTranslation(layer, tx, ty)
    validateParameters({"integer", "number", "number"}
        , layer, tx, ty)
    local layerRef = getLayer(self, layer)
    layerRef.translation = {tx, ty}
end

-- ---------------------- --
-- Screen State Functions --
-- ---------------------- --

--- Return the screen location that is currently raycasted by the player in screen pixel coordinates as a (x, y) tuple.
-- Returns (-1, -1) if the current raycasted location is not inside the screen.
-- @treturn float,float The mouse (x, y) in pixels.
function M:getCursor()
    return self.mouseX, self.mouseY
end

--- Return true if the mouse cursor is currently pressed down on the screen, false otherwise. Retains its state if
-- dragged out of the screen.
-- @treturn boolean True if the mouse is pressed on the screen, false otherwise.
function M:getCursorDown()
    return self.cursorDown
end

--- Return true if the mouse button changed from being released to being pressed at any point since the last update.
-- Note that it is possible for both getCursorPressed() and getCursorReleased() to return true in the same script
-- execution, if the mouse button was both pressed and released since the last execution.
-- @treturn boolean True if the mouse was pressed since the last update, false otherwise.
-- @see getCursorReleased
function M:getCursorPressed()
    return self.cursorPressed
end

--- Return true if the mouse button changed from being pressed to being released at any point since the last update.
-- Note that it is possible for both getCursorPressed() and getCursorReleased() to return true in the same script
-- execution, if the mouse button was both pressed and released since the last execution.  
-- @treturn boolean True if the mouse was released since the last update, false otherwise.
-- @see getCursorPressed
function M:getCursorReleased()
    return self.cursorReleased
end

--- Returns the time, in seconds, since the screen was last updated. Useful for timing-based animations, since screens
-- are not guaranteed to be updated at any specific time interval, it is more reliable to update animations based on
-- this timer than based on a frame counter.
-- @treturn float Time since last refresh in seconds.
function M:getDeltaTime()
    return self.deltaTime
end

--- Returns the time, in seconds, relative to the first execution.
-- @treturn float Time, in seconds, since the render script started running.
function M:getTime()
    return self.time
end

--- Return the locale in which the game is currently running.
-- @treturn string The locale, currently one of "en-US", "fr-FR", or "de-DE".
function M:getLocale()
    return self.locale
end

--- Return the current render cost of the script thus far, used to profile the performance of a screen. This can be
-- used to abort further render instructions when close to the render maximum preventing the screen from shutting down.
-- @treturn int The current render cost.
function M:getRenderCost()
    return self.renderCost
end

--- Return the maximum render cost limit. When a script exceeds this render cost in one execution, an error will be
-- thrown and the contents will fail to render.
-- @treturn int The render cost limit.
function M:getRenderCostMax()
    return self.renderCostMax
end

--- Return the current viewport resolution as a (width, height) tuple.
-- @treturn int,int resolution The resolution in the form of (width, height).
function M:getResolution()
    return self.resolution.x, self.resolution.y
end

--- Write message to the Lua chat if the output checkbox is checked.
-- @tparam string message The message to print.
function M:logMessage(message)
    local success, result = pcall(print, message)
    assert(success, "expected string for parameter 1")
end

-- ------------------ --
-- Loading References --
-- ------------------ --

--- Return an image handle that can be used with @{addImage}. If the image is not yet loaded, a sentinel value will be
-- returned that will cause addImage to fail silently, so that the rendered image will not appear until it is loaded.
-- Only images that have gone through image validation are available.
-- @tparam string path The path to the image to load.
-- @treturn int The handle to the newly loaded image.
-- @see addImage
function M:loadImage(path)
    -- TODO Implement
    return 0
end

--- Returns true if the given imageHandle is loaded.
-- @tparam int imageHandle An image handle provided by loadImage.
-- @treturn boolean True if loaded, false otherwise.
-- @see loadImage
function M:isImageLoaded(imageHandle)
    -- TODO error message: invalid image handle
    -- TODO Implement
    return false
end

--- Returns the width and height of an image.
-- @tparam int image The id of the image to query.
-- @treturn float,float A tuple containing the width and height, respectively, of the image, or (0, 0) if the image is
--   not yet loaded.
function M:getImageSize(image)
    -- TODO error message: invalid image handle
    -- TODO Implement
    return 0, 0
end

local AvailableFonts = {
    "FiraMono",
    "FiraMono-Bold",
    "Montserrat",
    "Montserrat-Bold",
    "Montserrat-Light",
    "Play",
    "Play-Bold",
    "RefrigeratorDeluxe",
    "RefrigeratorDeluxe-Light",
    "RobotoCondensed",
    "RobotoMono",
    "RobotoMono-Bold",
}

local FontData = {
    ["FiraMono"] = {
        name = "Fira Mono",
        ascenderMult = 0.935546875,
        descenderMult = -0.265625,
        widthMultAvg = 0.70282573084677,
        heightMultAvg = 0.92565524193548,
    },
    ["FiraMono-Bold"] = {
        name = "Fira Mono",
        weight = "bold",
        ascenderMult = 0.935546875,
        descenderMult = -0.265625,
        widthMultAvg = 0.7590568296371,
        heightMultAvg = 0.93699596774194,
    },
    ["Montserrat"] = {
        ascenderMult = 0.96875,
        descenderMult = -0.251953125,
        widthMultAvg = 0.7839591733871,
        heightMultAvg = 0.921875,
    },
    ["Montserrat-Bold"] = {
        name = "Montserrat",
        weight = "bold",
        ascenderMult = 0.96875,
        descenderMult = -0.251953125,
        widthMultAvg = 0.82601436491935,
        heightMultAvg = 0.92666330645161,
    },
    ["Montserrat-Light"] = {
        name = "Montserrat",
        weight = "lighter",
        ascenderMult = 0.96875,
        descenderMult = -0.251953125,
        widthMultAvg = 0.7614037298387,
        heightMultAvg = 0.91859879032258,
    },
    ["Play"] = {
        ascenderMult = 0.9375,
        descenderMult = -0.220703125,
        widthMultAvg = 0.7009513608871,
        heightMultAvg = 0.87525201612903,
    },
    ["Play-Bold"] = {
        name = "Play",
        weight = "bold",
        ascenderMult = 0.9375,
        descenderMult = -0.220703125,
        widthMultAvg = 0.75017326108871,
        heightMultAvg = 0.87525201612903,
    },
    ["RefrigeratorDeluxe"] = {
        name = "refrigerator-deluxe, sans-serif",
        ascenderMult = 0.82421875,
        descenderMult = -0.1767578125,
        widthMultAvg = 0.54813508064516,
        heightMultAvg = 0.88886088709677,
    },
    ["RefrigeratorDeluxe-Light"] = {
        name = "refrigerator-deluxe, sans-serif",
        weight = "lighter",
        ascenderMult = 0.82421875,
        descenderMult = -0.1767578125,
        widthMultAvg = 0.52898185483871,
        heightMultAvg = 0.88860887096774,
    },
    ["RobotoCondensed"] = {
        name = "Roboto Condensed",
        ascenderMult = 0.927734375,
        descenderMult = -0.244140625,
        widthMultAvg = 0.63977444556452,
        heightMultAvg = 0.93220766129032,
    },
    ["RobotoMono"] = {
        name = "Roboto Mono",
        ascenderMult = 1.0478515625,
        descenderMult = -0.271484375,
        widthMultAvg = 0.71044921875,
        heightMultAvg = 0.93245967741935,
    },
    ["RobotoMono-Bold"] = {
        name = "Roboto Mono",
        weight = "bold",
        ascenderMult = 1.0478515625,
        descenderMult = -0.271484375,
        widthMultAvg = 0.73979334677419,
        heightMultAvg = 0.93321572580645,
    }
}

--- Returns the number of fonts available to be used by render script.
-- @treturn int The total number of fonts available.
function M:getAvailableFontCount()
    return #AvailableFonts
end

--- Returns the name of the nth available font.
-- @tparam int index A number between 1 and the return value of @{getAvailableFontCount}.
-- @treturn string The name of the font, which can be used with the @{loadFont} function.
function M:getAvailableFontName(index)
    validateParameters({"integer"}, index)
    assert(index >= 1 and index <= #AvailableFonts, "out-of-bounds font index")
    return AvailableFonts[index]
end

--- Return a font handle that can be used with @{addText}. If the font is not yet loaded, a sentinel value will be
-- returned that will cause addText to fail silently, so that the rendered text will not appear until the font is
-- loaded.
--
-- Name must be one of the following currently-available fonts:
-- <ul>
--   <li>FiraMono</li>
--   <li>FiraMono-Bold</li>
--   <li>Montserrat</li>
--   <li>Montserrat-Bold</li>
--   <li>Montserrat-Light</li>
--   <li>Play</li>
--   <li>Play-Bold</li>
--   <li>RefrigeratorDeluxe</li>
--   <li>RefrigeratorDeluxe-Light</li>
--   <li>RobotoCondensed</li>
--   <li>RobotoMono</li>
--   <li>RobotoMono-Bold</li>
-- </ul>
-- @tparam string name The name of the font to load, chosen from the above list.
-- @tparam float size The size, in vertical pixels, at which the font will render. Note that this size can be changed
--   during script execution with the @{setFontSize} function.
-- @treturn int The id that can be used to uniquely identify the font for use with other API functions.
-- @see addText
function M:loadFont(name, size)
    validateParameters({"string", "number"}
        , name, size)
    local found = false
    for _, font in pairs(AvailableFonts) do
        if font == name then
            found = true
            break
        end
    end
    assert(found, string.format("unknown font <%s>", name))

    assert(#self.fonts < 8, "exceeded maximum number of loaded fonts (8)")

    self.fonts[#self.fonts + 1] = {
        name = name,
        size = size
    }
    return #self.fonts
end

--- <b>Deprecated:</b> Returns true if the given font is loaded.
-- @tparam int font A font handle provided by load font.
-- @treturn boolean True if loaded, false otherwise.
-- @see loadFont
function M:isFontLoaded(font)
    validateParameters({"integer"}, font)
    getFont(self, font)
    -- if getFont returned without error the font handle is valid and loaded
    return true
end

--- Compute and return the bounding box width and height of the given text in the given font as a (width, height)
-- tuple.
-- @tparam int font A font handle provided by load font.
-- @tparam string text The text to calculate bounds for.
-- @treturn float,float The text bounds as (width, height) in pixels.
-- @see loadFont
function M:getTextBounds(font, text)
    validateParameters({"integer", "string"}, font, text)
    local fontRef = getFont(self, font)

    -- if matching string data is found use it
    if self.fontStrings and self.fontStrings[fontRef.name] and self.fontStrings[fontRef.name][text] then
        local stringData = self.fontStrings[fontRef.name][text]
        return stringData[1] * fontRef.size, stringData[2] * fontRef.size
    end

    -- otherwise fall back to average size for the font
    local fontData = FontData[fontRef.name]
    local length = string.len(text)
    return fontData.widthMultAvg * fontRef.size * length, fontData.heightMultAvg * fontRef.size
end

--- Compute and return the ascender and descender height of given font.
-- @tparam int font The id of the font to query.
-- @treturn float,float A tuple containing the maximal ascender and descender, respectively, of the given font.
-- @see loadFont
function M:getFontMetrics(font)
    validateParameters({"integer"}, font)
    local fontRef = getFont(self, font)
    local fontData = FontData[fontRef.name]
    return fontData.ascenderMult * fontRef.size, fontData.descenderMult * fontRef.size
end

--- Return the currently-set size for the given font.
-- @tparam int font The id of the font to query.
-- @treturn float The font size in vertical pixels.
function M:getFontSize(font)
    validateParameters({"integer"}, font)
    local fontRef = getFont(self, font)
    return fontRef.size
end

--- Set the size at which a font will render. Impacts all subsequent font-related calls, including @{addText}, @{getFontMetrics}, and @{getTextBounds}.
-- @tparam int font The id of the font for which the size will be set.
-- @tparam int size The new size, in vertical pixels, at which the font will render.
function M:setFontSize(font, size)
    validateParameters({"integer", "number"},
        font, size)
    local fontRef = getFont(self, font)
    fontRef.size = size
end

-- --------- --
-- Animation --
-- --------- --

--- Notify the screen manager that this screen should be redrawn in frames frames. A screen that requires highly-fluid
-- animations should thus call requestAnimationFrame(1) before it returns.
--
-- Usage of this function has an obvious and significant performance impact on the screen unit system. Scripts should
-- try to request updates as infrequently as possible for their application. <u>A screen with unchanging (static)
-- contents should not call this function at all.</u>
-- @tparam int frames The number of frames to wait before redrawing the screen.
function M:requestAnimationFrame(frames)
    validateParameters({"integer"}, frames)
end

-- ------------------- --
-- Properties Defaults --
-- ------------------- --

--- Set the background color of the screen as red (r), green (g), blue (b) in the range [0, 1].
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
function M:setBackgroundColor(r, g, b)
    validateParameters({"number", "number", "number"},
        r, g, b)
    self.backgroundColor = {r, g, b}
end

--- Set the default fill color for all shapeType on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the fillColor property.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The type of @{Shape} to which the default will apply.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
-- @see Shape
function M:setDefaultFillColor(layer, shapeType, r, g, b, a)
    validateParameters({"integer", "integer", "number", "number", "number", "number"},
        layer, shapeType, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.defaultFillColor[shapeType] = {r, g, b, a}
end

--- Set the default rotation for all shapeType on layer. Rotation is specified in CCW radians radians. Has no effect
-- on shapes that don't support the rotation property.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The type of @{Shape} to which the default will apply.
-- @tparam float radians Rotation, in radians; positive is counter-clockwise, negative is clockwise.
-- @see Shape
function M:setDefaultRotation(layer, shapeType, radians)
    validateParameters({"integer", "integer", "number"},
        layer, shapeType, radians)
    local layerRef = getLayer(self, layer)
    layerRef.defaultRotation[shapeType] = math.deg(radians)
end

--- Set the default shadow for all shapeType on layer with size radius. Red (r), green (g), blue (b), and alpha (a)
-- components are specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the shadow
-- property.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The type of @{Shape} to which the default will apply.
-- @tparam float radius The distance that the shadow extends from the shape's border.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
-- @see Shape
function M:setDefaultShadow(layer, shapeType, radius, r, g, b, a)
    validateParameters({"integer", "integer", "number", "number", "number", "number", "number"},
        layer, shapeType, radius, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.defaultShadow[shapeType] = {radius, r, g, b, a}
end

--- Set the default stroke color for all shapeType on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the strokeColor property.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
-- @see Shape
function M:setDefaultStrokeColor(layer, shapeType, r, g, b, a)
    validateParameters({"integer", "integer", "number", "number", "number", "number"},
        layer, shapeType, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.defaultStrokeColor[shapeType] = {r, g, b, a}
end

--- Set the default stroke width for all shapeType on layer. Width is specified in pixels. Positive values produce an
-- outer stroke, while negative values produce an inner stroke. Has no effect on shapes that don't support the
-- strokeWidth property.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The type of @{Shape} to which the default will apply.
-- @tparam float width Stroke width, in pixels.
-- @see Shape
function M:setDefaultStrokeWidth(layer, shapeType, width)
    validateParameters({"integer", "integer", "number"},
        layer, shapeType, width)
    local layerRef = getLayer(self, layer)
    layerRef.defaultStrokeWidth[shapeType] = width
end

--- Set the default text alignment of all subsequent text strings on the given layer.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int alignH Controls the horizontal alignment of a text shape relative to the draw coordinates. Must be a
--   built in constant from @{AlignH}.
-- @tparam int alignV Controls the vertical alignment of a text shape relative to the draw coordinates. Must be a built
--   in constant from @{AlignV}.
-- @see AlignH
-- @see AlignV
function M:setDefaultTextAlign(layer, alignH, alignV)
    validateParameters({"integer", "integer", "integer"},
        layer, alignH, alignV)
    local layerRef = getLayer(self, layer)
    layerRef.defaultTextAlign[M.Shape.Shape_Text] = {alignH, alignV}
end

-- ---------- --
-- Properties --
-- ---------- --

--- Set the fill color of the next rendered shape on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the fillColor property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
function M:setNextFillColor(layer, r, g, b, a)
    validateParameters({"integer", "number", "number", "number", "number"},
        layer, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.nextFillColor = {r, g, b, a}
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW radians. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float radians The angle (in radians) to rotate by.
-- @see setNextRotationDegrees
function M:setNextRotation(layer, radians)
    validateParameters({"integer", "number"},
        layer, radians)
    local layerRef = getLayer(self, layer)
    layerRef.nextRotation = math.deg(radians)
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW degrees. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float degrees The angle (in degrees) to rotate by.
-- @see setNextRotation
function M:setNextRotationDegrees(layer, degrees)
    validateParameters({"integer", "number"},
        layer, degrees)
    local layerRef = getLayer(self, layer)
    layerRef.nextRotation = degrees
end

--- Set the shadow of the next rendered shape on layer with size radius. Red (r), green (g), blue (b), and alpha (a)
-- components are specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the shadow
-- property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float radius The radius of the shadow.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
function M:setNextShadow(layer, radius, r, g, b, a)
    validateParameters({"integer", "number", "number", "number", "number", "number"},
        layer, radius, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.nextShadow = {radius, r, g, b, a}
end

--- Set the stroke color of the next rendered shape on layer. Red (r), green (g), blue (b), and alpha (a) components
-- are specified, respectively, in the range [0, 1].
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
function M:setNextStrokeColor(layer, r, g, b, a)
    validateParameters({"integer", "number", "number", "number", "number"},
        layer, r, g, b, a)
    local layerRef = getLayer(self, layer)
    layerRef.nextStrokeColor = {r, g, b, a}
end

--- Set the stroke width of the next rendered shape on layer. Width is specified in pixels. Positive values produce an
-- outer stroke, while negative values produce an inner stroke. Has no effect on shapes that don't support the
-- strokeWidth property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float width The width of the stroke in pixels.
function M:setNextStrokeWidth(layer, width)
    validateParameters({"integer", "number"},
        layer, width)
    local layerRef = getLayer(self, layer)
    layerRef.nextStrokeWidth = width
end

--- Set the next text alignment for the next rendered shape on layer.
--
-- Note that there is a subtle difference between AlignV_Ascender/AlignV_Descender and AlignV_Top/AlignV_Bottom: the
-- ascender and descender alignment modes anchor a text string to a global top/bottom position of the font, while the
-- top and bottom alignment modes anchor a text string relative to its own bounding box. Thus, while top/bottom are
-- useful for aligning individual text strings with high precision, they depend on the contents of the text string that
-- is rendered. On the other hand, ascender/descender align text in such a way that the alignment will not change
-- depending on the text string. The correct choice will depend on your specific use case and needs.
-- @tparam int layer The id of the layer to apply this property to.
-- @tparam int alignH Controls the horizontal alignment of a text shape relative to the draw coordinates. Must be a
--   built in constant from @{AlignH}.
-- @tparam int alignV Controls the vertical alignment of a text shape relative to the draw coordinates. Must be a built
--   in constant from @{AlignV}.
-- @see AlignH
-- @see AlignV
function M:setNextTextAlign(layer, alignH, alignV)
    validateParameters({"integer", "integer", "integer"},
        layer, alignH, alignV)
    local layerRef = getLayer(self, layer)
    layerRef.nextTextAlign = {alignH, alignV}
end

-- ------------------------ --
-- Control Unit Interaction --
-- ------------------------ --

--- Return a string of input data (or an empty string, if no input has been set) that can be set via a control unit
-- with the screen unit API function screen.setScriptInput(inputString).
-- @treturn string The input string set by the control unit.
-- @see ScreenUnit:setScriptInput
function M:getInput()
    return self.input
end

--- Set the script's output string to outputString, which can be retrieved via a control unit with the screen unit API
-- function screen.getScriptOuput()
-- @tparam string outputString The string to output to the control unit.
-- @see ScreenUnit:getScriptOutput
function M:setOutput(outputString)
    self.output = outputString
end

--- Mock only, not in-game: Resets internal render state, to be called between script runs to ready the environment for
-- repainting.
function M:mockReset()
    self.layers = {}
    self.fonts = {}
    self.backgroundColor = {0, 0, 0}
    self.renderCost = 0
    -- TODO - does output reset on refresh?
end

local function getClipPath(layer)
    if not layer.clipRect then
        return ""
    end
    local shape = layer.clipRect
    return string.format([[<rect x="%f" y="%f" width="%f" height="%f" />]],
        shape.x, shape.y, shape.width, shape.height)
end

local function colorToHex(r, g, b, a)
    local alpha = ""
    if a then
        alpha = string.format("%02x", math.floor(a * 255))
    end

    return string.format("#%02x%02x%02x%s", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), alpha)
end

local function getTransformString(layer)
    local transforms = {}

    if layer.translation then
        transforms[#transforms + 1] = string.format("translate(%f %f)", layer.translation[1], layer.translation[2])
    end

    local xO, yO = 0, 0
    if layer.origin then
        xO = layer.origin[1]
        yO = layer.origin[2]
        transforms[#transforms + 1] = string.format("translate(%f %f)", xO, yO)
    end
    if layer.rotation then
        transforms[#transforms + 1] = string.format("rotate(%f)", layer.rotation)
    end
    if layer.scale then
        transforms[#transforms + 1] = string.format("scale(%f %f)", layer.scale[1], layer.scale[2], xO, yO)
    end
    if layer.origin then
        transforms[#transforms + 1] = string.format("translate(%f %f)", -xO, -yO)
    end

    if #transforms > 0 then
        return string.format([[ transform="%s"]], table.concat(transforms, " "))
    end
    return ""
end

local function getFillString(shape)
    local fillColor = shape.fillColor

    local opacity = ""
    if fillColor[4] < 1.0 then
        opacity = string.format([[ fill-opacity="%f"]], fillColor[4])
    end

    return string.format([[ fill="%s"%s]],
        colorToHex(table.unpack(fillColor, 1, 3)), opacity)
end

local function getRotationString(shape, shapeType)
    local rotationDeg = shape.rotation
    if rotationDeg % (2 * math.pi) == 0 then
        return ""
    end

    local cx, cy
    if shapeType == M.Shape.Shape_Box or
       shapeType == M.Shape.Shape_BoxRounded
       then
        cx = shape.x + shape.width / 2
        cy = shape.y + shape.height / 2
    elseif shapeType == M.Shape.Shape_Line then
        cx = (shape.x1 + shape.x2) / 2
        cy = (shape.y1 + shape.y2) / 2
    elseif shapeType == M.Shape.Shape_Polygon then
        if shape.x4 then
            cx = (shape.x1 + shape.x2 + shape.x3 + shape.x4) / 4
            cy = (shape.y1 + shape.y2 + shape.y3 + shape.y4) / 4
        else
            cx = (shape.x1 + shape.x2 + shape.x3) / 3
            cy = (shape.y1 + shape.y2 + shape.y3) / 3
        end
    end

    return string.format([[ transform="rotate(%f %f %f)"]],
        rotationDeg, cx, cy)
end

local function getShadowString(shape)
    local radius, shadowColor = shape.shadow[1], {table.unpack(shape.shadow, 2)}
    if radius == 0 or shadowColor[4] == 0 then
        return ""
    end

    return string.format([[ style="filter: drop-shadow( 0 0 %fpx %s)"]],
        radius / 2, colorToHex(table.unpack(shadowColor)))
end

local function getStrokeString(shape)
    local strokeWidth, strokeColor = shape.strokeWidth, shape.strokeColor

    if strokeWidth <= 0 or strokeColor[4] <= 0 then
        return ""
    end

    local opacity = ""
    if strokeColor[4] < 1.0 then
        opacity = string.format([[ stroke-opacity="%f"]], strokeColor[4])
    end

    return string.format([[ stroke-width="%f" stroke="%s"%s]],
        strokeWidth, colorToHex(table.unpack(strokeColor, 1, 3)), opacity)
end

local function getFontString(shape)
    local font = FontData[shape.font]
    local fontFamily = font.name or shape.font
    local fontWeight = font.weight or "normal"
    return string.format([[ font-family="%s" font-weight="%s"]],
        fontFamily, fontWeight)
end

local AlignHMapping = {
    [M.AlignH.AlignH_Left] = "start",
    [M.AlignH.AlignH_Center] = "middle",
    [M.AlignH.AlignH_Right] = "end"
}
local AlignVMapping = {
    [M.AlignV.AlignV_Ascender] = "text-before-edge",
    [M.AlignV.AlignV_Top] = "hanging",
    [M.AlignV.AlignV_Middle] = "middle",
    [M.AlignV.AlignV_Baseline] = "alphabetic",
    [M.AlignV.AlignV_Bottom] = "text-after-edge",
    [M.AlignV.AlignV_Descender] = "text-after-edge",
}
local function getAlignString(shape)
    local alignH = AlignHMapping[shape.textAlign[1]]
    local alignV = AlignVMapping[shape.textAlign[2]]
    return string.format([[ text-anchor="%s" dominant-baseline="%s"]],
        alignH, alignV)
end

--- Mock only, not in-game: Generates an SVG image from the data provided to the renderer.
--
-- Known discrepancies from in-game behavior (tested in firefox):
-- <ul>
--   <li>Stroke is drawn centered on shape border instead of outside it (Polygons, Text).</li>
--   <li>Shadows are less vibrant.</li>
--   <li>Shadows are hidden by stroke (Boxes, Circle).</li>
--   <li>Default stroke width is narrower.</li>
--   <li>AlignV_Bottom is higher (equivalent to AlignV_Descender).</li>
--   <li>RefrigeratorDeluxe(-Light) is not available from google fonts and may not render properly if not installed.</li>
-- </ul>
-- @treturn string The SVG string.
function M:mockGenerateSvg()
    local svg = {}
    svg[#svg + 1] = string.format([[<svg viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">]],
        self.resolution.x, self.resolution.y)

    svg[#svg + 1] = [[    <defs>]]
    local clipPath
    for id, layer in pairs(self.layers) do
        clipPath = getClipPath(layer)
        if string.len(clipPath) > 0 then
            svg[#svg + 1] = string.format([[        <clipPath id="%slayer%d">%s</clipPath>]], self.prefix, id, clipPath)
        end
    end
    svg[#svg + 1] = [[    </defs>]]

    svg[#svg + 1] = string.format([[    <rect width="100%%" height="100%%" fill="%s" />]],
        colorToHex(table.unpack(self.backgroundColor, 1, 3)))

    local clipPathString, transformString, fillString, rotationString, shadowString, strokeString
    for id, layer in pairs(self.layers) do
        if layer.clipRect then
            clipPathString = string.format([[ clip-path="url(#%slayer%d)"]], self.prefix, id)
        else
            clipPathString = ""
        end
        transformString = getTransformString(layer)
        svg[#svg + 1] = string.format([[    <g stroke-linejoin="round" stroke-linecap="round"%s%s>]],
            clipPathString, transformString)

        if layer.image then
        end

        if layer.bezier then
            for _, shape in pairs(layer.bezier) do
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <path d="M %f %f Q %f %f %f %f" fill-opacity="0"%s%s />]],
                        shape.x1, shape.y1, shape.x2, shape.y2, shape.x3, shape.y3,
                        shadowString, strokeString)
            end
        end

        if layer.box then
            for _, shape in pairs(layer.box) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_Box)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <rect x="%f" y="%f" width="%f" height="%f"%s%s%s />]],
                        shape.x, shape.y, shape.width, shape.height,
                        fillString, rotationString, shadowString)
                if strokeString ~= "" then
                    svg[#svg + 1] =
                        string.format([[          <rect x="%f" y="%f" width="%f" height="%f" fill-opacity="0" rx="%f" ry="%f"%s%s />]],
                            shape.x - shape.strokeWidth / 2, shape.y - shape.strokeWidth / 2, shape.width + shape.strokeWidth,
                            shape.height + shape.strokeWidth, shape.strokeWidth / 2, shape.strokeWidth / 2,
                            rotationString, strokeString)
                end
            end
        end

        if layer.boxRounded then
            for _, shape in pairs(layer.boxRounded) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_BoxRounded)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <rect x="%f" y="%f" width="%f" height="%f" rx="%f" ry="%f"%s%s%s />]],
                        shape.x, shape.y, shape.width, shape.height, shape.radius, shape.radius,
                        fillString, rotationString, shadowString)
                if strokeString ~= "" then
                    svg[#svg + 1] =
                        string.format([[          <rect x="%f" y="%f" width="%f" height="%f" fill-opacity="0" rx="%f" ry="%f"%s%s />]],
                            shape.x - shape.strokeWidth / 2, shape.y - shape.strokeWidth / 2, shape.width + shape.strokeWidth,
                            shape.height + shape.strokeWidth, shape.radius + shape.strokeWidth / 2, shape.radius + shape.strokeWidth / 2,
                            rotationString, strokeString)
                end
            end
        end

        if layer.circle then
            for _, shape in pairs(layer.circle) do
                fillString = getFillString(shape)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <circle cx="%f" cy="%f" r="%f"%s%s />]],
                        shape.x, shape.y, shape.radius,
                        fillString, shadowString)
                if strokeString ~= "" then
                    svg[#svg + 1] =
                        string.format([[          <circle cx="%f" cy="%f" r="%f" fill-opacity="0"%s />]],
                            shape.x, shape.y, shape.radius + shape.strokeWidth / 2,
                            strokeString)
                end
            end
        end

        if layer.line then
            for _, shape in pairs(layer.line) do
                rotationString = getRotationString(shape, M.Shape.Shape_Line)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <line x1="%f" y1="%f" x2="%f" y2="%f"%s%s%s />]],
                        shape.x1, shape.y1, shape.x2, shape.y2,
                        rotationString, shadowString, strokeString)
            end
        end

        if layer.triangle then
            for _, shape in pairs(layer.triangle) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_Polygon)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <polygon points="%f,%f %f,%f %f,%f"%s%s%s%s />]],
                        shape.x1, shape.y1, shape.x2, shape.y2, shape.x3, shape.y3,
                        fillString, rotationString, shadowString, strokeString)
            end
        end

        if layer.quad then
            for _, shape in pairs(layer.quad) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_Polygon)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <polygon points="%f,%f %f,%f %f,%f %f,%f"%s%s%s%s />]],
                        shape.x1, shape.y1, shape.x2, shape.y2, shape.x3, shape.y3, shape.x4, shape.y4,
                        fillString, rotationString, shadowString, strokeString)
    end
        end

        if layer.text then
            for _, shape in pairs(layer.text) do
                fillString = getFillString(shape)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                local fontString = getFontString(shape)
                local alignString = getAlignString(shape)
                svg[#svg + 1] =
                    string.format([[        <text x="%f" y="%f" font-size="%f"%s%s%s%s%s>%s</text>]],
                        shape.x, shape.y, shape.size, fontString,
                        fillString, shadowString, strokeString, alignString,
                        shape.text)
            end
        end

        svg[#svg + 1] = "    </g>"
    end

    svg[#svg + 1] = "</svg>"
    return table.concat(svg, "\n")
end

-- Modified require based on: https://stackoverflow.com/a/45430931
local delim = package.config:match("^(.-)\n"):gsub("%%", "%%%%")

local function searchpath(name, path)
    local pname = name:gsub("%.", delim):gsub("%%", "%%%%")
    local msg = {}
    for subpath in path:gmatch("[^;]+") do
        local fpath = subpath:gsub("%?", pname)
        local f = io.open(fpath, "r")
        if f then
            f:close()
            return fpath
        end
        msg[#msg + 1] = "\n\tno file '" .. fpath .. "'"
    end
    return nil, table.concat(msg)
end

local function requireToEnvironment(modname, env)
    assert(type(modname) == "string")
    local filename, msg = searchpath(modname, package.path)
    if not filename then
        error(string.format("error loading module '%s':%s", modname, msg))
    end
    local mod, msg = loadfile(filename, "bt", env)
    if not mod then
        error(string.format("error loading module '%s' from file '%s':\n\t%s", modname, filename, msg))
    end
    return mod()
end

--- Mock only, not in-game: Bundles the object into an environment that can be used to override the base environment
-- (_ENV) so that all methods are called directly against this object. It is recommended that you store your current
-- environment reference prior to overriding it so that it can be restored.
-- @treturn table A table containing all calls available from within a screen render script.
function M:mockGetEnvironment()
    local environment = {}
    -- codex-documented methods
    -- Shapes
    environment.addBezier = function(layer, x1, y1, x2, y2, x3, y3) return self:addBezier(layer, x1, y1, x2, y2, x3, y3) end
    environment.addBox = function(layer, x, y, width, height) return self:addBox(layer, x, y, width, height) end
    environment.addBoxRounded = function(layer, x, y, width, height, radius) return self:addBoxRounded(layer, x, y, width, height, radius) end
    environment.addCircle = function(layer, x, y, radius) return self:addCircle(layer, x, y, radius) end
    environment.addImage = function(layer, image, x, y, width, height) return self:addImage(layer, image, x, y, width, height) end
    environment.addImageSub = function(layer, image, x, y, sx, xy, subX, xubY, subSx, subSy) return self:addImageSub(layer, image, x, y, sx, xy, subX, xubY, subSx, subSy) end
    environment.addLine = function(layer, x1, y1, x2, y2) return self:addLine(layer, x1, y1, x2, y2) end
    environment.addQuad = function(layer, x1, y1, x2, y2, x3, y3, x4, y4) return self:addQuad(layer, x1, y1, x2, y2, x3, y3, x4, y4) end
    environment.addText = function(layer, font, text, x, y) return self:addText(layer, font, text, x, y) end
    environment.addTriangle = function(layer, x1, y1, x2, y2, x3, y3) return self:addTriangle(layer, x1, y1, x2, y2, x3, y3) end
    -- Layers
    environment.createLayer = function() return self:createLayer() end
    environment.setLayerClipRect = function(layer, x, y, sx, sy) return self:setLayerClipRect(layer, x, y, sx, sy) end
    environment.setLayerOrigin = function(layer, x, y) return self:setLayerOrigin(layer, x, y) end
    environment.setLayerRotation = function(layer, rotation) return self:setLayerRotation(layer, rotation) end
    environment.setLayerScale = function(layer, sx, sy) return self:setLayerScale(layer, sx, sy) end
    environment.setLayerTranslation = function(layer, tx, ty) return self:setLayerTranslation(layer, tx, ty) end
    -- Screen State Functions
    environment.getCursor = function() return self:getCursor() end
    environment.getCursorDown = function() return self:getCursorDown() end
    environment.getCursorPressed = function() return self:getCursorPressed() end
    environment.getCursorReleased = function() return self:getCursorReleased() end
    environment.getDeltaTime = function() return self:getDeltaTime() end
    environment.getTime = function() return self:getTime() end
    environment.getLocale = function() return self:getLocale() end
    environment.getRenderCost = function() return self:getRenderCost() end
    environment.getRenderCostMax = function() return self:getRenderCostMax() end
    environment.getResolution = function() return self:getResolution() end
    environment.logMessage = function(message) return self:logMessage(message) end
    -- Loading References
    environment.loadImage = function(path) return self:loadImage(path) end
    environment.isImageLoaded = function(imageHandle) return self:isImageLoaded(imageHandle) end
    environment.getImageSize = function(image) return self:getImageSize(image) end
    environment.getAvailableFontCount = function() return self:getAvailableFontCount() end
    environment.getAvailableFontName = function(index) return self:getAvailableFontName(index) end
    environment.loadFont = function(name, size) return self:loadFont(name, size) end
    environment.isFontLoaded = function(font) return self:isFontLoaded(font) end
    environment.getTextBounds = function(font, text) return self:getTextBounds(font, text) end
    environment.getFontMetrics = function(font) return self:getFontMetrics(font) end
    environment.getFontSize = function(font) return self:getFontSize(font) end
    environment.setFontSize = function(font, size) return self:setFontSize(font, size) end
    -- Animation
    environment.requestAnimationFrame = function(frames) return self:requestAnimationFrame(frames) end
    -- Properties Defaults
    environment.setBackgroundColor = function(r, g, b) return self:setBackgroundColor(r, g, b) end
    environment.setDefaultFillColor = function(layer, shapeType, r, g, b, a) return self:setDefaultFillColor(layer, shapeType, r, g, b, a) end
    environment.setDefaultRotation = function(layer, shapeType, radians) return self:setDefaultRotation(layer, shapeType, radians) end
    environment.setDefaultShadow = function(layer, shapeType, radius, r, g, b, a) return self:setDefaultShadow(layer, shapeType, radius, r, g, b, a) end
    environment.setDefaultStrokeColor = function(layer, shapeType, r, g, b, a) return self:setDefaultStrokeColor(layer, shapeType, r, g, b, a) end
    environment.setDefaultStrokeWidth = function(layer, shapeType, width) return self:setDefaultStrokeWidth(layer, shapeType, width) end
    environment.setDefaultTextAlign = function(layer, alignH, alignV) return self:setDefaultTextAlign(layer, alignH, alignV) end
    -- Properties
    environment.setNextFillColor = function(layer, r, g, b, a) return self:setNextFillColor(layer, r, g, b, a) end
    environment.setNextRotation = function(layer, radians) return self:setNextRotation(layer, radians) end
    environment.setNextRotationDegrees = function(layer, degrees) return self:setNextRotationDegrees(layer, degrees) end
    environment.setNextShadow = function(layer, radius, r, g, b, a) return self:setNextShadow(layer, radius, r, g, b, a) end
    environment.setNextStrokeColor = function(layer, r, g, b, a) return self:setNextStrokeColor(layer, r, g, b, a) end
    environment.setNextStrokeWidth = function(layer, width) return self:setNextStrokeWidth(layer, width) end
    environment.setNextTextAlign = function(layer, alignH, alignV) return self:setNextTextAlign(layer, alignH, alignV) end
    -- Control Unit Interaction
    environment.getInput = function() return self:getInput() end
    environment.setOutput = function(outputString) return self:setOutput(outputString) end

    -- codex-documented tables
    environment._RSVERSION = 2
    for key, value in pairs(self.Shape) do
        environment[key] = value
    end
    for key, value in pairs(self.AlignH) do
        environment[key] = value
    end
    for key, value in pairs(self.AlignV) do
        environment[key] = value
    end

    -- other things carried over from the base environment
    -- strings
    environment._VERSION = "Lua 5.3"
    -- functions
    environment.next = _ENV.next
    environment.select = _ENV.select
    environment.pairs = _ENV.pairs
    environment.ipairs = _ENV.ipairs
    environment.type = _ENV.type
    environment.tostring = _ENV.tostring
    environment.tonumber = _ENV.tonumber
    environment.pcall = _ENV.pcall
    environment.xpcall = _ENV.xpcall
    environment.assert = _ENV.assert
    environment.error = _ENV.error
    environment.require = function(modname) return requireToEnvironment(modname, environment) end
    environment.load = _ENV.load
    environment.setmetatable = _ENV.setmetatable
    environment.getmetatable = _ENV.getmetatable
    environment.rawget = _ENV.rawget
    environment.rawset = _ENV.rawset
    environment.rawequal = _ENV.rawequal
    -- tables
    environment.table = _ENV.table
    environment.string = _ENV.string
    environment.math = _ENV.math

    return environment
end

return M
