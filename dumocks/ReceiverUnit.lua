--- Receives messages on given channels.
-- @module ReceiverUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
-- TODO
local DEFAULT_ELEMENT = ""

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.range = 1 -- TODO when default element is defined: elementDefinition.getRange
    o.receiveCallbacks = {}

    return o
end

--- Returns the emitter range.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Event: Emitted when a message is received on any channel.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string channel The channel; can be used as a filter.
-- @tparam string message The message received.
function M.EVENT_receive(channel, message)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterReceive")
end

--- Mock only, not in-game: Register a handler for the in-game `receive(channel,message)` event.
-- @tparam string channel The channel to filter on, or "*" for all.
-- @tparam function callback The function to call when the button is pressed.
-- @treturn int The index of the callback.
-- @see EVENT_receive
function M:mockRegisterReceive(channel, callback)

    -- TODO: store channel with the callback

    local index = #self.receiveCallbacks + 1
    self.receiveCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates a message reaching the receiver.
-- @tparam string channel The channel; can be used as a filter.
-- @tparam string message The message received.
function M:mockDoReceive(channel, message)

    -- TODO filter on the channel

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.receiveCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
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