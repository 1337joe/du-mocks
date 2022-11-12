#!/usr/bin/env lua
--- Tests on dumocks.ReceiverUnit.
-- @see dumocks.ReceiverUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mru = require("dumocks.ReceiverUnit")
local utilities = require("test.Utilities")

_G.TestReceiverUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestReceiverUnit.testConstructor()

    -- default element:
    -- ["receiver xs"] = {mass = 13.27, maxHitPoints = 50.0, itemId = 3732634076}

    local receiver0 = mru:new()
    local receiver1 = mru:new(nil, 1, "Receiver XS")
    local receiver2 = mru:new(nil, 2, "invalid")
    local receiver3 = mru:new(nil, 3, "receiver s")

    local receiverClosure0 = receiver0:mockGetClosure()
    local receiverClosure1 = receiver1:mockGetClosure()
    local receiverClosure2 = receiver2:mockGetClosure()
    local receiverClosure3 = receiver3:mockGetClosure()

    lu.assertEquals(receiverClosure0.getLocalId(), 0)
    lu.assertEquals(receiverClosure1.getLocalId(), 1)
    lu.assertEquals(receiverClosure2.getLocalId(), 2)
    lu.assertEquals(receiverClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 13.27
    lu.assertEquals(receiverClosure0.getMass(), defaultMass)
    lu.assertEquals(receiverClosure1.getMass(), defaultMass)
    lu.assertEquals(receiverClosure2.getMass(), defaultMass)
    lu.assertNotEquals(receiverClosure3.getMass(), defaultMass)

    local defaultId = 3732634076
    lu.assertEquals(receiverClosure0.getItemId(), defaultId)
    lu.assertEquals(receiverClosure1.getItemId(), defaultId)
    lu.assertEquals(receiverClosure2.getItemId(), defaultId)
    lu.assertNotEquals(receiverClosure3.getItemId(), defaultId)
end

--- Verify get range retrieves range properly.
function _G.TestReceiverUnit.testGetRange()
    local mock = mru:new()
    local closure = mock:mockGetClosure()

    mock.range = 50.0
    lu.assertEquals(closure.getRange(), 50.0)

    mock.range = 100.0
    lu.assertEquals(closure.getRange(), 100.0)
end

--- Verify functionality of set channels.
function _G.TestReceiverUnit.testSetChannelList()
    local mock = mru:new()
    local closure = mock:mockGetClosure()

    local input, expected

    input = {"channel"}
    expected = "channel,"
    lu.assertEquals(closure.setChannelList(input), 1)
    lu.assertEquals(mock.channelList, expected)
    utilities.verifyDeprecated("setChannels", closure.setChannels, input[1])
    lu.assertEquals(mock.channelList, expected)

    input = {"l1", "l2"}
    expected = table.concat(input, ",") .. ","
    lu.assertEquals(closure.setChannelList(input), 1)
    lu.assertEquals(mock.channelList, expected)
    utilities.verifyDeprecated("setChannels", closure.setChannels, table.concat(input, ","))
    lu.assertEquals(mock.channelList, expected)

    -- currently throws a sandbox exception in-game
    -- input = {"l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8", "l9"}
    -- lu.assertEquals(closure.setChannelList(input), 0)
    -- lu.assertEquals(mock.channelList, expected)
    -- utilities.verifyDeprecated("setChannels", closure.setChannels, table.concat(input, ","))
    -- lu.assertEquals(mock.channelList, expected)
end

--- Verify functionality of get channels.
function _G.TestReceiverUnit.testGetChannelList()
    local mock = mru:new()
    local closure = mock:mockGetClosure()

    local input, expected

    expected = {"channel"}
    mock.channelList = table.concat(expected, ",") .. ","
    lu.assertEquals(closure.getChannelList(), expected)
    lu.assertEquals(utilities.verifyDeprecated("getChannels", closure.getChannels), expected[1] .. ",")

    expected = {"l1", "l2"}
    mock.channelList = table.concat(expected, ",") .. ","
    lu.assertEquals(closure.getChannelList(), expected)
    lu.assertEquals(utilities.verifyDeprecated("getChannels", closure.getChannels), table.concat(expected, ",") .. ",")
end

--- Verify receive calls all callbacks and propagates errors.
function _G.TestReceiverUnit.testReceiveError()
    local mock = mru:new()
    mock:setChannelList({"channel"})

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function(_, _)
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterReceive(callbackError, "*", "*")

    local callback2 = function(_, _)
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterReceive(callback2, "*", "*")

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoReceive, mock, "channel", "message")
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)
end

--- Verify unfiltered receive gets all messages on channels the receiver is listening to.
function _G.TestReceiverUnit.testReceiveAll()
    local mock = mru:new()
    mock:setChannelList({"channel", "blah"})

    local expectedChannel, actualChannel
    local expectedMessage, actualMessage

    local called
    local callback = function(channel, message)
        called = true
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "*", "*")

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "blah"
    expectedMessage = "new message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    called = false
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertFalse(called)

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)
end

--- Verify filtering on channel works.
function _G.TestReceiverUnit.testReceiveFilterChannel()
    local mock = mru:new()
    mock:setChannelList({"channel", "filter"})

    local expectedChannel, actualChannel
    local expectedMessage, actualMessage

    local called
    local callback = function(channel, message)
        called = true
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "channel", "*")

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    -- in channel list but not in filter
    called = false
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertFalse(called)

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)
end

--- Verify filtering on messages works.
function _G.TestReceiverUnit.testReceiveFilterMessage()
    local mock = mru:new()
    mock:setChannelList({"channel"})

    local expectedChannel, actualChannel
    local expectedMessage, actualMessage

    local called
    local callback = function(channel, message)
        called = true
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "*", "message")

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    called = false
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertFalse(called)
end

