#!/usr/bin/env lua
--- Tests on dumocks.AntiGravityGeneratorUnit.
-- @see dumocks.AntiGravityGeneratorUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local maggu = require("dumocks.AntiGravityGeneratorUnit")
require("test.Utilities")
local AbstractTestElementWithToggle = require("test.dumocks.AbstractTestElementWithToggle")

_G.TestAntiGravityGeneratorUnit = AbstractTestElementWithToggle

function _G.TestAntiGravityGeneratorUnit.getTestElement()
    return maggu:new()
end

function _G.TestAntiGravityGeneratorUnit.getStateFunction(closure)
    return closure.isActive
end

function _G.TestAntiGravityGeneratorUnit.getActivateFunction(closure)
    return closure.activate
end

function _G.TestAntiGravityGeneratorUnit.getDeactivateFunction(closure)
    return closure.deactivate
end

--- Verify that set base altitude properly sets a value within the agg limits.
function _G.TestAntiGravityGeneratorUnit.testSetBaseAltitude()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    local expected

    mock.targetAltitude = 1000

    expected = 1600
    closure.setBaseAltitude(expected)
    lu.assertEquals(mock.targetAltitude, expected)
    lu.assertNotEquals(mock.baseAltitude, expected)

    expected = 16000
    closure.setBaseAltitude(expected)
    lu.assertEquals(mock.targetAltitude, expected)
    lu.assertNotEquals(mock.baseAltitude, expected)

    expected = 1000
    closure.setBaseAltitude(500)
    lu.assertEquals(mock.targetAltitude, expected)
    lu.assertNotEquals(mock.baseAltitude, expected)
end

--- Verify that get base altitude returns properly.
function _G.TestAntiGravityGeneratorUnit.testGetBaseAltitude()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    local expected, actual

    expected = 2000
    mock.baseAltitude = expected
    actual = closure.getBaseAltitude()
    lu.assertEquals(actual, expected)

    expected = 1234.5
    mock.baseAltitude = expected
    actual = closure.getBaseAltitude()
    lu.assertEquals(actual, expected)
end

function _G.TestAntiGravityGeneratorUnit.testStepBaseAltitude()
    local mock = maggu:new()
    local closure = mock:mockGetClosure()

    local expected, actual

    mock.targetAltitude = 5000
    mock.baseAltitude = 10000

    -- 1 full second decrease
    expected = 9996
    mock:mockStepBaseAltitude()
    lu.assertEquals(mock.baseAltitude, expected)

    -- >1, not full second decrease
    expected = 9954
    mock:mockStepBaseAltitude(10.5)
    lu.assertEquals(mock.baseAltitude, expected)

    -- decrease all the way to target
    expected = 5000
    mock:mockStepBaseAltitude(2000)
    lu.assertEquals(mock.baseAltitude, expected)

    -- half-step increase to target
    mock.baseAltitude = 4998
    expected = 5000
    mock:mockStepBaseAltitude()
    lu.assertEquals(mock.baseAltitude, expected)
end

--- Verify format and content of getWidgetData string.
function _G.TestAntiGravityGeneratorUnit.testGetWidgetData()
    local mock = maggu:new(nil, 2)
    local closure = mock:mockGetClosure()

    mock.baseAltitude = 1217.0
    mock.antiGravityField = 1.2000000178813932
    mock.antiGravityPower = 0.38769580129994552

    local data = closure.getWidgetData()
    lu.assertStrContains(data, '"name":"anti-gravity generator s [2]"')
    lu.assertStrContains(data, '"type":"antigravity_generator"')
    lu.assertStrContains(data, '"helperId":"antigravity_generator"')
    lu.assertStrContains(data, '"showError":false')
    lu.assertStrContains(data, '"antiGPower":0.38769580129994552')
    lu.assertStrContains(data, '"antiGravityField":1.2000000178813932')
    lu.assertStrContains(data, '"baseAltitude":1217.0')
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Anti-Gravity Generator S, connected to Programming Board on slot1
--
-- Exercises: getClass, getData, deactivate, activate, toggle, isActive, setSignalIn, getSignalIn,
-- setBaseAltitude, getBaseAltitude
function _G.TestAntiGravityGeneratorUnit.testGameBehavior()
    local mock = maggu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.setTimer = function(_, _)
    end
    unit.getWidgetData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function(_)
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"isActive", "getCompensationRate", "getFieldPower", "getFieldStrength",
                               "getPulsorCount", "getTargetAltitude", "setTargetAltitude", "getBaseAltitude",
                               "setBaseAltitude", "setSignalIn", "getSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "AntiGravityGeneratorUnit")
    assert(string.match(string.lower(slot1.getName()), "anti%-gravity generator %w+ %[%d+%]"), slot1.getName())
    local expectedId = {[3997343699] = true, [233079829] = true, [294414265] = true}
    assert(expectedId[slot1.getItemId()], "Unexpected id: " .. slot1.getItemId())

    local data = slot1.getWidgetData()
    local expectedFields = {"antiGPower", "antiGravityField", "baseAltitude", "helperId", "name", "showError", "type"}
    local expectedValues = {}
    expectedValues["helperId"] = '"antigravity_generator"'
    expectedValues["type"] = '"antigravity_generator"'
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() == 43117.0)
    assert(slot1.getMass() == 27134.86)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3, "antigravity_generator")

    _G.initialState = slot1.isActive()
    _G.initialBase = slot1.getBaseAltitude()

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

    -- TODO test target altitude bounds - is there a min height, max height?

    _G.base1 = slot1.getBaseAltitude()
    assert(base1 >= 1000.0)
    slot1.setBaseAltitude(base1 + 100)
    local base2 = slot1.getBaseAltitude()
    -- can't have moved far, if at all
    assert(base2 - base1 < 0.01)

    -- wait for base to change
    unit.setTimer("base", 1)
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    -- simulate time passing
    mock:mockStepBaseAltitude(1)

    ---------------
    -- copy from here to unit.tick(timerId) base
    ---------------
    -- will test result in stop code
    unit.exit() -- run stop to report final result
    ---------------
    -- copy to here to unit.tick(timerId) base
    ---------------

    ---------------
    -- copy from here to unit.onStop()
    ---------------
    local base3 = slot1.getBaseAltitude()
    -- 1s of movement should be about 4 meters
    assert(4 - math.abs(base3 - base1) < 0.1, "Should have gone ~4 meters from " .. base1 .. " to " .. base3)

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getWidgetData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end

    -- restore initial state
    if initialState == 1.0 then
        slot1.activate()
    else
        slot1.deactivate()
    end
    slot1.setBaseAltitude(initialBase)
    ---------------
    -- copy to here to unit.onStop()
    ---------------
end

os.exit(lu.LuaUnit.run())
