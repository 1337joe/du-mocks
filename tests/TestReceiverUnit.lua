#!/usr/bin/env lua
--- Tests on dumocks.ReceiverUnit.
-- @see dumocks.ReceiverUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mru = require("dumocks.ReceiverUnit")

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

--- Verify element class is correct.
function _G.TestReceiverUnit.testGetElementClass()
    local element = mru:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "ReceiverUnit")
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

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestReceiverUnit.skipTestGameBehavior()
    local mock = mru:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "ReceiverUnit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())