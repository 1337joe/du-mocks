#!/usr/bin/env lua
--- Tests on dumocks.ReceiverUnit.
-- @see dumocks.ReceiverUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mru = require("dumocks.ReceiverUnit")
require("test.Utilities")

_G.TestReceiverUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestReceiverUnit.testConstructor()

    -- default element:
    -- ["receiver xs"] = {mass = 13.27, maxHitPoints = 50.0, range = 100.0}

    local receiver0 = mru:new()
    local receiver1 = mru:new(nil, 1, "Receiver XS")
    local receiver2 = mru:new(nil, 2, "invalid")
    local receiver3 = mru:new(nil, 3, "receiver s")

    local receiverClosure0 = receiver0:mockGetClosure()
    local receiverClosure1 = receiver1:mockGetClosure()
    local receiverClosure2 = receiver2:mockGetClosure()
    local receiverClosure3 = receiver3:mockGetClosure()

    lu.assertEquals(receiverClosure0.getId(), 0)
    lu.assertEquals(receiverClosure1.getId(), 1)
    lu.assertEquals(receiverClosure2.getId(), 2)
    lu.assertEquals(receiverClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 13.27
    lu.assertEquals(receiverClosure0.getMass(), defaultMass)
    lu.assertEquals(receiverClosure1.getMass(), defaultMass)
    lu.assertEquals(receiverClosure2.getMass(), defaultMass)
    lu.assertNotEquals(receiverClosure3.getMass(), defaultMass)
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

--- Verify receive calls all callbacks and propagates errors.
function _G.TestReceiverUnit.testReceiveError()
    local mock = mru:new()
    mock.channelList = "channel"

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
    mock.channelList = "channel, blah"

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
    mock.channelList = "channel, filter"

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
    mock.channelList = "channel"

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
    mock.channelList = "channel, filter"

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
-- Exercises: getElementClass, receive, getRange, setSignalOut, setChannels, getChannels
function _G.TestReceiverUnit.testGameBehavior()
    local mock = mru:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.setTimer = function()
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
        -- copy from here to unit.tick(timerId) stop
        ---------------
        -- exit to report status
        unit.exit()
        ---------------
        -- copy to here to unit.tick(timerId) stop
        ---------------
    end

    local tickResume = function()
        ---------------
        -- copy from here to unit.tick(timerId) resume
        ---------------
        assert(_G.receiverCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.receiverCoroutine) ~= "dead", "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.receiverCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
        ---------------
        -- copy to here to unit.tick(timerId) resume
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
    -- copy from here to unit.start
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getRange", "getChannels", "setChannels", "getSignalOut"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "ReceiverUnit")
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 13.27)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    assert(slot1.getRange() == 1000.0)

    allCount = 0
    messageFilterCount = 0
    channelFilterCount = 0

    local channelList = "unexpected, filtered, duMocks"
    slot1.setChannels(channelList)
    assert(slot1.getChannels() == channelList,
        string.format("Expected <%s> but got <%s>", channelList, slot1.getChannels()))

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
    -- copy to here to unit.start
    ---------------

    -- listener function called synchronously, by the time yield is called all processing is finished, so just resume
    tickResume()
    tickResume()
    tickResume()
    tickResume()

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(allCount == 3, allCount)
    assert(messageFilterCount == 1, messageFilterCount)
    assert(channelFilterCount == 1)

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end
    ---------------
    -- copy to here to unit.stop()
    ---------------
end

os.exit(lu.LuaUnit.run())
