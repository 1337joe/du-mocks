#!/usr/bin/env lua
--- Tests on dumocks.LightUnit.
-- @see dumocks.LightUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mlu = require("dumocks.LightUnit")
local utilities = require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestLightUnit = AbstractTestElementWithToggle

function _G.TestLightUnit.getTestElement()
    return mlu:new()
end

function _G.TestLightUnit.getStateFunction(closure)
    return closure.isActive
end

function _G.TestLightUnit.getActivateFunction(closure)
    return closure.activate
end

function _G.TestLightUnit.getDeactivateFunction(closure)
    return closure.deactivate
end

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLightUnit.testConstructor()

    -- default element:
    -- ["square light xs"] = {mass = 70.05, maxHitPoints = 50.0, itemId = 177821174}

    local light0 = mlu:new()
    local light1 = mlu:new(nil, 1, "Square Light XS")
    local light2 = mlu:new(nil, 2, "invalid")
    local light3 = mlu:new(nil, 3, "square light l")

    local lightClosure0 = light0:mockGetClosure()
    local lightClosure1 = light1:mockGetClosure()
    local lightClosure2 = light2:mockGetClosure()
    local lightClosure3 = light3:mockGetClosure()

    lu.assertEquals(lightClosure0.getLocalId(), 0)
    lu.assertEquals(lightClosure1.getLocalId(), 1)
    lu.assertEquals(lightClosure2.getLocalId(), 2)
    lu.assertEquals(lightClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 70.05
    lu.assertEquals(lightClosure0.getMass(), defaultMass)
    lu.assertEquals(lightClosure1.getMass(), defaultMass)
    lu.assertEquals(lightClosure2.getMass(), defaultMass)
    lu.assertNotEquals(lightClosure3.getMass(), defaultMass)

    local defaultId = 177821174
    lu.assertEquals(lightClosure0.getItemId(), defaultId)
    lu.assertEquals(lightClosure1.getItemId(), defaultId)
    lu.assertEquals(lightClosure2.getItemId(), defaultId)
    lu.assertNotEquals(lightClosure3.getItemId(), defaultId)
end

--- Test inputs to setColor.
function _G.TestLightUnit.testSetColor()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    closure.setColor(0, 0, 0)
    lu.assertEquals(mock.color, {r = 0, g = 0, b = 0})
    lu.assertEquals(utilities.verifyDeprecated("setRGBColor", closure.setRGBColor, 0, 0, 0))
    lu.assertEquals(mock.color, {r = 0, g = 0, b = 0})

    closure.setColor(1, -1, 8)
    lu.assertEquals(mock.color, {r = 1, g = 0, b = 5})
    lu.assertEquals(utilities.verifyDeprecated("setRGBColor", closure.setRGBColor, 255, -255, 5000))
    lu.assertEquals(mock.color, {r = 1, g = 0, b = 5})
end

--- Test results from getColor.
function _G.TestLightUnit.testGetColor()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    -- default in valid range
    lu.assertEquals(closure.getColor(), {1, 1, 1})
    lu.assertEquals(utilities.verifyDeprecated("getRGBColor", closure.getRGBColor), {255, 255, 255})

    mock.color = {r = 5, g = 2, b = 0}
    lu.assertEquals(closure.getColor(), {5, 2, 0})
    lu.assertEquals(utilities.verifyDeprecated("getRGBColor", closure.getRGBColor), {1275, 510, 0})
end

--- Test inputs to setBlinkingState.
function _G.TestLightUnit.testSetBlinkingState()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.blinking = false

    -- expected inputs
    closure.setBlinkingState(true)
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState(true)
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState(false)
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(false)
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(1)
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState(0)
    lu.assertFalse(mock.blinking)

    -- unexpected false inputs
    closure.setBlinkingState("true")
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState("false")
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState("0.0")
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState("words")
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(nil)
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(-1.5)
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(0.5)
    lu.assertFalse(mock.blinking)
    closure.setBlinkingState(1.5)
    lu.assertFalse(mock.blinking)

    -- unexpected true inputs
    closure.setBlinkingState(-1.0)
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState("-2.0")
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState(2.0)
    lu.assertTrue(mock.blinking)
    closure.setBlinkingState("1.0")
    lu.assertTrue(mock.blinking)
end

--- Test function of isBlinking.
function _G.TestLightUnit.testIsBlinking()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.blinking = true
    lu.assertEquals(closure.isBlinking(), 1)

    mock.blinking = false
    lu.assertEquals(closure.isBlinking(), 0)
end

--- Test functionality of getOnBlinkingDuration.
function _G.TestLightUnit.testGetOnBlinkingDuration()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.blinkingOn = 1
    lu.assertEquals(closure.getOnBlinkingDuration(), 1)

    mock.blinkingOn = 0
    lu.assertEquals(closure.getOnBlinkingDuration(), 0)

    mock.blinkingOn = 100000
    lu.assertEquals(closure.getOnBlinkingDuration(), 100000)
end

--- Test functionality of setOnBlinkingDuration.
function _G.TestLightUnit.testSetOnBlinkingDuration()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    closure.setOnBlinkingDuration(1)
    lu.assertEquals(mock.blinkingOn, 1)

    closure.setOnBlinkingDuration(1.5)
    lu.assertEquals(mock.blinkingOn, 1.5)

    closure.setOnBlinkingDuration(0)
    lu.assertEquals(mock.blinkingOn, 0)

    closure.setOnBlinkingDuration(100000)
    lu.assertEquals(mock.blinkingOn, 100000)

    closure.setOnBlinkingDuration("1.0")
    lu.assertEquals(mock.blinkingOn, 1.0)

    closure.setOnBlinkingDuration(nil)
    lu.assertEquals(mock.blinkingOn, 0)

    closure.setOnBlinkingDuration(-1)
    lu.assertEquals(mock.blinkingOn, 0)
end

--- Test functionality of getOffBlinkingDuration.
function _G.TestLightUnit.testGetOffBlinkingDuration()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.blinkingOff = 1
    lu.assertEquals(closure.getOffBlinkingDuration(), 1)

    mock.blinkingOff = 0
    lu.assertEquals(closure.getOffBlinkingDuration(), 0)

    mock.blinkingOff = 100000
    lu.assertEquals(closure.getOffBlinkingDuration(), 100000)
end

--- Test functionality of setOffBlinkingDuration.
function _G.TestLightUnit.testSetOffBlinkingDuration()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    closure.setOffBlinkingDuration(1)
    lu.assertEquals(mock.blinkingOff, 1)

    closure.setOffBlinkingDuration(1.5)
    lu.assertEquals(mock.blinkingOff, 1.5)

    closure.setOffBlinkingDuration(0)
    lu.assertEquals(mock.blinkingOff, 0)

    closure.setOffBlinkingDuration(100000)
    lu.assertEquals(mock.blinkingOff, 100000)

    closure.setOffBlinkingDuration("1.0")
    lu.assertEquals(mock.blinkingOff, 1.0)

    closure.setOffBlinkingDuration(nil)
    lu.assertEquals(mock.blinkingOff, 0)

    closure.setOffBlinkingDuration(-1)
    lu.assertEquals(mock.blinkingOff, 0)
end

--- Test functionality of getBlinkingTimeShift.
function _G.TestLightUnit.testGetBlinkingTimeShift()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    mock.blinkingShift = 1
    lu.assertEquals(closure.getBlinkingTimeShift(), 1)

    mock.blinkingShift = 0
    lu.assertEquals(closure.getBlinkingTimeShift(), 0)

    mock.blinkingShift = 100000
    lu.assertEquals(closure.getBlinkingTimeShift(), 100000)
end

--- Test functionality of setBlinkingTimeShift.
function _G.TestLightUnit.testSetBlinkingTimeShift()
    local mock = mlu:new()
    local closure = mock:mockGetClosure()

    closure.setBlinkingTimeShift(1)
    lu.assertEquals(mock.blinkingShift, 1)

    closure.setBlinkingTimeShift(1.5)
    lu.assertEquals(mock.blinkingShift, 1.5)

    closure.setBlinkingTimeShift(0)
    lu.assertEquals(mock.blinkingShift, 0)

    closure.setBlinkingTimeShift(100000)
    lu.assertEquals(mock.blinkingShift, 100000)

    closure.setBlinkingTimeShift("1.0")
    lu.assertEquals(mock.blinkingShift, 1.0)

    closure.setBlinkingTimeShift(nil)
    lu.assertEquals(mock.blinkingShift, 0)

    closure.setBlinkingTimeShift(-1)
    lu.assertEquals(mock.blinkingShift, 0)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Square Light XS, connected to Programming Board on slot1
--
-- Exercises: getClass, deactivate, activate, toggle, isActive, getColor, setColor, isBlinking, setBlinking, setSignalIn, getSignalIn
function _G.TestLightUnit.testGameBehavior()
    local mock = mlu:new(nil, 1, "square light xs")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"isActive", "setRGBColor", "setColor", "getRGBColor", "getColor", "setBlinkingState",
                               "isBlinking", "getOnBlinkingDuration", "setOnBlinkingDuration",
                               "getOffBlinkingDuration", "setOffBlinkingDuration", "getBlinkingTimeShift",
                               "setBlinkingTimeShift", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "LightUnit")
    assert(string.match(string.lower(slot1.getName()), "square light %w+ %[%d+%]"), slot1.getName())
    local expectedId = {[177821174] = true}
    assert(expectedId[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())

    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 70.05)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.isActive()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)
    slot1.setSignalIn("in", "1.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.isActive() == initialState)

    -- ensure initial state
    slot1.deactivate()
    assert(slot1.isActive() == 0)

    -- validate methods
    slot1.activate()
    assert(slot1.isActive() == 1)
    slot1.deactivate()
    assert(slot1.isActive() == 0)
    slot1.toggle()
    assert(slot1.isActive() == 1)

    -- handle float comparisons
    local epsilon = 0.0001
    local colorVec
    slot1.setColor(-1, "bad", nil)
    colorVec = slot1.getColor()
    assert(colorVec[1] == 0, "r: " ..colorVec[1])
    assert(colorVec[2] == 0, "g: " ..colorVec[2])
    assert(colorVec[3] == 0, "b: " ..colorVec[3])
    slot1.setColor(1.1, 4.5, 6.0)
    colorVec = slot1.getColor()
    assert(math.abs(1.1 - colorVec[1]) < epsilon, "r: " ..colorVec[1])
    assert(math.abs(4.5 - colorVec[2]) < epsilon, "g: " ..colorVec[2])
    assert(math.abs(5.0 - colorVec[3]) < epsilon, "b: " ..colorVec[3])

    slot1.setBlinkingState(true)
    assert(slot1.isBlinking() == 1)
    slot1.setBlinkingState(false)
    assert(slot1.isBlinking() == 0)
    slot1.setBlinkingState(1)
    assert(slot1.isBlinking() == 1)
    slot1.setBlinkingState(0)
    assert(slot1.isBlinking() == 0)

    slot1.setOnBlinkingDuration(5.5)
    assert(slot1.getOnBlinkingDuration() == 5.5)
    slot1.setOnBlinkingDuration(0)
    assert(slot1.getOnBlinkingDuration() == 0)

    slot1.setOffBlinkingDuration(5.5)
    assert(slot1.getOffBlinkingDuration() == 5.5)
    slot1.setOffBlinkingDuration(0)
    assert(slot1.getOffBlinkingDuration() == 0)

    slot1.setBlinkingTimeShift(5.5)
    assert(slot1.getBlinkingTimeShift() == 5.5)
    slot1.setBlinkingTimeShift(0)
    assert(slot1.getBlinkingTimeShift() == 0)

    system.print("Success")
    slot1.deactivate();
    unit.exit()
    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
