--- Receives messages on given channels.
--
-- Element class: ReceiverUnit
--
-- Extends: @{Element}
-- @module ReceiverUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["receiver xs"] = {mass = 13.27, maxHitPoints = 50.0, itemId = 3732634076}
elementDefinitions["receiver s"] = {mass = 475.87, maxHitPoints = 191.0, itemId = 2082095499}
elementDefinitions["receiver m"] = {mass = 12664.06, maxHitPoints = 15326.0, itemId = 736740615}
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
-- @treturn float The range in m (meters).
function M:getRange()
    return self.range
end

--- Checks if the given channel exists in the receiver channels list.
-- @tparam string channel The channel to check for.
-- @treturn 0/1 1 if the channels list contains the given channel.
function M:hasChannel(channel)
    for _, c in pairs(self:getChannelList()) do
        if c == channel then
            return 1
        end
    end
    return 0
end

--- <b>Deprecated:</b> Set the channels list.
--
-- This method is deprecated: setChannelList should be used instead
-- @see setChannelList
-- @tparam string channelList The channels list separated by commas.
function M:setChannels(channelList)
    M.deprecated("setChannels", "setChannelList")
    local channels = {}
    for channel in string.gmatch(channelList, "([^,]+)") do
        channels[#channels + 1] = channel
    end
    self:setChannelList(channels)
end

--- Set the channels list.
-- @tparam list channels The channels list as a Lua table. At most 8 channels may be set, but a comma-separated string
--   in the table will be split on the commas into multiple channels.
-- @treturn 0/1 1 if the channels list has been successfully set.
function M:setChannelList(channels)
    if #channels > 8 then
        error("Too many channels set")
        -- return 0
    end

    -- trailing , to match in-game behavior
    self.channelList = table.concat(channels, ",") .. ","
    return 1
end

--- <b>Deprecated:</b> Returns the channels list.
--
-- This method is deprecated: getChannelList should be used instead
-- @see getChannelList
-- @treturn string The channels list separated by commas.
function M:getChannels()
    M.deprecated("getChannels", "getChannelList")
    return table.concat(self:getChannelList(), ",") .. ","
end

--- Returns the channels list.
-- @treturn list The channels list as a Lua table.
function M:getChannelList()
    local channels = {}
    for channel in string.gmatch(self.channelList, "([^,]+)") do
        channels[#channels + 1] = channel
    end
    return channels
end

--- Return the value of a signal in the specified OUT plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"out" for the out signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
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

--- <b>Deprecated:</b> Event: Emitted when a message is received on any channel defined on the element.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onReceived should be used instead.
-- @see EVENT_onReceived
-- @tparam string channel The channel; can be used as a filter.
-- @tparam string message The message received.
function M.EVENT_receive(channel, message)
    M.deprecated("EVENT_receive", "EVENT_onReceived")
    M.EVENT_onReceived()
end

--- Event: Emitted when a message is received on any channel defined on the element.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string channel The channel; can be used as a filter.
-- @tparam string message The message received.
function M.EVENT_onReceived(channel, message)
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
-- @tparam string channel The channel a message was sent on, receiver must have channel to be received.
-- @tparam string message The message received.
function M:mockDoReceive(channel, message)
    if self:hasChannel(channel) ~= 1 then
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
    closure.hasChannel = function(channel) return self:hasChannel(channel) end
    closure.setChannels = function(channelList) return self:setChannels(channelList) end
    closure.setChannelList = function(channelList) return self:setChannelList(channelList) end
    closure.getChannels = function() return self:getChannels() end
    closure.getChannelList = function() return self:getChannelList() end

    closure.getSignalOut = function(plug) return self:getSignalOut(plug) end
    return closure
end

return M
