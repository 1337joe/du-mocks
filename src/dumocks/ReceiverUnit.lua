--- Receives messages on given channels.
--
-- Element class: ReceiverUnit
--
-- Extends: Element
-- @see Element
-- @module ReceiverUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["receiver xs"] = {mass = 13.27, maxHitPoints = 50.0}
elementDefinitions["receiver s"] = {mass = 475.87, maxHitPoints = 191.0}
elementDefinitions["receiver m"] = {mass = 12664.06, maxHitPoints = 15326.0}
local DEFAULT_ELEMENT = "receiver xs"

local M = MockElement:new()
M.elementClass = "ReceiverUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.channelList = ""
    o.range = 1000 -- meters
    o.receiveCallbacks = {}

    return o
end

--- Returns the receiver range.
-- @treturn meter The range.
function M:getRange()
    return self.range
end

--- Set the channels list.
-- @tparam string channelList The channels list separated by commas.
function M:setChannels(channelList)
    self.channelList = channelList
end

--- Returns the channels list.
-- @treturn string The channels list separated by commas.
function M:getChannels()
    return self.channelList
end

--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"out" for the out signal.</li>
-- </ul>
-- @param plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    if plug == "out" then
        if self.plugOut then
            return 1.0
        else
            return 0.0
        end
    end
    return MockElement.getSignalOut(self, plug)
end

--- Event: Emitted when a message is received on any channel defined on the element.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string channel The channel; can be used as a filter.
-- @tparam string message The message received.
function M.EVENT_receive(channel, message)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterReceive")
end

--- Mock only, not in-game: Register a handler for the in-game `receive(channel,message)` event.
-- @tparam function callback The function to call when the a message is received.
-- @tparam string channel The channel to filter on, or "*" for all.
-- @tparam string message The message to filter for, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_receive
function M:mockRegisterReceive(callback, channel, message)
    -- default to all
    channel = channel or "*"
    message = message or "*"

    local index = #self.receiveCallbacks + 1
    self.receiveCallbacks[index] = {
        callback = callback,
        channel = channel,
        message = message
    }
    return index
end

--- Mock only, not in-game: Simulates a message reaching the receiver.
-- @tparam string channel The channel a message was sent on, must match a channel in channelList to be received.
-- @tparam string message The message received.
function M:mockDoReceive(channel, message)
    local processMessage = false
    for listenChannel in string.gmatch(self.channelList, "%s*([^,]+)%s*") do
        if listenChannel == channel then
            processMessage = true
            break
        end
    end
    if not processMessage then
        return
    end

    -- enable out signal for as long as it takes to process receive handlers
    self.plugOut = true

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.receiveCallbacks) do
        -- filter on the channel and on message
        if (callback.channel == "*" or callback.channel == channel) and
                (callback.message == "*" or callback.message == message) then
            local status, err = pcall(callback.callback, channel, message)
            if not status then
                errors = errors .. "\nError while running callback " .. i .. ": " .. err
            end
        end
    end

    self.plugOut = false

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:" .. errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getRange = function() return self:getRange() end
    closure.setChannels = function(channelList) return self:setChannels(channelList) end
    closure.getChannels = function() return self:getChannels() end

    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M
