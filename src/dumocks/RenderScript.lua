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
    resolution = {
        x = 1024,
        y = 613,
    },
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
    Shape_Polygon = 6,
    Shape_Text = 7,
}

--- Horizontal alignment constants for alignH. Used by @{setNextTextAlign}.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table AlignH
M.AlignH = {
    AlignH_Left = 0,
    AlignH_Center = 1,
    AlignH_Right = 2,
}
--- Vertical alignment constants for alignV. Used by @{setNextTextAlign}.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table AlignV
M.AlignV = {
    AlignV_Ascender = 0,
    AlignV_Top = 1,
    AlignV_Middle = 2,
    AlignV_Baseline = 3,
    AlignV_Bottom = 4,
    AlignV_Descender = 5,
}

function M:new(o)
    -- define default instance fields
    o = o or {
    }
    setmetatable(o, self)
    self.__index = self

    o.mouseX, o.mouseY = -1, -1
    o.cursorDown, o.cursorPressed, o.cursorReleased = false, false, false
    o.deltaTime = 0.0
    o.renderCost = 589824

    o.layers = {}
    o.backgroundColor = {0, 0, 0}

    o.locale = "en-US"
    o.input = ""
    o.output = ""

    return o
end

-- ---------------- --
-- Helper Functions --
-- ---------------- --

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
        layer[property.next] = nil
    elseif layer[property.default][shapeType] then
        value = layer[property.default][shapeType]
    else
        value = property.missing
    end

    return value
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
    local layerRef = getLayer(self, layer)
    if not layerRef.box then
        layerRef.box = {}
    end
    local layerShape = layerRef.box

    layerShape[#layerShape + 1] = {
        x = x,
        y = y,
        width = width,
        height = height,
        fillColor = getPropertyValue(layerRef, Property.FillColor, M.Shape.Shape_Box),
        rotation = getPropertyValue(layerRef, Property.Rotation, M.Shape.Shape_Box),
        shadow = getPropertyValue(layerRef, Property.Shadow, M.Shape.Shape_Box),
        strokeColor = getPropertyValue(layerRef, Property.StrokeColor, M.Shape.Shape_Box),
        strokeWidth = getPropertyValue(layerRef, Property.StrokeWidth, M.Shape.Shape_Box)
    }
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
end

--- Add a circle to the given layer with center (x, y) and radius radius.
--
-- Supported properties: fillColor, shadow, strokeColor, strokeWidth
-- @tparam int layer The id of the layer to which to add.
-- @tparam float x The x coordinate (in pixels) of the center of the circle.
-- @tparam float y The y coordinate (in pixels) of the center of the circle.
-- @tparam float radius The radius of the circle in pixels.
function M:addCircle(layer, x, y, radius)
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
end

--- Add text to layer using font, with top-left baseline starting at (x, y). Note that each glyph in text counts as one
-- shape toward the total rendered shape limit.
--
-- Supported properties: fillColor
-- @tparam int layer The id of the layer to which to add.
-- @tparam int font The id of the font to use.
-- @tparam string text The text to add.
-- @tparam float x The x coordinate (in pixels) of the top-left baseline.
-- @tparam float y The y coordinate (in pixels) of the top-left baseline.
-- @see loadFont
function M:addText(layer, font, text, x, y)
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
        defaultStrokeWidth = {}
    }
    return #self.layers
end

--- Set a clipping rectangle applied to the layer as a whole. Layer contents that fall outside the clipping rectangle
-- will not be rendered, and those athat are partially within the rectangle will be 'clipped' against it. The clipping
-- rectangle is applied before layer transformations. Note that clipped contents still count toward the render cost.
-- @tparam int layer The id of the layer for which the clipping rectangle will be set.
-- @tparam float x The X coordinate of the clipping rectangle's top-left corner.
-- @tparam float y The Y coordinate of the clipping rectangle's top-left corner.
-- @tparam float sx The width of the clipping rectangle.
-- @tparam float sy The height of the clipping rectangle.
function M:setLayerClipRect(layer, x, y, sx, sy)
end

--- Set the transform origin of a layer; layer scaling and rotation are applied relative to this origin.
-- @tparam int layer The id of the layer for which the origin will be set.
-- @tparam float x The X coordinate of the layer's transform origin.
-- @tparam float y The Y coordinate of the layer's transform origin.
function M:setLayerOrigin(layer, x, y)
end

