#!/usr/bin/env lua
--- Tests on dumocks.ControlUnit.
-- @see dumocks.ControlUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.ControlUnit")

_G.TestControlUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestControlUnit.testConstructor()

    -- default element:
    -- ["programming board"] = {mass = 27.74, maxHitPoints = 50.0, class = "Generic"}

    local control0 = mcu:new()
    local control1 = mcu:new(nil, 1, "Programming Board")
    local control2 = mcu:new(nil, 2, "invalid")
    local control3 = mcu:new(nil, 3, "Hovercraft Seat")

    local controlClosure0 = control0:mockGetClosure()
    local controlClosure1 = control1:mockGetClosure()
    local controlClosure2 = control2:mockGetClosure()
    local controlClosure3 = control3:mockGetClosure()

    lu.assertEquals(controlClosure0.getId(), 0)
    lu.assertEquals(controlClosure1.getId(), 1)
    lu.assertEquals(controlClosure2.getId(), 2)
    lu.assertEquals(controlClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 27.74
    lu.assertEquals(controlClosure0.getMass(), defaultMass)
    lu.assertEquals(controlClosure1.getMass(), defaultMass)
    lu.assertEquals(controlClosure2.getMass(), defaultMass)
    lu.assertNotEquals(controlClosure3.getMass(), defaultMass)
end

--- Verify element class is correct.
function _G.TestControlUnit.testGetElementClass()
    local element

    element = mcu:new(nil, 1, "programming board"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "Generic")

    element = mcu:new(nil, 1, "hovercraft seat"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CockpitHovercraftUnit")

    element = mcu:new(nil, 1, "command seat controller"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CockpitCommandmentUnit")
end

--- Verify timers can be started.
function _G.TestControlUnit.testStartTimer()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    -- non-string timerId
    -- negative duration
    --TODO
    --lu.fail("NYI")
end

--- Verify getMasterPlayerId.
function _G.TestControlUnit.testGetMasterPlayerId()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local expected = 10
    mock.masterPlayerId = expected
    lu.assertEquals(closure.getMasterPlayerId(), expected)
end

--- Verify isRemoteControlled translates to numbers.
function _G.TestControlUnit.testIsRemoteControlled()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    mock.remoteControlled = false
    lu.assertEquals(closure.isRemoteControlled(), 0)

    mock.remoteControlled = true
    lu.assertEquals(closure.isRemoteControlled(), 1)
end

--- Verify tick works without errors.
function _G.TestControlUnit.testTick()
    local mock = mcu:new()

    local expected, actual
    local callback = function(timerId)
        actual = timerId
    end
    mock:mockRegisterTimer(callback, "*")

    expected = "Timer"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)

    expected = "Update"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)
end

--- Verify tick works with and propagates errors.
function _G.TestControlUnit.testTickError()
    local mock = mcu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function(_)
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterTimer(callbackError, "*")

    local callback2 = function(_)
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterTimer(callback2, "*")

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoTick, mock, "Update")
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)
end

--- Verify filtering on tick timerId works.
function _G.TestControlUnit.testTickFilter()
    local mock = mcu:new()

    local expected, actual
    local callback = function(id)
        actual = id
    end
    mock:mockRegisterTimer(callback, "Update")

    actual = nil
    expected = "Update"
    mock:mockDoTick(expected)
    lu.assertEquals(actual, expected)

    actual = nil
    expected = "Tick"
    mock:mockDoTick(expected)
    lu.assertNil(actual)
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestControlUnit.skipTestGameBehavior()
    local mock = mcu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "Generic")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())