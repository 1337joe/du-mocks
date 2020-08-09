#!/usr/bin/env lua
--- Tests on MockManualSwitchUnit
-- @see MockManualSwitchUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mmsu = require("MockManualSwitchUnit")

--- Verify constructor arguments properly handled and independent between instances.
function testConstructor()

    -- default element:
    -- ["Manual Switch"] = {mass = 13.27, maxHitPoints = 50.0}

    local switch1 = mmsu:new(nil, 1, "Manual Button")
    local switch2 = mmsu:new(nil, 2, "invalid")
    local switch3 = mmsu:new()

    local switch1Closure = switch1:getClosure()
    local switch2Closure = switch2:getClosure()
    local switch3Closure = switch3:getClosure()

    lu.assertEquals(switch1Closure.getId(), 1)
    lu.assertEquals(switch2Closure.getId(), 2)
    lu.assertEquals(switch3Closure.getId(), 0)

    -- prove default element is selected
    local defaultMass = 13.27
    lu.assertEquals(switch1Closure.getMass(), defaultMass)
    lu.assertEquals(switch2Closure.getMass(), defaultMass)
    lu.assertEquals(switch3Closure.getMass(), defaultMass)

    -- do some damage, max hit points is 50 (prove independance)
    switch1.hitPoints = 25.0
    switch2.hitPoints = 12.5
    switch3.hitPoints = 0.25

    lu.assertEquals(switch1Closure.getIntegrity(), 50.0)
    lu.assertEquals(switch2Closure.getIntegrity(), 25.0)
    lu.assertEquals(switch3Closure.getIntegrity(), 0.5)
end

--- Verify element class is correct.
function testGetElementClass()
    local element = mmsu:new():getClosure()
    lu.assertEquals(element.getElementClass(), "ManualSwitchUnit")
end

-- Verify activate results in enabled switch.
function testActivate()
    local switch = mmsu:new()
    local closure = switch:getClosure()

    switch.state = false
    closure.activate()
    lu.assertTrue(switch.state)

    switch.state = true
    closure.activate()
    lu.assertTrue(switch.state)
end

-- Verify deactivate results in disabled switch.
function testDeactivate()
    local switch = mmsu:new()
    local closure = switch:getClosure()

    switch.state = false
    closure.deactivate()
    lu.assertFalse(switch.state)

    switch.state = true
    closure.deactivate()
    lu.assertFalse(switch.state)
end

-- Verify toggle results in swapped switch.
function testToggle()
    local switch = mmsu:new()
    local closure = switch:getClosure()

    switch.state = false
    closure.toggle()
    lu.assertTrue(switch.state)

    switch.state = true
    closure.toggle()
    lu.assertFalse(switch.state)
end

-- Verify get state properly translated results.
function testGetState()
    local switch = mmsu:new()
    local closure = switch:getClosure()
    local actual

    switch.state = false
    actual = closure.getState()
    lu.assertEquals(actual, 0)

    switch.state = true
    actual = closure.getState()
    lu.assertEquals(actual, 1)
end

-- Verify callbacks can be registered and fire properly for `pressed()`.
function testDoPressedValid()
    local switch = mmsu:new()

    local pressed1Result = nil
    local pressed1Index = switch:mockRegisterPressed(function() pressed1Result = switch:getState() end)
    lu.assertNotNil(pressed1Index)

    switch.state = false -- ensure not pressed
    switch:mockDoPressed()

    lu.assertTrue(switch.state) -- turns on switch
    lu.assertEquals(pressed1Result, 1) -- fires handler after turning on
end

-- Verify callbacks are properly handled for invalid calls for `pressed()`.
function testDoPressedInvalid()
    local switch = mmsu:new()

    local pressed1Result = nil
    local pressed1Index = switch:mockRegisterPressed(function() pressed1Result = switch:getState() end)
    lu.assertNotNil(pressed1Index)

    switch.state = true -- invalid state, should do nothing
    switch:mockDoPressed()

    lu.assertTrue(switch.state) -- switch is still on
    lu.assertNil(pressed1Result) -- handler not fired