--- Set a rotation applied to the layer as a whole, relative to the layer's transform origin.
-- @tparam int layer The id of the layer for which the rotation will be set.
-- @tparam float rotation Rotation, in radians; positive is counter-clockwise, negative is clockwise.
function M:setLayerRotation(layer, rotation)
end

--- Set a scale factor applied to the layer as a whole, relative to the layer's transform origin. Scale factors are
-- multiplicative, so that a scale >1 enlarges the size of the layer, 1.0 does nothing, and <1 reduces the size of the
-- layer.
-- @tparam int layer The id of the layer for which the scale factor will be set.
-- @tparam float sx The scale factor along the X axis.
-- @tparam float sy The scale factor along the Y axis.
function M:setLayerScale(layer, sx, sy)
end

--- Set a translation applied to the layer as a whole.
-- @tparam int layer The id of the layer for which the translation will be set.
-- @tparam float tx The translation along the X axis.
-- @tparam float ty The translation along the Y axis.
function M:setLayerTranslation(layer, tx, ty)
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
    if system and type(system.print) == "function" then
        system.print(message)
    else
        print(message)
    end
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
    return 0
end

--- Returns true if the given imageHandle is loaded.
-- @tparam int imageHandle An image handle provided by loadImage.
-- @treturn boolean True if loaded, false otherwise.
-- @see loadImage
function M:isImageLoaded(imageHandle)
    return false
end

--- Returns the width and height of an image.
-- @tparam int image The id of the image to query.
-- @treturn float,float A tuple containing the width and height, respectively, of the image, or (0, 0) if the image is
--   not yet loaded.
function M:getImageSize(image)
    return {0, 0}
end

--- Returns the number of fonts available to be used by render script.
-- @treturn int The total number of fonts available.
function M:getAvailableFontCount()
    return 12
end

--- Returns the name of the nth available font.
-- @tparam int index A number between 1 and the return value of @{getAvailableFontCount}.
-- @treturn string The name of the font, which can be used with the @{loadFont} function.
function M:getAvailableFontName(index)
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
--   <li>Montserrat-Light</li>
--   <li>Montserrat-Bold</li>
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
    return 0
end

--- <b>Deprecated:</b> Returns true if the given font is loaded.
-- @tparam int font A font handle provided by load font.
-- @treturn boolean True if loaded, false otherwise.
-- @see loadFont
function M:isFontLoaded(font)
    return false
end

--- Compute and return the bounding box width and height of the given text in the given font as a (width, height)
-- tuple.
-- @tparam int font A font handle provided by load font.
-- @tparam string text The text to calculate bounds for.
-- @treturn float,float The text bounds as (width, height) in pixels.
-- @see loadFont
function M:getTextBounds(font, text)
    return 0.0, 0.0
end

--- Compute and return the ascender and descender height of given font.
-- @tparam int font The id of the font to query.
-- @treturn float,float A tuple containing the maximal ascender and descender, respectively, of the given font.
-- @see loadFont
function M:getFontMetrics(font)
    return 0.0, 0.0
end

--- Return the currently-set size for the given font.
-- @tparam int font The id of the font to query.
-- @treturn float The font size in vertical pixels.
function M:getFontSize(font)
    return 10
end

--- Set the size at which a font will render. Impacts all subsequent font-related calls, including @{addText}, @{getFontMetrics}, and @{getTextBounds}.
-- @tparam int font The id of the font for which the size will be set.
-- @tparam int size The new size, in vertical pixels, at which the font will render.
function M:setFontSize(font, size)
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
end

-- ------------------- --
-- Properties Defaults --
-- ------------------- --

--- Set the background color of the screen as red (r), green (g), blue (b) in the range [0, 1].
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
function M:setBackgroundColor(r, g, b)
    self.backgroundColor = {r, g, b}
end

