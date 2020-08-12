--- Screen unit.
-- Screen units can display any HTML code or text message, and you can use them to create visually interactive feedback
-- for your running Lua script by connecting one or more of them to your control unit.
-- @module MockScreenUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {}
elementDefinitions["screen xs"] = {mass = 18.67, maxHitPoints = 50.0}
-- TODO others
local DEFAULT_ELEMENT = "screen xs"

local M = MockElement:new()
M.elementClass = "ScreenUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self



    return o
end

--- Displays the given text at the given coordinates in the screen, and returns an ID to move it later.
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam 0..100 fontSize Text font size, as a percentage of the screen width.
-- @tparam string text The text to display.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addText(x, y, fontSize, text)
end

--- Displays the given text centered in the screen with a font to maximize its visibility.
-- @tparam string text The text to display.
function M:setCenteredText(text)
end

--- Set the whole screen HTML content (overrides anything already set).
-- @tparam html html The HTML content to display.
function M:setHTML(html)
end

--- Displays the given HTML content at the given coordinates in the screen, and returns an ID to move it later.
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam html html The HTML content to display, which can contain SVG elements to make drawings.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addContent(x, y, html)
end

--- Displays SVG code (anything that fits within a <svg> section), which overrides any preexisting content.
-- @tparam svg svg The SVG content to display, which fits inside a 1920x1080 canvas.
function M:setSVG(svg)
end

--- Update the element with the given ID (returned by setContent) with a new HTML content.
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
-- @tparam html html The HTML content to display, which can contain SVG elements to make drawings.
function M:resetContent(id, html)
end

--- Delete the element with the given ID (returned by setContent).
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
function M:deleteContent(id)
end

--- Update the visibility of the element with the given ID (returned by setContent).
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
-- @tparam 0/1 state 0 = invisible, 1 = visible.
function M:showContent(id, state)
end

--- Move the element with the given id (returned by setContent) to a new position in the screen.
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- that you can store to use later here.
function M:moveContent(id, x, y)
end

--- Returns the x-coordinate of the position pointed at in the screen.
-- @treturn 0..1 The x-position as a percentage of screen width; -1 if nothing is pointed at.
function M:getMouseX()
end

--- Returns the y-coordinate of the position pointed at in the screen.
-- @treturn 0..1 The y-position as a percentage of screen height; -1 if nothing is pointed at.
function M:getMouseY()
end

--- Returns the state of the mouse click.
-- @treturn 0/1 0 when the mouse is not clicked and 1 otherwise.
function M:getMouseState()
end

--- Clear the screen.
function M:clear()
end

--- Event: Emitted when the player starts a click on the screen unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam 0..1 x X-coordinate of the click in percentage of the screen width.
-- @tparam 0..1 y Y-coordinate of the click in percentage of the screen height.
function M.EVENT_mouseDown(x, y)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the player releases a click on the screen unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam 0..1 x X-coordinate of the click in percentage of the screen width.
-- @tparam 0..1 y Y-coordinate of the click in percentage of the screen height.
function M.EVENT_mouseUp(x, y)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see MockElement:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.addText = function(x, y, fontSize, text) return self:addText(x, y, fontSize, text) end
    closure.setCenteredText = function(text) return self:setCenteredText(text) end
    closure.setHTML = function(html) return self:setHTML(html) end
    closure.setSVG = function(svg) return self:setSVG(svg) end
    closure.resetContent = function(id, html) return self:resetContent(id, html) end
    closure.deleteContent = function(id) return self:deleteContent(id) end
    closure.showContent = function(id, state) return self:showContent(id, state) end
    closure.moveContent = function(id, x, y) return self:moveContent(id, x, y) end
    closure.getMouseX = function() return self:getMouseX() end
    closure.getMouseY = function() return self:getMouseY() end
    closure.getMouseState = function() return self:getMouseState() end
    closure.clear = function() return self:clear() end
    return closure
end

return M