--- Screen units can display any HTML code or text message, and you can use them to create visually interactive feedback
-- for your running Lua script by connecting one or more of them to your control unit.
--
-- Element class:
-- <ul>
--   <li>ScreenUnit: Basic and transparent screens</li>
--   <li>ScreenSignUnit: Signs</li>
-- </ul>
--
-- Documentation for the @{renderScript} is separate.
--
-- Note: The max size of screen content is 50,000 characters. Any calls to set or add content that result in the screen
-- exceeding this will silently fail.
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @see renderScript
-- @module ScreenUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local RenderScript = require("dumocks.RenderScript")

local elementDefinitions = {}
elementDefinitions["screen xs"] = {mass = 18.67, maxHitPoints = 50.0, itemId = 184261427, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["screen s"] = {mass = 18.67, maxHitPoints = 50.0, itemId = 184261490, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["screen m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["screen xl"] = {mass = 12810.88, maxHitPoints = 28116.0, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["modern screen s"] = {mass = 7.5, maxHitPoints = 200.0, itemId = 819161538, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["transparent screen xs"] = {mass = 18.67, maxHitPoints = 50.0, itemId = 3988665660, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["transparent screen s"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["transparent screen m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["transparent screen l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenUnit", resolutionX = 1024.0, resolutionY = 613.0}
elementDefinitions["sign xs"] = {mass = 18.67, maxHitPoints = 50.0, itemId = 166656023, class = "ScreenSignUnit", resolutionX = 1024.0, resolutionY = 512.0}
elementDefinitions["sign s"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 1024.0, resolutionY = 1024.0}
elementDefinitions["sign m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 1024.0, resolutionY = 512.0}
elementDefinitions["sign l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 1024.0, resolutionY = 256.0}
elementDefinitions["vertical sign xs"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 512.0, resolutionY = 1024.0}
elementDefinitions["vertical sign m"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 512.0, resolutionY = 1024.0}
elementDefinitions["vertical sign l"] = {mass = 18.67, maxHitPoints = 50.0, class = "ScreenSignUnit", resolutionX = 256.0, resolutionY = 1024.0}
local DEFAULT_ELEMENT = "screen xs"

local M = MockElementWithToggle:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class
    o.resolutionX = elementDefinition.resolutionX
    o.resolutionY = elementDefinition.resolutionY

    o.html = "" -- this is the displayed content, for use in checking what's on the screen in non-lua mode

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

    o.renderScript = ""
    o.scriptInput = ""
    o.scriptOutput = ""

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

--- Switch on the screen.
function M:activate()
    self.state = true
end

--- Switch off the screen.
function M:deactivate()
    self.state = false
end

--- Checks if the screen is on.
-- @treturn 0/1 1 if the screen is on.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

local ADD_TEXT_TEMPLATE = '<div style="font-size:%.6fvw">%s</div>'
--- <b>Deprecated:</b> Displays the given text at the given coordinates in the screen, and returns an ID to move it later.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam float x Horizontal position, as a percentage (between 0 and 100) of the screen width.
-- @tparam float y Vertical position, as a percentage (between 0 and 100) of the screen height.
-- @tparam float fontSize Text font size, as a percentage (between 0 and 100) of the screen width.
-- @tparam string text The text to display.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addText(x, y, fontSize, text)
    M.deprecated("addText", "Lua rendering on the screen or setRenderScript(script)")
    fontSize = validateFloat(fontSize)
    text = validateText(text)

    local htmlContent = string.format(ADD_TEXT_TEMPLATE, fontSize, text)
    return self:addContent(x, y, htmlContent)
end

local CENTERED_TEXT_TEMPLATE = [[local rslib = require('rslib')
local text = "%s"
local config = { fontSize = %d }
rslib.drawQuickText(text, config)]]
--- Displays the given text centered in the screen with a font to maximize its visibility.
-- @tparam string text The text to display.
function M:setCenteredText(text)
    text = validateText(text)
    local fontSize
    if string.len(text) == 0 then
        fontSize = 122
    else
        -- calculated based on lengths 1-10
        fontSize = 122 - math.floor(34 * math.log(string.len(text), 10))
    end

    self:setRenderScript(string.format(CENTERED_TEXT_TEMPLATE, text, fontSize))
end

--- <b>Deprecated:</b> Set the whole screen HTML content (overrides anything already set).
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam string html The HTML content to display.
function M:setHTML(html)
    M.deprecated("setHTML", "Lua rendering on the screen or setRenderScript(script)")
    self.contentList = {}
    self.directHtml = validateText(html)

    generateHtml(self)
end

--- Set the screen render script, switching the screen to native rendering mode.
-- @tparam string script The Lua render script.
function M:setRenderScript(script)
    self.renderScript = script
end

--- Defines the input of the screen rendering script, which will be automatically defined during the execution of Lua.
-- @tparam string params A string that can be retrieved by calling getInput in a render script.
-- @see renderScript:getInput
function M:setScriptInput(params)
    self.scriptInput = validateText(params)
end

--- Set the screen render script output to the empty string.
-- @see renderScript:setOutput
function M:clearScriptOutput()
    self.scriptOutput = ""
end

--- Get the screen render script output.
-- @treturn string The contents of the last render script setOutput call, or an empty string.
-- @see renderScript:setOutput
function M:getScriptOutput()
    return validateText(self.scriptOutput)
end

--- <b>Deprecated:</b> Displays the given HTML content at the given coordinates in the screen, and returns an ID to move it later.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam float x Horizontal position, as a percentage (between 0 and 100) of the screen width.
-- @tparam float y Vertical position, as a percentage (between 0 and 100) of the screen height.
-- @tparam string html The HTML content to display, which can contain SVG elements to make drawings.
-- @return An integer ID that can be used later to update/remove the added element.
function M:addContent(x, y, html)
    M.deprecated("addContent", "Lua rendering on the screen or setRenderScript(script)")
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
--- <b>Deprecated:</b> Displays SVG code (anything that fits within a &lt;svg&gt; section), which overrides any preexisting content.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam string svg The SVG content to display, which fits inside a 1920x1080 canvas.
function M:setSVG(svg)
    M.deprecated("setSVG", "Lua rendering on the screen or setRenderScript(script)")
    if svg == nil then
        svg = ""
    elseif type(svg) ~= "string" then
        svg = tostring(svg)
    end

    -- intentionally clear any additional content
    self:setHTML(string.format(SVG_TEMPLATE, svg))
end

--- <b>Deprecated:</b> Update the element with the given ID (returned by addContent) with a new HTML content.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam int id An integer ID that is used to identify the element in the screen. Methods such as addContent return the ID
-- that you can store to use later here.
-- @tparam string html The HTML content to display, which can contain SVG elements to make drawings.
-- @see addContent
function M:resetContent(id, html)
    M.deprecated("resetContent", "Lua rendering on the screen or setRenderScript(script)")
    self.contentList[id].html = html

    generateHtml(self)
end

--- <b>Deprecated:</b> Delete the element with the given ID (returned by addContent).
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam int id An integer ID that is used to identify the element in the screen. Methods such as addContent return the ID
-- that you can store to use later here.
-- @see addContent
function M:deleteContent(id)
    M.deprecated("deleteContent", "Lua rendering on the screen or setRenderScript(script)")
    -- deleting non-existent index is no-op
    if not self.contentList[id] then
        return
    end

    self.contentList[id] = nil

    generateHtml(self)
end

--- <b>Deprecated:</b> Update the visibility of the element with the given ID (returned by addContent).
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam int id An integer ID that is used to identify the element in the screen. Methods such as addContent return the ID
-- that you can store to use later here.
-- @tparam 0/1 state 0 = invisible, 1 = visible.
-- @see addContent
function M:showContent(id, state)
    M.deprecated("showContent", "Lua rendering on the screen or setRenderScript(script)")
    -- showing non-existent index is no-op
    if not self.contentList[id] then
        return
    end

    self.contentList[id].visible = state == 1

    generateHtml(self)
end

--- <b>Deprecated:</b> Move the element with the given id (returned by addContent) to a new position in the screen.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
-- @tparam int id An integer ID that is used to identify the element in the screen. Methods such as addContent return the ID
-- that you can store to use later here.
-- @tparam float x Horizontal position, as a percentage (between 0 and 1) of the screen width.
-- @tparam float y Vertical position, as a percentage (between 0 and 1) of the screen height.
-- @see addContent
function M:moveContent(id, x, y)
    M.deprecated("moveContent", "Lua rendering on the screen or setRenderScript(script)")
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
-- @treturn float The x-position as a percentage (between 0 and 1) of screen width; -1 if nothing is pointed at.
function M:getMouseX()
    if self.mouseX < 0 or self.mouseX > 1 then
        return -1
    end
    return self.mouseX
end

--- Returns the y-coordinate of the position pointed at in the screen.
-- @treturn float The y-position as a percentage (between 0 and 1) of screen height; -1 if nothing is pointed at.
function M:getMouseY()
    if self.mouseY < 0 or self.mouseY > 1 then
        return -1
    end
    return self.mouseY
end

--- Returns the state of the mouse click.
-- @treturn 0/1 1 if the mouse is pressed, otherwise 0.
function M:getMouseState()
    if self.mouseState then
        return 1
    end
    return 0
end

--- <b>Deprecated:</b> Clear the screen.
--
-- This method is deprecated: Lua rendering on the screen or setRenderScript(script) should be used instead
-- @see setRenderScript
function M:clear()
    M.deprecated("clear", "Lua rendering on the screen or setRenderScript(script)")
    self.directHtml = ""
    self.contentList = {}

    generateHtml(self)
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- no longer responds to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- <b>Deprecated:</b> Event: Emitted when the player starts a click on the screen unit.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onMouseDown should be used instead.
-- @see EVENT_onMouseDown
-- @tparam float x X-coordinate of the click in percentage of the screen width.
-- @tparam float y Y-coordinate of the click in percentage of the screen height.
function M.EVENT_mouseDown(x, y)
    M.deprecated("EVENT_mouseDown", "EVENT_onMouseDown")
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the player starts a click on the screen.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam float x X-coordinate of the click in percentage (between 0 and 1) of the screen width.
-- @tparam float y Y-coordinate of the click in percentage (between 0 and 1) of the screen height.
function M.EVENT_onMouseDown(x, y)
    assert(false, "This is implemented for documentation purposes only.")
end

--- <b>Deprecated:</b> Event: Emitted when the player releases a click on the screen unit.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onMouseUp should be used instead.
-- @see EVENT_onMouseUp
-- @tparam float x X-coordinate of the click in percentage of the screen width.
-- @tparam float y Y-coordinate of the click in percentage of the screen height.
function M.EVENT_mouseUp(x, y)
    M.deprecated("EVENT_mouseUp", "EVENT_onMouseUp")
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the player releases a click on the screen unit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam float x X-coordinate of the click in percentage (between 0 and 1) of the screen width.
-- @tparam float y Y-coordinate of the click in percentage (between 0 and 1) of the screen height.
function M.EVENT_onMouseUp(x, y)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the output of the screen is changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string output The output string of the screen.
function M.EVENT_onOutputChanged(output)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Mock only, not in-game: Register a handler for the in-game `onMouseDown(x,y)` event.
-- @tparam function callback The function to call when the mouse button is pressed.
-- @tparam string x The x to filter on, or "*" for all.
-- @tparam string y The y to filter for, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_onMouseDown
function M:mockRegisterMouseDown(callback, x, y)
    -- default to all
    x = x or "*"
    y = y or "*"

    local index = #self.mouseDownCallbacks + 1
    self.mouseDownCallbacks[index] = {callback = callback, x = x, y = y}
    return index
end

--- Mock only, not in-game: Simulates a mouse press on the screen.
-- @tparam float x X-coordinate of the click in percentage (between 0 and 1) of the screen width.
-- @tparam float y Y-coordinate of the click in percentage (between 0 and 1) of the screen width.
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

--- Mock only, not in-game: Register a handler for the in-game `onMouseUp(x,y)` event.
-- @tparam function callback The function to call when the mouse button is released.
-- @tparam string x The x to filter on, or "*" for all.
-- @tparam string y The y to filter for, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_onMouseUp
function M:mockRegisterMouseUp(callback, x, y)
    -- default to all
    x = x or "*"
    y = y or "*"

    local index = #self.mouseUpCallbacks + 1
    self.mouseUpCallbacks[index] = {callback = callback, x = x, y = y}
    return index
end

--- Mock only, not in-game: Simulates a mouse release on the screen.
-- @tparam float x X-coordinate of the click in percentage (between 0 and 1) of the screen width.
-- @tparam float y Y-coordinate of the click in percentage (between 0 and 1) of the screen width.
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

--- Mock only, not in-game: Executes the script set by @{setRenderScript} in a new @{renderScript} environment
-- configured for resolution and script input and saves the script output for retrieval by @{getScriptOutput}.
-- @treturn RenderScript,table Tuple containing the @{renderScript} reference and the resulting environment.
function M:mockDoRenderScript()
    local renderScript = RenderScript:new(nil, self.resolutionX, self.resolutionY)
    renderScript.input = self.scriptInput
    local environment = renderScript:mockGetEnvironment()

    local script = assert(load(self.renderScript, nil, "t", environment))
    script()

    self.scriptOutput = renderScript.output

    return renderScript, environment
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    -- codex-documented methods
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.addText = function(x, y, fontSize, text) return self:addText(x, y, fontSize, text) end
    closure.setCenteredText = function(text) return self:setCenteredText(text) end
    closure.setHTML = function(html) return self:setHTML(html) end
    closure.setRenderScript = function(script) return self:setRenderScript(script) end
    closure.setScriptInput = function(params) return self:setScriptInput(params) end
    closure.clearScriptOutput = function() return self:clearScriptOutput() end
    closure.getScriptOutput = function() return self:getScriptOutput() end
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

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M
