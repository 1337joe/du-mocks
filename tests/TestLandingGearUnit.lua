#!/usr/bin/env lua
--- Tests on dumocks.LandingGearUnit.
-- @see dumocks.LandingGearUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mlgu = require("dumocks.LandingGearUnit")

_G.TestLandingGearUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestLandingGearUnit.testConstructor()

    -- default element:
    -- ["landing gear s"] = {mass = 258.76, maxHitPoints = 1045.0}

    local gear0 = mlgu:new()
    local gear1 = mlgu:new(nil, 1, "Landing Gear S")
    local gear2 = mlgu:new(nil, 2, "invalid")
    local gear3 = mlgu:new(nil, 3, "landing gear m")

    local gearClosure0 = gear0:mockGetClosure()
    local gearClosure1 = gear1:mockGetClosure()
    local gearClosure2 = gear2:mockGetClosure()
    local gearClosure3 = gear3:mockGetClosure()

    lu.assertEquals(gearClosure0.getId(), 0)
    lu.assertEquals(gearClosure1.getId(), 1)
    lu.assertEquals(gearClosure2.getId(), 2)
    lu.assertEquals(gearClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 258.76
    lu.assertEquals(gearClosure0.getMass(), defaultMass)
    lu.assertEquals(gearClosure1.getMass(), defaultMass)
    lu.assertEquals(gearClosure2.getMass(), defaultMass)
    lu.assertNotEquals(gearClosure3.getMass(), defaultMass)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Landing Gear, connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState, setSignalIn, getSignalIn
function _G.TestLandingGearUnit.testGameBehavior()
    local mock = mlgu:new(nil, 1, "landing gear xs")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"activate", "deactivate", "toggle", "getState", 
                               "show", "hide", "getData", "getDataId", "getWidgetType", "getIntegrity", "getHitPoints",
                               "getMaxHitPoints", "getId", "getMass", "getElementClass", "setSignalIn", "getSignalIn",
                               "load"}
    local unexpectedFunctions = {}
    for key, value in pairs(slot1) do
        if type(value) == "function" then
            for index, funcName in pairs(expectedFunctions) do
                if key == funcName then
                    table.remove(expectedFunctions, index)
                    goto continueOuter
                end
            end

            table.insert(unexpectedFunctions, key)
        end

        ::continueOuter::
    end
    local message = ""
    if #expectedFunctions > 0 then
        message = message .. "Missing expected functions: " .. table.concat(expectedFunctions, ", ") .. "\n"
    end
    if #unexpectedFunctions > 0 then
        message = message .. "Found unexpected functions: " .. table.concat(unexpectedFunctions, ", ") .. "\n"
    end
    assert(message:len() == 0, message)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "LandingGearUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() == 63.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() == 49.88)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.getState()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.5")
    assert(slot1.getSignalIn("in") == 0.5)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "7.0")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- invalid sets to 0
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)

    -- ensure initial state
    slot1.deactivate()
    assert(slot1.getState() == 0)

    -- validate methods
    slot1.activate()
    assert(slot1.getState() == 1)
    slot1.deactivate()
    assert(slot1.getState() == 0)
    slot1.toggle()
    assert(slot1.getState() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())