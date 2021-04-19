--- Screen units can display any HTML code or text message, and you can use them to create visually interactive feedback
-- for your running Lua script by connecting one or more of them to your control unit.
--
-- Element class:
-- <ul>
--   <li>ScreenUnit: Basic and transparent screens</li>
--   <li>ScreenSignUnit: Signs</li>
-- </ul>
--
-- Note: The max size of screen content is 50,000 characters. Any calls to set or add content that result in the screen
-- exceeding this will silently fail.
--
-- Extends: Element &gt; ElementWithState &gt; ElementWithToggle
-- @see Element
-- @see ElementWithState
-- @see ElementWithToggle
-- @module ScreenUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["screen xs"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["screen s"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["screen m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["screen xl"] = {mass = 12810.88, maxHitPoints = 28116.0, class = "ScreenUnit"}
elementDefinitions["transparent screen xs"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["transparent screen s"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["transparent screen m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["transparent screen l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit"}
elementDefinitions["sign xs"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["sign s"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["sign m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["sign l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["vertical sign xs"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["vertical sign m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
elementDefinitions["vertical sign l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit"}
local DEFAULT_ELEMENT = "screen xs"

local M = MockElementWithToggle:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.html = "" -- this is the displayed content, for use in checking what's on the screen

    o.directHtml = "" -- this is html set through setHTML, used as the foundation for building self.html
    o.contentList = {}
    o.contentNextIndex = 1

    o.mouseX = -1
    o.mouseY = -1
    o.mouseState = false

    o.plugIn = 0.0

    o.propagateHtmlErrors = false -- if errors in callbacks should throw exceptions
    o.htmlCallbacks = {}

    o.mouseDownCallbacks = {}
    o.mouseUpCallbacks = {}

    return o
end

local CONTENT_TEMPLATE = '<div style="position:absolute; left:%.6fvw; top:%.6fvh; display: %s;">%s</div>'
-- Rebuilds the current state, including all declared and visible content, into a single internal html string.
-- @tparam ScreenUnit The screen to rebuild html for.
local function generateHtml(screen)
    local html = ""
    html = html .. screen.directHtml

    local display
    for _,content in pairs(screen.contentList) do
        if content.visible ~= false then
            display = "block"
        else
            display = "none"
        end
        html = html .. string.format(CONTENT_TEMPLATE, content.x, content.y, display, content.html)
    end

    screen.html = html

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(screen.htmlCallbacks) do
        local status,err = pcall(callback, html)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if screen.propagateHtmlErrors and string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

local function validateText(text)
    if text == nil then
        text = ""
    elseif type(text) ~= "string" then
        text = tostring(text)
    end
    return text
end

local function validateFloat(value)
    if type(value) ~= "number" then
        value = tonumber(value)
    end
    if value == nil then
        value = 0
    end
    return value
end

--- <b>Deprecated:</b> Displays the given text at the given coordinates in the screen, and returns an ID to move it later.
--
-- This method is deprecated: addText should be used instead.
-- @see addText
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam 0..100 fontSize Text font size, as a percentage of the screen width.
-- @tparam string text The text to display.
-- @return An integer ID that can be used later to update/remove the added element.
function M:setText(x, y, fontSize, text)
    local message = "Warning: method setText is deprecated, use addText instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
    self:addText(x, y, fontSize, text)
end

local ADD_TEXT_TEMPLATE = '<div style="font-size:%.6fvw">%s</div>'
--- Displays the given text at the given coordinates in the screen, and returns an ID to move it later.
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam 0..100 fontSize Text font size, as a percentage of the screen width.
-- @tparam string text The text to display.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addText(x, y, fontSize, text)
    fontSize = validateFloat(fontSize)
    text = validateText(text)

    local htmlContent = string.format(ADD_TEXT_TEMPLATE, fontSize, text)
    return self:addContent(x, y, htmlContent)
end

local CENTERED_TEXT_TEMPLATE = '<div class="bootstrap" style="font-size:%.6fvw; ">%s</div>'
--- Displays the given text centered in the screen with a font to maximize its visibility.
-- @tparam string text The text to display.
function M:setCenteredText(text)
    text = validateText(text)
    local fontSize
    if string.len(text) == 0 then
        fontSize = 12
    else
        -- calculated based on lengths 1-8
        fontSize = 12 - 1.442695041 * math.log(string.len(text))
    end

    -- intentionally clear any additional content
    self:setHTML(string.format(CENTERED_TEXT_TEMPLATE, fontSize, text))
end

--- <b>Deprecated:</b> Set the whole screen HTML content (overrides anything already set).
--
-- This method is deprecated: setHTML should be used instead.
-- @see setHTML
-- @tparam html html The HTML content to display.
function M:setRawHTML(html)
    local message = "Warning: method setRawHTML is deprecated, use setHTML instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
    self:setHTML(html)
end

--- Set the whole screen HTML content (overrides anything already set).
-- @tparam html html The HTML content to display.
function M:setHTML(html)
    self.contentList = {}
    self.directHtml = validateText(html)

    generateHtml(self)
end

--- Set the screen to draw using a script (overrides anything already set).
-- @tparam string script The Lua script that will define what is drawn.
function M:setRenderScript(script)
end

--- <b>Deprecated:</b> Displays the given HTML content at the given coordinates in the screen, and returns an ID to move it later.
--
-- This method is deprecated: addContent should be used instead.
-- @see addContent
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam html html The HTML content to display, which can contain SVG elements to make drawings.
-- @return An integer ID that can be used later to update/remove the added element.
function M:setContent(x, y, html)
    local message = "Warning: method setContent is deprecated, use addContent instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
    self:addContent(x, y, html)
end

--- Displays the given HTML content at the given coordinates in the screen, and returns an ID to move it later.
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
-- @tparam html html The HTML content to display, which can contain SVG elements to make drawings.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addContent(x, y, html)
    x = validateFloat(x)
    y = validateFloat(y)
    html = validateText(html)

    local content = {
        x = x,
        y = y,
        html = html,
        visible = true
    }

    local index = self.contentNextIndex
    self.contentNextIndex = self.contentNextIndex + 1

    self.contentList[index] = content

    generateHtml(self)
    return index
end

local SVG_TEMPLATE = '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%%; height:100%%">%s</svg>'
--- Displays SVG code (anything that fits within a &lt;svg&gt; section), which overrides any preexisting content.
-- @tparam svg svg The SVG content to display, which fits inside a 1920x1080 canvas.
function M:setSVG(svg)
    if svg == nil then
        svg = ""
    elseif type(svg) ~= "string" then
        svg = tostring(svg)
    end

    -- intentionally clear any additional content
    self:setHTML(string.format(SVG_TEMPLATE, svg))
end

--- Update the element with the given ID (returned by setContent) with a new HTML content.
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
-- @tparam html html The HTML content to display, which can contain SVG elements to make drawings.
function M:resetContent(id, html)
    self.contentList[id].html = html

    generateHtml(self)
end

--- Delete the element with the given ID (returned by setContent).
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
function M:deleteContent(id)
    -- deleting non-existent index is no-op
    if not self.contentList[id] then
        return
    end

    self.contentList[id] = nil

    generateHtml(self)
end

--- Update the visibility of the element with the given ID (returned by setContent).
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
-- @tparam 0/1 state 0 = invisible, 1 = visible.
function M:showContent(id, state)
    -- showing non-existent index is no-op
    if not self.contentList[id] then
        return
    end

    self.contentList[id].visible = state == 1

    generateHtml(self)
end

--- Move the element with the given id (returned by setContent) to a new position in the screen.
-- @param id An integer ID that is used to identify the element in the screen. Methods such as setContent return the ID
-- that you can store to use later here.
-- @tparam 0..100 x Horizontal position, as a percentage of the screen width.
-- @tparam 0..100 y Vertical position, as a percentage of the screen height.
function M:moveContent(id, x, y)
    -- moving non-existent index is no-op
    if not self.contentList[id] then
        return
    end

    x = validateFloat(x)
    y = validateFloat(y)

    self.contentList[id].x = x
    self.contentList[id].y = y

    generateHtml(self)
end

--- Returns the x-coordinate of the position pointed at in the screen.
-- @treturn 0..1 The x-position as a percentage of screen width; -1 if nothing is pointed at.
function M:getMouseX()
    if self.mouseX < 0 or self.mouseX > 1 then
        return -1
    end
    return self.mouseX
end

--- Returns the y-coordinate of the position pointed at in the screen.
-- @treturn 0..1 The y-position as a percentage of screen height; -1 if nothing is pointed at.
function M:getMouseY()
    if self.mouseY < 0 or self.mouseY > 1 then
        return -1
    end
    return self.mouseY
end

--- Returns the state of the mouse click.
-- @treturn 0/1 0 when the mouse is not clicked and 1 otherwise.
function M:getMouseState()
    if self.mouseState then
        return 1
    end
    return 0
end

--- Clear the screen.
function M:clear()
    self.directHtml = ""
    self.contentList = {}

    generateHtml(self)
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (has no actual effect on screen state when modified this way).</li>
-- </ul>
-- @param plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        local value = tonumber(state)
        if type(value) ~= "number" then
            value = 0.0
        end

        -- expected behavior, but in fact nothing happens in-game
        if value > 0.0 then
            -- self:activate()
        else
            -- self:deactivate()
        end

        if value <= 0 then
            self.plugIn = 0
        elseif value >= 1.0 then
            self.plugIn = 1.0
        else
            self.plugIn = value
        end
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @param plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        -- clamp to valid values
        local value = tonumber(self.plugIn)
        if type(value) ~= "number" then
            return 0.0
        elseif value >= 1.0 then
            return 1.0
        elseif value <= 0.0 then
            return 0.0
        else
            return value
        end
    end
    return MockElement.getSignalIn(self)
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

--- Mock only, not in-game: Register a handler for the in-game `mouseDown(x,y)` event.
-- @tparam function callback The function to call when the mouse button is pressed.
-- @tparam string x The x to filter on, or "*" for all.
-- @tparam string y The y to filter for, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_mouseDown
function M:mockRegisterMouseDown(callback, x, y)
    -- default to all
    x = x or "*"
    y = y or "*"

    local index = #self.mouseDownCallbacks + 1
    self.mouseDownCallbacks[index] = {callback = callback, x = x, y = y}
    return index
end

--- Mock only, not in-game: Simulates a mouse press on the screen.
-- @tparam float x X-coordinate of the click in percentage of the screen width.
-- @tparam float y Y-coordinate of the click in percentage of the screen width.
function M:mockDoMouseDown(x, y)
    assert(x > 0 and x < 1, "Mouse X value out of range: " .. x)
    assert(y > 0 and y < 1, "Mouse Y value out of range: " .. y)

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.mouseDownCallbacks) do
        -- filter on the channel and on message
        if (callback.x == "*" or callback.x == x) and
                (callback.y == "*" or callback.y == y) then
            local status,err = pcall(callback.callback, x, y)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a handler for the in-game `mouseUp(x,y)` event.
-- @tparam function callback The function to call when the mouse button is released.
-- @tparam string x The x to filter on, or "*" for all.
-- @tparam string y The y to filter for, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_mouseUp
function M:mockRegisterMouseUp(callback, x, y)
    -- default to all
    x = x or "*"
    y = y or "*"

    local index = #self.mouseUpCallbacks + 1
    self.mouseUpCallbacks[index] = {callback = callback, x = x, y = y}
    return index
end

--- Mock only, not in-game: Simulates a mouse release on the screen.
-- @tparam float x X-coordinate of the click in percentage of the screen width.
-- @tparam float y Y-coordinate of the click in percentage of the screen width.
function M:mockDoMouseUp(x, y)
    assert(x > 0 and x < 1, "Mouse X value out of range: " .. x)
    assert(y > 0 and y < 1, "Mouse Y value out of range: " .. y)

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.mouseUpCallbacks) do
        -- filter on the channel and on message
        if (callback.x == "*" or callback.x == x) and
                (callback.y == "*" or callback.y == y) then
            local status,err = pcall(callback.callback, x, y)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Mock only, not in-game: Register a callback to be notified when the screen html changes.
-- @tparam function callback The function to call (with html) when the screen updates is called.
-- @treturn int The index of the callback.
function M:mockRegisterHtmlCallback(callback)
    local index = #self.htmlCallbacks + 1
    self.htmlCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    -- codex-documented methods
    closure.addText = function(x, y, fontSize, text) return self:addText(x, y, fontSize, text) end
    closure.setCenteredText = function(text) return self:setCenteredText(text) end
    closure.setHTML = function(html) return self:setHTML(html) end
    closure.setRenderScript = function(script) return self:setRenderScript(script) end
    closure.addContent = function(x, y, html) return self:addContent(x, y, html) end
    closure.setSVG = function(svg) return self:setSVG(svg) end
    closure.resetContent = function(id, html) return self:resetContent(id, html) end
    closure.deleteContent = function(id) return self:deleteContent(id) end
    closure.showContent = function(id, state) return self:showContent(id, state) end
    closure.moveContent = function(id, x, y) return self:moveContent(id, x, y) end
    closure.getMouseX = function() return self:getMouseX() end
    closure.getMouseY = function() return self:getMouseY() end
    closure.getMouseState = function() return self:getMouseState() end
    closure.clear = function() return self:clear() end
    -- undocumented (deprecated) methods
    closure.setText = function(x, y, fontSize, text) return self:setText(x, y, fontSize, text) end
    closure.setRawHTML = function(html) return self:setRawHTML(html) end
    closure.setContent = function(x, y, html) return self:setContent(x, y, html) end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M
