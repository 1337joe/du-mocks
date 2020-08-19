--- This unit is capable of emitting messages on channels.
-- @module EmitterUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["emitter xs"] = {mass = 69.31, maxHitPoints = 50.0, range = 100.0}
-- TODO others
local DEFAULT_ELEMENT = "emitter xs"

local M = MockElement:new()
M.elementClass = "EmitterUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.range = elementDefinition.range -- meters
    o.propagateSendErrors = false -- in-game module gets no feedback, make optional for testing purposes
    o.receiverCallbacks = {}

    return o
end

--- Send a message on the given channel.
-- @tparam string channel The channel name.
-- @tparam string message The message to transmit.
function M:send(channel, message)
    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.receiverCallbacks) do
        local status,err = pcall(callback, channel, message)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if self.propagateSendErrors and string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end

--- Returns the emitter range.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Mock only, not in-game: Register a receiver of calls to send()
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
    closure.getRange = function() return self:getRange() end
    return closure
end

return M