--- Verify filtering on channel and message at the same time works.
function _G.TestReceiverUnit.testReceiveFilterBoth()
    local mock = mru:new()
    mock:setChannelList({"channel", "filter"})

    local expectedChannel, actualChannel
    local expectedMessage, actualMessage

    local called
    local callback = function(channel, message)
        called = true
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "channel", "message")

    called = false
    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertTrue(called)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    called = false
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertFalse(called)

    called = false
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertFalse(called)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Receiver XS, connected to Programming Board on slot1, default channel set to duMocks
-- 2. 1x Emitter XS, connected to Programming Board on slot2
--
-- Exercises: getClass, receive, getRange, setSignalOut, setChannelList, getChannelList, hasChannel
function _G.TestReceiverUnit.testGameBehavior()
    local mock = mru:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to suppress print in the unit test
    local unit = {}
    unit.getWidgetData = function()
        return '"showScriptError":false'
    end
    unit.setTimer = function(_, _)
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function(msg)
    end

    local slot2 = {}
    function slot2.send(channel, message)
        mock:mockDoReceive(channel, message)
    end

    local tickEnd = function()
        ---------------
        -- copy from here to unit.onTimer(timerId) stop
        ---------------
        -- exit to report status
        unit.exit()
        ---------------
        -- copy to here to unit.onTimer(timerId) stop
        ---------------
    end

    local tickResume = function()
        ---------------
        -- copy from here to unit.onTimer(timerId) resume
        ---------------
        assert(_G.receiverCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.receiverCoroutine) ~= "dead", "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.receiverCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
        ---------------
        -- copy to here to unit.onTimer(timerId) resume
        ---------------
    end

    local allCount, messageFilterCount, channelFilterCount

    local receiveAllListener = function(channel, message)
        ---------------
        -- copy from here to slot1.receive(channel,message) * *
        ---------------
        allCount = allCount + 1
        assert(slot1.getSignalOut("out") == 1.0)
        ---------------
        -- copy to here to slot1.receive(channel,message) * *
        ---------------
    end
    mock:mockRegisterReceive(receiveAllListener, "*", "*")

    local receiveChannelListener = function(channel, message)
        ---------------
        -- copy from here to slot1.receive(channel,message) duMocks *
        ---------------
        channelFilterCount = channelFilterCount + 1
        assert(message == "filtered", "Received: " .. message)
        ---------------
        -- copy to here to slot1.receive(channel,message) duMocks *
        ---------------
    end
    mock:mockRegisterReceive(receiveChannelListener, "duMocks", "*")

    local receiveMessageListener = function(channel, message)
        ---------------
        -- copy from here to slot1.receive(channel,message) * message
        ---------------
        messageFilterCount = messageFilterCount + 1
        assert(channel == "filtered", "Received on: " .. channel)
        ---------------
        -- copy to here to slot1.receive(channel,message) * message
        ---------------
    end
    mock:mockRegisterReceive(receiveMessageListener, "*", "message")

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getRange", "hasChannel", "getChannels", "getChannelList", "setChannels",
                               "setChannelList", "getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "ReceiverUnit")
    assert(string.match(string.lower(slot1.getName()), "receiver %w+ %[%d+%]"), slot1.getName())
    local expectedIds = {[3732634076] = true, [2082095499] = true, [736740615] = true}
    assert(expectedIds[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 13.27)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    assert(slot1.getRange() == 1000.0)

    allCount = 0
    messageFilterCount = 0
    channelFilterCount = 0

    -- test channel interface
    assert(slot1.setChannelList({"channel1, channel 2 "}) == 1)
    assert(#slot1.getChannelList() == 2)
    assert(slot1.hasChannel("channel1") == 1)
    assert(slot1.hasChannel(" channel 2 ") == 1)
    assert(slot1.setChannelList({"c1", "c2"}) == 1)
    assert(#slot1.getChannelList() == 2)
    assert(slot1.hasChannel("channel1") == 0)
    assert(slot1.hasChannel(" channel 2 ") == 0)
    assert(slot1.hasChannel("c1") == 1)
    assert(slot1.hasChannel("c2") == 1)

    -- test messaging
    local channels = {"unexpected", "filtered", "duMocks"}
    slot1.setChannelList(channels)
    _G.Utilities.assertTableEquals(slot1.getChannelList(), channels)

    local function messagingTest()
        slot2.send("unexpected", "unexpected") -- hits all listener only
        coroutine.yield()

        slot2.send("filtered", "message") -- filtered by message
        coroutine.yield()

        slot2.send("duMocks", "filtered") -- filtered by channel
        coroutine.yield()

        slot2.send("unlistened", "unexpected") -- receiver not registered for channel
        coroutine.yield()

        unit.exit()
    end

    _G.receiverCoroutine = coroutine.create(messagingTest)
    coroutine.resume(_G.receiverCoroutine)

    unit.setTimer("resume", 0.25)

    -- all messages should be processed easily within 2 seconds
    unit.setTimer("stop", 2)
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    -- listener function called synchronously, by the time yield is called all processing is finished, so just resume
    tickResume()
    tickResume()
    tickResume()
    tickResume()

    ---------------
    -- copy from here to unit.onStop()
    ---------------
    assert(allCount == 3, allCount)
    assert(messageFilterCount == 1, messageFilterCount)
    assert(channelFilterCount == 1)

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getWidgetData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end
    ---------------
    -- copy to here to unit.onStop()
    ---------------
end

os.exit(lu.LuaUnit.run())
