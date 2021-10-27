--- RenderScript is a new technology for creating screen unit contents using Lua (also referred to as "Lua Screen
-- Units"), rather than HTML/CSS. In general, this technology causes less performance drops in the game, while
-- simultaneously allowing significantly more complex animaged and interactive screens.
--
-- Render scripts are Lua scripts residing inside screen units that provide rendering instructions for the screen. To
-- use RenderScript, simply switch the screen mode from 'HTML' to 'Lua' in the screen unit content editor interface,
-- then start writing a render script! Render scripts work by building up layers of geometric shapes, images, and text,
-- that are then rendered sequentially to the screen.
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
-- Additional funcionality is provided in the rslib.lua library in your Dual Universe\Game\data\lua directory,
-- accessible by calling <code>local rslib = require('rslib')</code>.
--
-- @see ScreenUnit.setRenderScript
-- @module ScreenRenderer
-- @alias M

-- define class fields
local M = {
    resolution = {
        x = 1024,
        y = 576,
    },
    renderCostMax = 4000000,
}

--- Shape constants for shapeType. Used to set default properties by shape.
--
-- Note: These are constants defined directly in the screen renderer, the grouping in a table is for documentation
-- purposes only.
-- @table Shape
M.Shape = {
    Shape_Box = 0,
    Shape_BoxRounded = 1,
    Shape_Circle = 2,
    Shape_Image = 3,
    Shape_Line = 4,
    Shape_Polygon = 5,
    Shape_Text = 6,
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

    o.input = ""
    o.output = ""

    return o
end

-- ------ --
-- Shapes --
-- ------ --

--- Add a rectangle to the given layer with top-left corner (x,y) and dimensions width x height.
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
-- @tparam float x The x coordinate (in pixels) of the left side of the box.
-- @tparam float y The y coordinate (in pixels) of the top side of the box.
-- @tparam float width The width of the box in pixels.
-- @tparam float height The height of the box in pixels.
function M:addBox(layer, x, y, width, height)
end

--- Add a rectangle to the given layer with top-left corner (x,y) and dimensions width x height with each corner
-- rounded to radius.
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
-- @tparam float x The x coordinate (in pixels) of the left side of the box.
-- @tparam float y The y coordinate (in pixels) of the top side of the box.
-- @tparam float width The width of the box in pixels.
-- @tparam float height The height of the box in pixels.
-- @tparam float radius The corner radius of the box in pixels.
function M:addBoxRounded(layer, x, y, width, height, radius)
end

--- Add a circle to the given layer with center (x, y) and radius radius.
--
-- Supported properties: fillColor, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
-- @tparam float x The x coordinate (in pixels) of the center of the circle.
-- @tparam float y The y coordinate (in pixels) of the center of the circle.
-- @tparam float radius The radius of the circle in pixels.
function M:addCircle(layer, x, y, radius)
end

--- Add image reference to layer as a rectangle with top-left corner x, y) and dimensions width x height.
--
-- Supported properties: fillColor, rotation
-- @tparam int layer The handle for the layer to add this shape to.
-- @tparam int image The handle for the image to add.
-- @tparam float x The x coordinate (in pixels) of the left side of the image.
-- @tparam float y The y coordinate (in pixels) of the top side of the image.
-- @tparam float width The width of the image in pixels.
-- @tparam float height The height of the image in pixels.
-- @see loadImage
function M:addImage(layer, image, x, y, width, height)
end

--- Add a line to layer from (x1, y1) to (x2, y2).
--
-- Supported properties: rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
-- @tparam float x1 The x coordinate (in pixels) of the start of the line.
-- @tparam float y1 The y coordinate (in pixels) of the start of the line.
-- @tparam float x2 The x coordinate (in pixels) of the end of the line.
-- @tparam float y2 The y coordinate (in pixels) of the end of the line.
function M:addLine(layer, x1, y1, x2, y2)
end

--- Add a quadrilateral to the given layer with vertices (x1, y1), (x2, y2), (x3, y3), (x4, y4).
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
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
-- @tparam int layer The handle for the layer to add this text to.
-- @tparam int font The handle for the font to use for the text.
-- @tparam string text The text to add.
-- @tparam float x The x coordinate (in pixels) of the top-left baseline.
-- @tparam float y The y coordinate (in pixels) of the top-left baseline.
-- @see loadFont
function M:addText(layer, font, text, x, y)
end

--- Add a triangle to the given layer with vertices (x1, y1), (x2, y2), (x3, y3).
--
-- Supported properties: fillColor, rotation, shadow, strokeColor, strokeWidth
-- @tparam int layer The handle for the layer to add this shape to.
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

--- Create a new layer and return a handle to it that can be used by subsequent calls to the above add shapes. Layers
-- are rendered in the order in which they are created by the script, such that all shapes on layer N+1 will appear on
-- top of layer N. This results in the first created layer being the in the background and the last created layer will
-- be in the foreground.
-- @treturn int The handle to the newly created layer.
function M:createLayer()
    return 0
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
-- @tparam float size The font size in vertical pixels.
-- @treturn int The handle to the newly loaded font.
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
-- @tparam int font A font handle provided by load font.
-- @treturn float,float The font metrics as (ascender height, descender height) in pixels.
-- @see loadFont
function M:getFontMetrics(font)
    return 0.0, 0.0
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
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
function M:setBackgroundColor(r, g, b)
end

--- Set the default fill color for all shapeType on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the fillColor property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
-- @see Shape
function M:setDefaultFillColor(layer, shapeType, r, g, b, a)
end

--- Set the default rotation for all shapeType on layer. Rotation is specified in CCW radians radians. Has no effect
-- on shapes that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam float radians The angle (in radians) to rotate by.
-- @see Shape
function M:setDefaultRotation(layer, shapeType, radians)
end

--- Set the default shadow for all shapeType on layer with size radius. Red (r), green (g), blue (b), and alpha (a)
-- components are specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the shadow
-- property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam float radius The radius of the shadow.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
-- @see Shape
function M:setDefaultShadow(layer, shapeType, radius, r, g, b, a)
end

--- Set the default stroke color for all shapeType on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the strokeColor property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
-- @see Shape
function M:setDefaultStrokeColor(layer, shapeType, r, g, b, a)
end

--- Set the default stroke width for all shapeType on layer. Width is specified in pixels. Positive values produce an
-- outer stroke, while negative values produce an inner stroke. Has no effect on shapes that don't support the
-- strokeWidth property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int shapeType The shape to apply this default to. Must be a built in constant from @{Shape}.
-- @tparam float width The width of the stroke in pixels.
-- @see Shape
function M:setDefaultStrokeWidth(layer, shapeType, width)
end

-- ---------- --
-- Properties --
-- ---------- --

--- Set the fill color of the next rendered shape on layer. Red (r), green (g), blue (b), and alpha (a) components are
-- specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the fillColor property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
function M:setNextFillColor(layer, r, g, b, a)
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW radians. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float radians The angle (in radians) to rotate by.
-- @see setNextRotationDegrees
function M:setNextRotation(layer, radians)
end

--- Set the rotation of the next rendered shape on layer. Rotation is specified in CCW degrees. Has no effect on shapes
-- that don't support the rotation property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float degrees The angle (in degrees) to rotate by.
-- @see setNextRotation
function M:setNextRotationDegrees(layer, degrees)
end

--- Set the shadow of the next rendered shape on layer with size radius. Red (r), green (g), blue (b), and alpha (a)
-- components are specified, respectively, in the range [0, 1]. Has no effect on shapes that don't support the shadow
-- property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float radius The radius of the shadow.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
function M:setNextShadow(layer, radius, r, g, b, a)
end

--- Set the stroke color of the next rendered shape on layer. Red (r), green (g), blue (b), and alpha (a) components
-- are specified, respectively, in the range [0, 1].
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam [0,1] r The red component value.
-- @tparam [0,1] g The green component value.
-- @tparam [0,1] b The blue component value.
-- @tparam [0,1] a The alpha component value.
function M:setNextStrokeColor(layer, r, g, b, a)
end

--- Set the stroke width of the next rendered shape on layer. Width is specified in pixels. Positive values produce an
-- outer stroke, while negative values produce an inner stroke. Has no effect on shapes that don't support the
-- strokeWidth property.
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float width The width of the stroke in pixels.
function M:setNextStrokeWidth(layer, width)
end

--- Set the next text alignment for the next rendered shape on layer.
--
-- Note that there is a subtle difference between AlignV_Ascender/AlignV_Descender and AlignV_Top/AlignV_Bottom: the
-- ascender and descender alignment modes anchor a text string to a global top/bottom position of the font, while the
-- top and bottom alignment modes anchor a text string relative to its own bounding box. Thus, while top/bottom are
-- useful for aligning individual text strings with high precision, they depend on the contents of the text string that
-- is rendered. On the other hand, ascender/descender align text in such a way that the alignment will not change
-- depending on the text string. The correct choice will depend on your specific use case and needs.
-- @tparam int layer The handle for the layer to apply this property to.
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

--- Mock only, not in-game: Bundles the object into an environment that can be used to override the base environment
-- (_ENV) so that all methods are called directly against this object. It is recommended that you store your current
-- environment reference prior to overriding it so that it can be restored.
-- @treturn table A table containing all calls available from within a screen render script.
function M:mockGetEnvironment()
    local environment = {}
    -- codex-documented methods
    -- Shapes
    environment.addBox = function(layer, x, y, width, height) return self:addBox(layer, x, y, width, height) end
    environment.addBoxRounded = function(layer, x, y, width, height, radius) return self:addBoxRounded(layer, x, y, width, height, radius) end
    environment.addCircle = function(layer, x, y, radius) return self:addCircle(layer, x, y, radius) end
    environment.addImage = function(layer, image, x, y, width, height) return self:addImage(layer, image, x, y, width, height) end
    environment.addLine = function(layer, x1, y1, x2, y2) return self:addLine(layer, x1, y1, x2, y2) end
    environment.addQuad = function(layer, x1, y1, x2, y2, x3, y3, x4, y4) return self:addQuad(layer, x1, y1, x2, y2, x3, y3, x4, y4) end
    environment.addText = function(layer, font, text, x, y) return self:addText(layer, font, text, x, y) end
    environment.addTriangle = function(layer, x1, y1, x2, y2, x3, y3) return self:addTriangle(layer, x1, y1, x2, y2, x3, y3) end
    -- Layers
    environment.createLayer = function() return self:createLayer() end
    -- Screen State Functions
    environment.getCursor = function() return self:getCursor() end
    environment.getCursorDown = function() return self:getCursorDown() end
    environment.getCursorPressed = function() return self:getCursorPressed() end
    environment.getCursorReleased = function() return self:getCursorReleased() end
    environment.getDeltaTime = function() return self:getDeltaTime() end
    environment.getTime = function() return self:getTime() end
    environment.getRenderCost = function() return self:getRenderCost() end
    environment.getRenderCostMax = function() return self:getRenderCostMax() end
    environment.getResolution = function() return self:getResolution() end
    environment.logMessage = function(message) return self:logMessage(message) end
    -- Loading References
    environment.loadImage = function(path) return self:loadImage(path) end
    environment.isImageLoaded = function(imageHandle) return self:isImageLoaded(imageHandle) end
    environment.getAvailableFontCount = function() return self:getAvailableFontCount() end
    environment.getAvailableFontName = function(index) return self:getAvailableFontName(index) end
    environment.loadFont = function(name, size) return self:loadFont(name, size) end
    environment.isFontLoaded = function(font) return self:isFontLoaded(font) end
    environment.getTextBounds = function(font, text) return self:getTextBounds(font, text) end
    environment.getFontMetrics = function(font) return self:getFontMetrics(font) end
    -- Animation
    environment.requestAnimationFrame = function(frames) return self:requestAnimationFrame(frames) end
    -- Properties Defaults
    environment.setBackgroundColor = function(r, g, b) return self:setBackgroundColor(r, g, b) end
    environment.setDefaultFillColor = function(layer, shapeType, r, g, b, a) return self:setDefaultFillColor(layer, shapeType, r, g, b, a) end
    environment.setDefaultRotation = function(layer, shapeType, radians) return self:setDefaultRotation(layer, shapeType, radians) end
    environment.setDefaultShadow = function(layer, shapeType, radius, r, g, b, a) return self:setDefaultShadow(layer, shapeType, radius, r, g, b, a) end
    environment.setDefaultStrokeColor = function(layer, shapeType, r, g, b, a) return self:setDefaultStrokeColor(layer, shapeType, r, g, b, a) end
    environment.setDefaultStrokeWidth = function(layer, shapeType, width) return self:setDefaultStrokeWidth(layer, shapeType, width) end
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
