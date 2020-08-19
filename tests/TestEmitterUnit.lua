#!/usr/bin/env lua
--- Tests on dumocks.EmitterUnit.
-- @see dumocks.EmitterUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local meu = require("dumocks.EmitterUnit")

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

--- Verify element class is correct.
function _G.TestEmitterUnit.testGetElementClass()
    local element = meu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "EmitterUnit")
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

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestEmitterUnit.skipTestGameBehavior()
    local mock = meu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(false, "Not Yet Implemented")

    assert(slot1.getElementClass() == "EmitterUnit")

    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())