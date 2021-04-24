--- The screen renderer handles the screen render script content, which can be set with @{ScreenUnit.setRenderScript}.
-- This is based on documentation originally posted on the forum in
-- <a href="https://board.dualthegame.com/index.php?/topic/22643-lua-screen-units-api-and-instructions/">this thread</a>.
--
-- @see ScreenUnit
-- @module ScreenRenderer
-- @alias M

-- define class fields
local M = {
    resolution = {
        x = 1024,
        y = 576,
    },
    renderCostMax = 4000000,
    maxLayers = 8,
}

function M:new(o)
    -- define default instance fields
    o = o or {
    }
    setmetatable(o, self)
    self.__index = self

    o.mouseX, o.mouseY = -1, -1
    o.deltaTime = 0.0
    o.renderCost = 589824

    o.layers = {}

    return o
end

--- Return the screen location that is currently raycasted by the player in screen pixel coordinates as a (x, y) tuple.
-- Returns (-1, -1) if the current raycasted location is not inside the screen.
-- @treturn float,float The mouse (x, y) in pixels.
function M:getCursor()
    return self.mouseX, self.mouseY
end

--- Returns the time, in seconds, since the screen was last updated. Useful for timing-based animations, since screens
-- are not guaranteed to be updated at any specific time interval, it is more reliable to update animations based on
-- this timer than based on a frame counter.
-- @treturn float Time since last refresh in seconds.
function M:getDeltaTime()
    return self.deltaTime
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

--- Create a new layer and return a handle to it that can be used by subsequent calls to the above add shapes. Layers
-- are rendered in the order in which they are created by the script, such that all shapes on layer N+1 will appear on
-- top of layer N. This results in the first created layer being the in the background and the last created layer will
-- be in the foreground.
-- @treturn int The handle to the newly created layer.
function M:createLayer()
    return 0
end

--- Return an image handle that can be used with @{addImage}. If the image is not yet loaded, a sentinel value will be
-- returned that will cause addImage to fail silently, so that the rendered image will not appear until it is loaded.
-- Only images that have gone through image validation are available.
-- @tparam string path The path to the image to load.
-- @treturn int The handle to the newly loaded image.
-- @see addImage
function M:loadImage(path)
    return 0
end

--- Return a font handle that can be used with @{addText}. If the font is not yet loaded, a sentinel value will be
-- returned that will cause addText to fail silently, so that the rendered text will not appear until the font is
-- loaded.
--
-- Name must be one of the following currently-available fonts:
-- <ul>
--   <li>Montserrat</li>
--   <li>Montserrat-Light</li>
--   <li>Montserrat-Bold</li>
--   <li>Play</li>
--   <li>Play-Bold</li>
--   <li>RefrigeratorDeluxe</li>
--   <li>RefrigeratorDeluxe-Light</li>
--   <li>RobotoCondensed</li>
-- </ul>
-- @tparam string name The name of the font to load, chosen from the above list.
-- @tparam float size The font size in vertical pixels.
-- @treturn int The handle to the newly loaded font.
-- @see addText
function M:loadFont(name, size)
    return 0
end

--- Add a rectangle to the given layer with top-left corner (x,y) and dimensions width by height.
--
-- Supported properties: @{setNextFillColor|fillColor}, @{setNextRotation|rotation},
-- @{setNextStrokeColor|strokeColor}, @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float x The x coordinate (in pixels) of the left side of the box.
-- @tparam float y The y coordinate (in pixels) of the top side of the box.
-- @tparam float width The width of the box in pixels.
-- @tparam float height The height of the box in pixels.
function M:addBox(layer, x, y, width, height)
end

--- Add a circle to the given layer with center (x, y) and radius radius.
--
-- Supported properties: @{setNextFillColor|fillColor}, @{setNextStrokeColor|strokeColor},
-- @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float x The x coordinate (in pixels) of the center of the circle.
-- @tparam float y The y coordinate (in pixels) of the center of the circle.
-- @tparam float radius The radius of the circle in pixels.
function M:addCircle(layer, x, y, radius)
end

--- Add image reference to layer as a rectangle with top-left corner x, y) and dimensions width x height.
--
-- Supported properties: @{setNextFillColor|fillColor}, @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
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
-- Supported properties: @{setNextRotation|rotation}, @{setNextStrokeColor|strokeColor},
-- @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float x1 The x coordinate (in pixels) of the start of the line.
-- @tparam float y1 The y coordinate (in pixels) of the start of the line.
-- @tparam float x2 The x coordinate (in pixels) of the end of the line.
-- @tparam float y2 The y coordinate (in pixels) of the end of the line.
function M:addLine(layer, x1, y1, x2, y2)
end

