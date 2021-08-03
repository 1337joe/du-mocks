--- This unit is capable of emitting messages on a channel.
--
-- Element class: EmitterUnit
--
-- Extends: Element
-- @see Element
-- @module EmitterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["emitter xs"] = {mass = 69.31, maxHitPoints = 50.0}
elementDefinitions["emitter s"] = {mass = 427.72, maxHitPoints = 133.0}
elementDefinitions["emitter m"] = {mass = 2035.73, maxHitPoints = 13686.0}
local DEFAULT_ELEMENT = "emitter xs"

local M = MockElement:new()
M.elementClass = "EmitterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.defaultChannel = ""
    o.range = 1000 -- meters
    o.propagateBroadcastErrors = false -- in-game module gets no feedback, make optional for testing purposes
    o.receiverCallbacks = {}

    return o
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal. When this is non-zero "*" will be sent on the default channel, if set.</li>
-- </ul>
-- @param plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        local value = tonumber(state)
        if type(value) ~= "number" then
            value = 0.0
        end

        local oldValue = self.plugIn

        if value <= 0 then
            self.plugIn = 0
        elseif value >= 1.0 then
            self.plugIn = 1.0
        else
            self.plugIn = value
        end

        -- send * on default channel
        if value > 0.0 then
            self:broadcast("*")

            -- do it again if it's a new value
            if value ~= oldValue then
                self:broadcast("*")
            end
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

local function trimString(inpString)
    return string.sub(inpString, 0, 512)
end

--- Send a message on the given channel. Note that only the last message is guaranteed to be propagated on the network,
-- due to bandwidth limitations.
--
-- Note: Max channel and message string length is currently 512 characters each, any additional text will be truncated.
-- @tparam string channel The channel name.
-- @tparam string message The message to transmit.
function M:send(channel, message)
    local outputMessage = "Warning: method send is deprecated, use broadcast instead"
    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(outputMessage)
    else
        print(outputMessage)
    end
    self:broadcast(message)
end

--- Send a message on the channel specified by the emitter. Note that only the last message is guaranteed to be propagated on the network,
-- due to bandwidth limitations.
--
-- Note: Max message string length is currently 512 characters, any additional text will be truncated.
-- @tparam string message The message to transmit.
function M:broadcast(message)
    message = trimString(message)

    if not (self.defaultChannel and self.defaultChannel:len() > 0) then
        error("Define a broadcast channel on your Emitter (mock.defaultChannel)")
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.receiverCallbacks) do
        local status,err = pcall(callback, self.defaultChannel, message)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if self.propagateBroadcastErrors and string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Returns the emitter range.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Mock only, not in-game: Register a receiver of calls to send().
-- @tparam function callback The function to call (with channel and message arguments) when the send is called.
-- @treturn int The index of the callback.
-- @see send
function M:mockRegisterReceiver(callback)
    local index = #self.receiverCallbacks + 1
    self.receiverCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.send = function(channel, message) return self:send(channel, message) end
    closure.broadcast = function(message) return self:broadcast(message) end
    closure.getRange = function() return self:getRange() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M