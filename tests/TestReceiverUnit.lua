#!/usr/bin/env lua
--- Tests on dumocks.ReceiverUnit.
-- @see dumocks.ReceiverUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mru = require("dumocks.ReceiverUnit")
require("tests.Utilities")

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
    -- TODO uncomment when Receiver S definition is in place
    -- lu.assertNotEquals(receiverClosure3.getMass(), defaultMass)
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

--- Verify unfiltered receive gets all messages.
function _G.TestReceiverUnit.testReceiveAll()
    local mock = mru:new()

    local expectedChannel, expectedMessage
    local actualChannel, actualMessage

    local callback = function(channel, message)
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "*", "*")

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)
end

--- Verify filtering on channel works.
function _G.TestReceiverUnit.testReceiveFilterChannel()
    local mock = mru:new()

    local expectedChannel, expectedMessage
    local actualChannel, actualMessage

    local callback = function(channel, message)
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "channel", "*")

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertNil(actualChannel)
    lu.assertNil(actualMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)
end

--- Verify filtering on messages works.
function _G.TestReceiverUnit.testReceiveFilterMessage()
    local mock = mru:new()

    local expectedChannel, expectedMessage
    local actualChannel, actualMessage

    local callback = function(channel, message)
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "*", "message")

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertNil(actualChannel)
    lu.assertNil(actualMessage)
end

--- Verify filtering on channel and message at the same time works.
function _G.TestReceiverUnit.testReceiveFilterBoth()
    local mock = mru:new()

    local expectedChannel, expectedMessage
    local actualChannel, actualMessage

    local callback = function(channel, message)
        actualChannel = channel
        actualMessage = message
    end
    mock:mockRegisterReceive(callback, "channel", "message")

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertEquals(actualChannel, expectedChannel)
    lu.assertEquals(actualMessage, expectedMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "filter"
    expectedMessage = "message"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertNil(actualChannel)
    lu.assertNil(actualMessage)

    actualChannel = nil
    actualMessage = nil
    expectedChannel = "channel"
    expectedMessage = "filter"
    mock:mockDoReceive(expectedChannel, expectedMessage)
    lu.assertNil(actualChannel)
    lu.assertNil(actualMessage)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Receiver XS, connected to Programming Board on slot1, default channel set to duMocks
-- 2. 1x Emitter XS, connected to Programming Board on slot2
--
-- Exercises: getElementClass, receive, getRange, setSignalOut
function _G.TestReceiverUnit.testGameBehavior()
    local mock = mru:new(nil, 1)
    local slot1 = mock:mockGetClosure()
    mock.defaultChannel = "duMocks"

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

    ---------------
    -- copy from here to unit.tick(timerId) stop
    ---------------
    -- exit to report status
    unit.exit()
    ---------------
    -- copy to here to unit.tick(timerId) stop
    ---------------

    local allCount, messageFilterCount, channelFilterCount

    local receiveAllListener = function(channel, message)
        ---------------
        -- copy from here to slot1.receive(channel,message) * *
        ---------------
        allCount = allCount + 1
        ---------------
        -- copy to here to slot1.receive(channel,message) * *
        ---------------
    end
    mock:mockRegisterReceive(receiveAllListener, "*", "*")

    local receiveChannelListener = function(channel, message)
        ---------------
        -- copy from here to slot1.receive(channel,message) duMocks *
        ---------------
        -- momentary on, if this isn't quick enough to catch the out signal send it to a switch and check that
        assert(slot1.getSignalOut("out") == 1.0)

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
    local expectedFunctions = {"getRange", "getSignalOut",
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "load"}
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "ReceiverUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 13.27)

    assert(slot1.getRange() == 100.0)

    allCount = 0
    messageFilterCount = 0
    channelFilterCount = 0

    slot2.send("unexpected", "unexpected")
    slot2.send("filtered", "message")
    slot2.send("duMocks", "filtered")

    -- all messages should be processed easily within 1 second
    unit.setTimer("stop", 0.25)
    ---------------
    -- copy to here to unit.start
    ---------------

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(allCount == 3, allCount)
    assert(messageFilterCount == 1)
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