--- Set the default fill color for all shapeType on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the fillColor property.
-- Does not retroactively apply to already added shapes.
-- @tparam int layer The id of the layer for which the default will be set.
-- @tparam int shapeType The type of @{Shape} to which the default will apply.
-- @tparam float r The red component, between 0 and 1.
-- @tparam float g The green component, between 0 and 1.
-- @tparam float b The blue component, between 0 and 1.
-- @tparam float a The alpha component, between 0 and 1.
-- @see Shape
function M:setDefaultFillColor(layer, shapeType, r, g, b, a)
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
    local layerRef = getLayer(self, layer)
    layerRef.nextFillColor = {r, g, b, a}
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW radians. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float radians The angle (in radians) to rotate by.
-- @see setNextRotationDegrees
function M:setNextRotation(layer, radians)
    local layerRef = getLayer(self, layer)
    layerRef.nextRotation = math.deg(radians)
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW degrees. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float degrees The angle (in degrees) to rotate by.
-- @see setNextRotation
function M:setNextRotationDegrees(layer, degrees)
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
    local layerRef = getLayer(self, layer)
    layerRef.nextStrokeColor = {r, g, b, a}
end

--- Set the stroke width of the next rendered shape on layer. Width is specified in pixels. Positive values produce an
-- outer stroke, while negative values produce an inner stroke. Has no effect on shapes that don't support the
-- strokeWidth property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float width The width of the stroke in pixels.
function M:setNextStrokeWidth(layer, width)
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

-- ---------------------- --
-- Undocumented Functions --
-- ---------------------- --

--- Unknown use.
--
-- Note: This method is not documented in the codex.
function M:rawget()
end

--- Unknown use.
--
-- Note: This method is not documented in the codex.
function M:rawset()
end

--- Unknown use.
--
-- Note: This method is not documented in the codex.
function M:rawequal()
end

local function colorToHex(r, g, b, a)
    local alpha = ""
    if a then
        alpha = string.format("%02x", math.floor(a * 255))
    end

    return string.format("#%02x%02x%02x%s", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), alpha)
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

    if strokeWidth <= 0 then
        return ""
    end

    local opacity = ""
    if strokeColor[4] < 1.0 then
        opacity = string.format([[ stroke-opacity="%f"]], strokeColor[4])
    end

    return string.format([[ stroke-width="%f" stroke="%s"%s]],
        strokeWidth, colorToHex(table.unpack(strokeColor, 1, 3)), opacity)
end

--- Mock only, not in-game: Generates an SVG image from the data provided to the renderer.
-- @treturn string The SVG string.
function M:mockGenerateSvg()
    local svg = {}
    svg[#svg + 1] = string.format([[<svg viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">]], self.resolution.x, self.resolution.y)

    svg[#svg + 1] = string.format([[    <rect width="100%%" height="100%%" fill="%s" />]],
        colorToHex(table.unpack(self.backgroundColor, 1, 3)))

    local fillString, rotationString, shadowString, strokeString
    for _, layer in pairs(self.layers) do
        svg[#svg + 1] = [[    <g stroke-linejoin="round">]]

        if layer.box then
            for _, shape in pairs(layer.box) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_Box)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <rect x="%f" y="%f" width="%f" height="%f"%s%s%s%s />]],
                        shape.x, shape.y, shape.width, shape.height,
                        fillString, rotationString, shadowString, strokeString)
            end
        end

        if layer.boxRounded then
            for _, shape in pairs(layer.boxRounded) do
                fillString = getFillString(shape)
                rotationString = getRotationString(shape, M.Shape.Shape_BoxRounded)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <rect x="%f" y="%f" width="%f" height="%f" rx="%f" ry="%f"%s%s%s%s />]],
                        shape.x, shape.y, shape.width, shape.height, shape.radius, shape.radius,
                        fillString, rotationString, shadowString, strokeString)
            end
        end

        if layer.circle then
            for _, shape in pairs(layer.circle) do
                fillString = getFillString(shape)
                shadowString = getShadowString(shape)
                strokeString = getStrokeString(shape)
                svg[#svg + 1] =
                    string.format([[        <circle cx="%f" cy="%f" r="%f"%s%s%s />]],
                        shape.x, shape.y, shape.radius,
                        fillString, shadowString, strokeString)
            end
        end

        svg[#svg + 1] = "    </g>"
    end

    svg[#svg + 1] = "</svg>"
    return table.concat(svg, "\n")
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
    -- Undocumented Functions
    environment.rawget = function() return self:rawget() end
    environment.rawset = function() return self:rawset() end
    environment.rawequal = function() return self:rawequal() end

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
    environment.require = _ENV.require
    environment.load = _ENV.load
    environment.setmetatable = _ENV.setmetatable
    environment.getmetatable = _ENV.getmetatable
    -- tables
    environment.table = _ENV.table
    environment.string = _ENV.string
    environment.math = _ENV.math

    return environment
end

return M