end

-- Verify callbacks can be registered and properly handle errors for `pressed()`.
function testDoPressedError()
    local switch = mmsu:new()

    local callbackNumber = 0

    -- second callback - is valid and should fire second
    local pressed1Message = "I have problems!"
    local pressed1CallOrder = nil
    local pressed1Callback = function()
        callbackNumber = callbackNumber + 1
        pressed1CallOrder = callbackNumber
        error(pressed1Message)
    end
    local pressed1Index = switch:mockRegisterPressed(pressed1Callback)
    lu.assertNotNil(pressed1Index)

    -- second callback - is valid and should fire second
    local pressed2CallOrder = nil
    local pressed2Callback = function()
        callbackNumber = callbackNumber + 1
        pressed2CallOrder = callbackNumber
    end
    local pressed2Index = switch:mockRegisterPressed(pressed2Callback)
    lu.assertNotNil(pressed2Index)

    switch.state = false -- ensure valid state
    local status,err = pcall(function() switch:mockDoPressed() end)

    -- threw error
    lu.assertFalse(status, "Should have thrown error.")
    -- verify error message from first callback propagated up
    lu.assertStrContains(err, pressed1Message)

     -- still turned on switch
    lu.assertTrue(switch.state)

    -- verify order and that second callback was reached
    lu.assertEquals(pressed1CallOrder, 1)
    lu.assertEquals(pressed2CallOrder, 2)
end

-- Verify callbacks can be registered and fire properly for `released()`.
function testDoReleasedValid()
    local switch = mmsu:new()

    local released1Result = nil
    local released1Index = switch:mockRegisterReleased(function() released1Result = switch:getState() end)
    lu.assertNotNil(released1Index)

    switch.state = true -- ensure pressed
    switch:mockDoReleased()

    lu.assertTrue(switch.state) -- turns off switch
    lu.assertEquals(released1Result, 1) -- fires handler before turning off
end

-- Verify callbacks are properly handled for invalid calls for `released()`.
function testDoReleasedInvalid()
    local switch = mmsu:new()

    local released1Result = nil
    local released1Index = switch:mockRegisterReleased(function() released1Result = switch:getState() end)
    lu.assertNotNil(released1Index)

    switch.state = false -- invalid state, should do nothing
    switch:mockDoReleased()

    lu.assertFalse(switch.state) -- switch is still on
    lu.assertNil(released1Result) -- handler not fired
end

-- Verify callbacks can be registered and properly handle errors for `released()`.
function testDoReleasedError()
    local switch = mmsu:new()

    local callbackNumber = 0

    -- second callback - is valid and should fire second
    local released1Message = "I have problems!"
    local released1CallOrder = nil
    local released1Callback = function()
        callbackNumber = callbackNumber + 1
        released1CallOrder = callbackNumber
        error(released1Message)
    end
    local released1Index = switch:mockRegisterReleased(released1Callback)
    lu.assertNotNil(released1Index)

    -- second callback - is valid and should fire second
    local released2CallOrder = nil
    local released2Callback = function()
        callbackNumber = callbackNumber + 1
        released2CallOrder = callbackNumber
    end
    local released2Index = switch:mockRegisterReleased(released2Callback)
    lu.assertNotNil(released2Index)

    switch.state = true -- ensure valid state
    local status,err = pcall(function() switch:mockDoReleased() end)

    -- threw error
    lu.assertFalse(status, "Should have thrown error.")
    -- verify error message from first callback propagated up
    lu.assertStrContains(err, released1Message)

     -- still turned on switch
    lu.assertTrue(switch.state)

    -- verify order and that second callback was reached
    lu.assertEquals(released1CallOrder, 1)
    lu.assertEquals(released2CallOrder, 2)
end

os.exit(lu.LuaUnit.run())