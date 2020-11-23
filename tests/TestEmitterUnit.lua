#!/usr/bin/env lua
--- Tests on dumocks.EmitterUnit.
-- @see dumocks.EmitterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local meu = require("dumocks.EmitterUnit")
require("tests.Utilities")

_G.TestEmitterUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestEmitterUnit.testConstructor()

    -- default element:
    -- ["emitter xs"] = {mass = 69.31, maxHitPoints = 50.0, range = 100.0}

    local emitter0 = meu:new()
    local emitter1 = meu:new(nil, 1, "Emitter XS")
    local emitter2 = meu:new(nil, 2, "invalid")
    local emitter3 = meu:new(nil, 3, "Emitter S")

    local emitterClosure0 = emitter0:mockGetClosure()
    local emitterClosure1 = emitter1:mockGetClosure()
    local emitterClosure2 = emitter2:mockGetClosure()
    local emitterClosure3 = emitter3:mockGetClosure()

    lu.assertEquals(emitterClosure0.getId(), 0)
    lu.assertEquals(emitterClosure1.getId(), 1)
    lu.assertEquals(emitterClosure2.getId(), 2)
    lu.assertEquals(emitterClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 69.31
    lu.assertEquals(emitterClosure0.getMass(), defaultMass)
    lu.assertEquals(emitterClosure1.getMass(), defaultMass)
    lu.assertEquals(emitterClosure2.getMass(), defaultMass)
    -- TODO uncomment when Emitter S definition is in place
    -- lu.assertNotEquals(emitterClosure3.getMass(), defaultMass)
end

--- Verify send works properly in optimal (non-error) conditions.
function _G.TestEmitterUnit.testSend()
    local mock = meu:new()
    local closure = mock:mockGetClosure()

    local calledChannel = nil
    local calledMessage = nil
    local callback = function(channel, message)
        calledChannel = channel
        calledMessage = message
    end
    mock:mockRegisterReceiver(callback)

    lu.assertNil(calledChannel)
    lu.assertNil(calledMessage)

    local expectedChannel = "channel"
    local expectedMessage = "message"
    closure.send(expectedChannel, expectedMessage)
    lu.assertEquals(calledChannel, expectedChannel)
    lu.assertEquals(calledMessage, expectedMessage)
end

--- Verify send hits all callbacks in error conditions (suppressing errors received).
function _G.TestEmitterUnit.testSendErrorSuppress()
    local mock = meu:new()
    local closure = mock:mockGetClosure()

    local called1 = false
    local called2 = false
    local callback1 = function(_, _)
        called1 = true
        error("Callback 1 is broken!")
    end
    mock:mockRegisterReceiver(callback1)
    local callback2 = function(_, _)
        called2 = true
        error("Callback 2 is not to be trusted either")
    end
    mock:mockRegisterReceiver(callback2)

    mock.propagateSendErrors = false

    lu.assertFalse(called1)
    lu.assertFalse(called2)
    closure.send("channel", "message")
    lu.assertTrue(called1)
    lu.assertTrue(called2)
end

--- Verify send hits all callbacks in error conditions (propagating errors received).
function _G.TestEmitterUnit.testSendErrorPropagate()
    local mock = meu:new()
    local closure = mock:mockGetClosure()

    local called1 = false
    local called2 = false
    local callback1 = function(_, _)
        called1 = true
        error("Callback 1 is broken!")
    end
    mock:mockRegisterReceiver(callback1)
    local callback2 = function(_, _)
        called2 = true
        error("Callback 2 is not to be trusted either")
    end
    mock:mockRegisterReceiver(callback2)

    mock.propagateSendErrors = true

    lu.assertFalse(called1)
    lu.assertFalse(called2)
    lu.assertError(closure.send, "channel", "message")
    lu.assertTrue(called1)
    lu.assertTrue(called2)
end

--- Verify get range retrieves range properly.
function _G.TestEmitterUnit.testGetRange()
    local mock = meu:new()
    local closure = mock:mockGetClosure()

    mock.range = 50.0
    lu.assertEquals(closure.getRange(), 50.0)

    mock.range = 100.0
    lu.assertEquals(closure.getRange(), 100.0)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Emitter XS, connected to Programming Board on slot1, default channel set to duMocks
-- 2. 1x Receiver XS, connected to Programming Board on slot2
--
-- Exercises: getElementClass, send, getRange, setSignalIn, getSignalIn
function _G.TestEmitterUnit.testGameBehavior()
    local mock = meu:new(nil, 1)
    local slot1 = mock:mockGetClosure()
    mock.defaultChannel = "duMocks"

    -- fake coroutine: uncomment to allow errors to immediately propagate up
    -- coroutine = {}
    -- function coroutine.create(func)
    --     coroutine.myFunc = func
    -- end
    -- function coroutine.resume()
    --     coroutine.myFunc()
    --     coroutine.resume = function() end
    -- end
    -- function coroutine.yield()
    -- end

    local finished = false

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    unit.setTimer = function()
    end
    local system = {}
    system.print = function(msg)
        lu.assertStrContains(msg, "Success")
        finished = true
    end

    local tickFail = function()
        ---------------
        -- copy from here to unit.tick(timerId) fail
        ---------------
        -- should hit exit call from coroutine before this ticks, indicates some call didn't get received
        system.print("Failed")
        unit.exit()
        ---------------
        -- copy to here to unit.tick(timerId) fail
        ---------------
    end

    local tickResume = function()
        ---------------
        -- copy from here to unit.tick(timerId) resume
        ---------------
        assert(_G.emitterCoroutine, "Coroutine must exist when resume is called.")
        assert(coroutine.status(_G.emitterCoroutine) ~= "dead", "Coroutine should not be dead when resume is called.")

        -- resume routine only when expected call has been received and processed
        local ok, message = coroutine.resume(_G.emitterCoroutine)
        assert(ok, string.format("Error resuming coroutine: %s", message))
        ---------------
        -- copy to here to unit.tick(timerId) resume
        ---------------
    end

    local receiveListener = function(channel, message)
        ---------------
        -- copy from here to slot2.receive(channel,message) * *
        ---------------
        if _G.send then
            assert(channel:len() <= 512, string.format("Channel longer than expected max: %d", channel:len()))
            assert(message:len() > 0, "Message was empty.")
            assert(message:len() <= 512, string.format("Message longer than expected max: %d", message:len()))
        elseif _G.signals then
            local actualSignal = slot1.getSignalIn("in")
            assert(actualSignal == _G.expectedSignal, string.format("Did not match expected signal (%s): %s", _G.expectedSignal, actualSignal))
            assert(channel == "duMocks", string.format("Default channel was: %s", channel))
            assert(message == "*", string.format("Message was: %s", message))

            -- emitter sends one message on signal in ~= 0 and a second message when the value also changed
            if _G.expectedCall then
                if _G.repeatSignal == actualSignal then
                    -- not changed, won't repeat
                    _G.repeatSignal = nil
                else
                    _G.repeatSignal = actualSignal
                end
            elseif _G.repeatSignal == actualSignal then
                _G.expectedCall = true
                _G.repeated = true
            end
        end

        -- check and reset expected call flag
        assert(_G.expectedCall, string.format("Failed on %s", _G.expectedSignal))
        _G.expectedCall = false

        unit.setTimer("resume", 0.5)
        ---------------
        -- copy to here to slot2.receive(channel,message) * *
        ---------------
    end
    mock:mockRegisterReceiver(receiveListener)
    mock.propagateSendErrors = true

    ---------------
    -- copy from here to unit.start
    ---------------
    -- verify expected functions
    local expectedFunctions = {"send", "getRange",
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "setSignalIn", "getSignalIn",
                               "load"}
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "EmitterUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 69.31)

    assert(slot1.getRange() == 100.0)

    -- set flag to indicate expected, wait for receiver to reactivate coroutine
    local function awaitReceive()
        coroutine.yield()
        assert(not _G.expectedCall)
    end

    local function setSignalAndWait(signal, expected)
        expected = expected or signal
        _G.expectedSignal = expected
        _G.expectedCall = true
        slot1.setSignalIn("in", signal)
        local actualSignal = slot1.getSignalIn("in")
        assert(actualSignal == expected, string.format("Set %s and expected %s but got %s", signal, expected, actualSignal))
        awaitReceive()
    end

    local function messagingTest()
        _G.expectedCall = false

        -- test send function
        _G.send = true

        _G.expectedCall = true
        slot1.send("channel", "message")
        awaitReceive()

        -- test max message length
        local tenChars = "1234567890"
        local message = string.rep(tenChars, 100)
        assert(message:len() > 512)
        _G.expectedCall = true
        slot1.send(message, message)
        awaitReceive()

        _G.send = false

        -- play with set signal
        -- non-zero values will send * to the default channel, if the value is changed it will send a duplicate message
        -- allows for and reports repeats but doesn't require them
        _G.signals = true
        _G.repeated = false
        local repeatedCount = 0

        slot1.setSignalIn("in", 0.0)
        assert(slot1.getSignalIn("in") == 0.0)

        setSignalAndWait(1.0)
        if _G.repeated then
            repeatedCount = repeatedCount + 1
        end
        _G.repeated = false

        -- fractions within [0,1] work, and string numbers are cast
        setSignalAndWait(0.7)
        if _G.repeated then
            repeatedCount = repeatedCount + 1
        end
        _G.repeated = false

        -- repeat still sends once
        setSignalAndWait(0.7)
        assert(not _G.repeated)

        setSignalAndWait(0.5)
        if _G.repeated then
            repeatedCount = repeatedCount + 1
        end
        _G.repeated = false

        slot1.setSignalIn("in", "0.0")
        assert(slot1.getSignalIn("in") == 0.0)
        -- doesn't send

        setSignalAndWait("7.0", 1.0)
        if _G.repeated then
            repeatedCount = repeatedCount + 1
        end
        _G.repeated = false

        -- invalid sets to 0 and doesn't send
        slot1.setSignalIn("in", "text")
        assert(slot1.getSignalIn("in") == 0.0)
        slot1.setSignalIn("in", nil)
        assert(slot1.getSignalIn("in") == 0.0)

        _G.signals = false

        -- multi-part script, can't just print success because end of script was reached
        if string.find(unit.getData(), '"showScriptError":false') then
            system.print(string.format("Success with %d repeats", repeatedCount))
        else
            system.print("Failed")
        end
        unit.exit()
    end

    _G.emitterCoroutine = coroutine.create(messagingTest)
    coroutine.resume(_G.emitterCoroutine)

    -- report failure if coroutine has not reached success within 1 second
    unit.setTimer("fail", 5)
    ---------------
    -- copy to here to unit.start
    ---------------

    -- listener function called synchronously, by the time yield is called all processing is finished, so just resume
    tickResume()
    tickResume()
    tickResume()
    tickResume()
    tickResume()
    tickResume()
    tickResume()

    lu.assertTrue(finished)
end

os.exit(lu.LuaUnit.run())