--- Add a quadrilateral to the given layer with vertices (x1, y1), (x2, y2), (x3, y3), (x4, y4).
--
-- Supported properties: @{setNextFillColor|fillColor}, @{setNextRotation|rotation},
-- @{setNextStrokeColor|strokeColor}, @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
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
-- Supported properties: @{setNextFillColor|fillColor}
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam int font The handle for the font to use for the text.
-- @tparam string text The text to add.
-- @tparam float x The x coordinate (in pixels) of the top-left baseline.
-- @tparam float y The y coordinate (in pixels) of the top-left baseline.
-- @see loadFont
function M:addText(layer, font, text, x, y)
end

--- Add a triangle to the given layer with vertices (x1, y1), (x2, y2), (x3, y3).
--
-- Supported properties: @{setNextFillColor|fillColor}, @{setNextRotation|rotation},
-- @{setNextStrokeColor|strokeColor}, @{setNextStrokeWidth|strokeWidth}
-- @tparam int layer The handle for the layer to apply this property to.
-- @tparam float x1 The x coordinate (in pixels) of the first corner.
-- @tparam float y1 The y coordinate (in pixels) of the first corner.
-- @tparam float x2 The x coordinate (in pixels) of the second corner.
-- @tparam float y2 The y coordinate (in pixels) of the second corner.
-- @tparam float x3 The x coordinate (in pixels) of the third corner.
-- @tparam float y3 The y coordinate (in pixels) of the third corner.
function M:addTriangle(layer, x1, y1, x2, y2, x3, y3)
end

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

--- Notify the screen manager that this screen should be redrawn in frames frames. A screen that requires highly-fluid
-- animations should thus call requestAnimationFrame(1) before it returns.
--
-- Usage of this function has an obvious and significant performance impact on the screen unit system. Scripts should
-- try to request updates as infrequently as possible for their application. <u>A screen with unchanging (static)
-- contents should not call this function at all.</u>
-- @tparam int frames The number of frames to wait before redrawing the screen.
function M:requestAnimationFrame(frames)
end

--- Mock only, not in-game: Bundles the object into an environment that can be used to override the base environment
-- (_ENV) so that all methods are called directly against this object. It is recommended that you store your current
-- environment reference prior to overriding it so that it can be restored.
-- @treturn table A table containing all calls available from within a screen render script.
function M:mockGetEnvironment()
    local environment = {}
    -- codex-documented methods
    environment.getCursor = function() return self:getCursor() end
    environment.getDeltaTime = function() return self:getDeltaTime() end
    environment.getRenderCost = function() return self:getRenderCost() end
    environment.getRenderCostMax = function() return self:getRenderCostMax() end
    environment.getResolution = function() return self:getResolution() end
    environment.createLayer = function() return self:createLayer() end
    environment.loadImage = function(path) return self:loadImage(path) end
    environment.loadFont = function(name, size) return self:loadFont(name, size) end
    environment.addBox = function(layer, x, y, width, height) return self:addBox(layer, x, y, width, height) end
    environment.addCircle = function(layer, x, y, radius) return self:addCircle(layer, x, y, radius) end
    environment.addImage = function(layer, image, x, y, width, height) return self:addImage(layer, image, x, y, width, height) end
    environment.addLine = function(layer, x1, y1, x2, y2) return self:addLine(layer, x1, y1, x2, y2) end
    environment.addQuad = function(layer, x1, y1, x2, y2, x3, y3, x4, y4) return self:addQuad(layer, x1, y1, x2, y2, x3, y3, x4, y4) end
    environment.addText = function(layer, font, text, x, y) return self:addText(layer, font, text, x, y) end
    environment.addTriangle = function(layer, x1, y1, x2, y2, x3, y3) return self:addTriangle(layer, x1, y1, x2, y2, x3, y3) end
    environment.setNextFillColor = function(layer, r, g, b, a) return self:setNextFillColor(layer, r, g, b, a) end
    environment.setNextRotation = function(layer, radians) return self:setNextRotation(layer, radians) end
    environment.setNextRotationDegrees = function(layer, degrees) return self:setNextRotationDegrees(layer, degrees) end
    environment.setNextStrokeColor = function(layer, r, g, b, a) return self:setNextStrokeColor(layer, r, g, b, a) end
    environment.setNextStrokeWidth = function(layer, width) return self:setNextStrokeWidth(layer, width) end
    environment.requestAnimationFrame = function(frames) return self:requestAnimationFrame(frames) end

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
    -- tables
    environment.table = _ENV.table
    environment.string = _ENV.table
    environment.math = _ENV.math

    return environment
end

return M
