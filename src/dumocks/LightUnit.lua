--- Emits a source of light
--
-- Element class: LightUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module LightUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["square light xs"] = {mass = 70.05, maxHitPoints = 50.0, itemId = 177821174}
elementDefinitions["square light s"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 3981684520}
elementDefinitions["square light m"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 632353355}
elementDefinitions["square light l"] = {mass = 79.34, maxHitPoints = 57.0, itemId = 823697268}
elementDefinitions["long light xs"] = {mass = 70.05, maxHitPoints = 50.0, itemId = 25682791}
elementDefinitions["long light s"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 3180371725}
elementDefinitions["long light m"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 677591159}
elementDefinitions["long light l"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 3524314552}
elementDefinitions["vertical light xs"] = {mass = 70.05, maxHitPoints = 50.0, itemId = 3923388834}
elementDefinitions["vertical light s"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 3231255047}
elementDefinitions["vertical light m"] = {mass = 79.34, maxHitPoints = 62.0, itemId = 1603266808}
elementDefinitions["vertical light l"] = {mass = 371.80, maxHitPoints = 499.0, itemId = 2027152926}
elementDefinitions["headlight"] = {mass = 79.34, maxHitPoints = 50.0, itemId = 787207321}
local DEFAULT_ELEMENT = "square light xs"

local M = MockElementWithToggle:new()
M.elementClass = "LightUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = true
    o.color = {
        r = 1,
        g = 1,
        b = 1
    }
    o.blinking = false
    o.blinkingOn = 1.0
    o.blinkingOff = 0.0
    o.blinkingShift = 0.0

    o.plugIn = 0.0

    return o
end

--- Switches the light on.
function M:activate()
    self.state = true
end

--- Switches the light off.
function M:deactivate()
    self.state = false
end

--- Checks if the light is on.
-- @treturn 0/1 1 if the light is on.
function M:isActive()
    if self.state then
        return 1
    end
    return 0
end

local function handleColorValue(val)
    val = tonumber(val)
    if not val then
        val = 0
    elseif val < 0 then
        val = 0
    elseif val > 5 then
        val = 5
    end
    return val
end

--- <b>Deprecated:</b> Set the light color in RGB.
--
-- This method is deprecated: setColor should be used instead
-- @see setColor
-- @tparam 0..255 r The red component, between 0 and 255.
-- @tparam 0..255 g The green component, between 0 and 255.
-- @tparam 0..255 b The blue component, between 0 and 255.
function M:setRGBColor(r, g, b)
    M.deprecated("setRGBColor", "setColor")
    self:setColor(r / 255.0, g / 255.0, b / 255.0)
end

--- Set the color of the light to RGB. Lights can use HDR color values above 1.0 to glow.
-- @tparam int r The red component, between 0.0 and 1.0, up to 5.0 for HDR colors.
-- @tparam int g The green component, between 0.0 and 1.0, up to 5.0 for HDR colors.
-- @tparam int b The blue component, between 0.0 and 1.0, up to 5.0 for HDR colors.
function M:setColor(r, g, b)
    self.color.r = handleColorValue(r)
    self.color.g = handleColorValue(g)
    self.color.b = handleColorValue(b)
end

--- <b>Deprecated:</b> Get the light color in RGB.
--
-- This method is deprecated: getColor should be used instead
-- @see getColor
-- @treturn vec3 A vec3 for the red, blue and green components of the light, with values between 0 and 255.
function M:getRGBColor()
    M.deprecated("getRGBColor", "getColor")
    local rgb = self:getColor()
    return {rgb[1] * 255, rgb[2] * 255, rgb[3] * 255}
end

--- Returns the light color in RGB.
-- @treturn vec3 A vec3 for the red, blue and green components of the light, with values between 0.0 and 1.0, up to 5.0.
function M:getColor()
    return {self.color.r, self.color.g, self.color.b}
end

--- Enables or disables the blinking state of the light.
-- @tparam bool state True to enable light blinking.
function M:setBlinkingState(state)
    -- accepts 1 or true, as well as anything parseable as a whole number besides 0
    local numberState = tonumber(state)
    self.blinking = (state == true) or (numberState and numberState ~= 0 and numberState % 1 == 0) or false
end

--- Checks if the light blinking is enabled.
-- @treturn 0/1 1 if the light blinking is enabled.
function M:isBlinking()
    if self.blinking then
        return 1
    end
    return 0
end

--- Returns the light 'on' blinking duration.
-- @treturn float The duration of the 'on' blinking in seconds.
function M:getOnBlinkingDuration()
    return self.blinkingOn
end

local function toValidTime(time)
    local timeNumber = tonumber(time)
    if not timeNumber or timeNumber < 0 then
        return 0
    end
    return timeNumber
end

--- Set the light 'on' blinking duration.
-- @tparam float time The duration of the 'on' blinking in seconds.
function M:setOnBlinkingDuration(time)
    self.blinkingOn = toValidTime(time)
end

--- Returns the light 'off' blinking duration.
-- @treturn float The duration of the 'off' blinking in seconds.
function M:getOffBlinkingDuration()
    return self.blinkingOff
end

--- Set the light 'off' blinking duration.
-- @tparam float time The duration of the 'off' blinking in seconds.
function M:setOffBlinkingDuration(time)
    self.blinkingOff = toValidTime(time)
end

--- Returns the light blinking time shift.
-- @treturn float The time shift of the blinking in seconds.
function M:getBlinkingTimeShift()
    return self.blinkingShift
end

--- Set the light blinking time shift.
-- @tparam float shift The time shift of the blinking in seconds.
function M:setBlinkingTimeShift(shift)
    self.blinkingShift = toValidTime(shift)
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

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.isActive = function() return self:isActive() end
    closure.setRGBColor = function(r, g, b) return self:setRGBColor(r, g, b) end
    closure.setColor = function(r, g, b) return self:setColor(r, g, b) end
    closure.getRGBColor = function() return self:getRGBColor() end
    closure.getColor = function() return self:getColor() end
    closure.setBlinkingState = function(state) return self:setBlinkingState(state) end
    closure.isBlinking = function() return self:isBlinking() end
    closure.getOnBlinkingDuration = function() return self:getOnBlinkingDuration() end
    closure.setOnBlinkingDuration = function(time) return self:setOnBlinkingDuration(time) end
    closure.getOffBlinkingDuration = function() return self:getOffBlinkingDuration() end
    closure.setOffBlinkingDuration = function(time) return self:setOffBlinkingDuration(time) end
    closure.getBlinkingTimeShift = function() return self:getBlinkingTimeShift() end
    closure.setBlinkingTimeShift = function(shift) return self:setBlinkingTimeShift(shift) end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M