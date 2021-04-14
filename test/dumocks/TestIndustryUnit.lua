#!/usr/bin/env lua
--- Tests on dumocks.IndustryUnit.
-- @see dumocks.IndustryUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local miu = require("dumocks.IndustryUnit")
require("test.Utilities")

TestIndustryUnit = {}

--- Verify element class is correct.
function TestIndustryUnit.testGetElementClass()
    local element = miu:new():mockGetClosure()
    lu.assertEquals(element.getElementClass(), "IndustryUnit")
end

function TestIndustryUnit.testStart()
    local mock = miu:new()
    local closure = mock:mockGetClosure()

    -- verify default state is stopped
    lu.assertEquals(closure.getStatus(), miu.status.STOPPED)

    -- nominal - goes to running
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.RUNNING)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = false
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = false
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = false
    mock.hasInputIngredients = false
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing output
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = false
    mock.hasOutputSpace = true
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.RUNNING)

    -- not nominal - missing output space
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = false
    closure.start()
    lu.assertEquals(closure.getStatus(), miu.status.RUNNING)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run 
-- in-game.
--
-- Test setup:
-- 1. 2x Container XS, 2x Transfer Unit, link in a loop.
-- 2. Put 100x Pure Oxygen in a container and select recipe "Pure Oxygen" in both Transfer Units.
-- 3. Transfer Unit 1 is linked to Programming Board on slot1.
-- 4. Transfer Unit 2 is set to run infinitely.
--
-- Exercises: batchStart, softStop, getStatus, getCycleCountSinceStartup, getEfficiency, getUptime, EVENT_completed,
-- EVENT_statusChanged (with and without filter)
function TestIndustryUnit.testGameBehavior()
    local mock = miu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {
        getData = function()
            return '"showScriptError":false'
        end,
        exit = function()
        end
    }
    local system = {}
    system.print = function()
    end

    -- use locals here since all code is in this method
    local completedCallCount, statusChangedCallCount

    -- completed handlers
    local completedHandler1 = function()
        ---------------
        -- copy from here to slot1.completed()
        ---------------
        completedCallCount = completedCallCount + 1
        assert(completedCallCount % 2 == 1, "Should always be odd - first in call queue.")
        assert(slot1.getStatus() == "RUNNING")
        assert(slot1.getCycleCountSinceStartup() == math.floor(completedCallCount / 2) + 1)

        if slot1.getCycleCountSinceStartup() == 1 then
            assert(math.abs(slot1.getUptime() - 10.0) < 3.0,
                "10s recipe: expected < 3.0s deviance, are you lagging? " .. slot1.getUptime())
            assert(slot1.getEfficiency() > 0.9 and slot1.getEfficiency() <= 1.0,
                "Expected high efficiency due to supplies already on hand, are you lagging? " .. slot1.getEfficiency())

            assert(statusChangedCallCount == 1, "Only RUNNING state change should be first: " .. statusChangedCallCount)
        else
            -- generous padding due to how slow the server can be to update industry units
            assert(math.abs(slot1.getUptime() - 30.0) < 10.0,
                "10s recipe: expected < 10s deviance after 3 runs, are you lagging? " .. slot1.getUptime())
            assert(slot1.getEfficiency() > 0.5 and slot1.getEfficiency() <= 0.70,
                "~30 seconds to do 2x 10 second jobs, expect ~0.66 efficiency: " .. slot1.getEfficiency())

            assert(statusChangedCallCount == 3, "Only RUNNING state change should be first: " .. statusChangedCallCount)
        end
        ---------------
        -- copy to here to slot1.completed()
        ---------------
    end
    local completedHandler2 = function()
        ---------------
        -- copy from here to slot1.completed()
        ---------------
        completedCallCount = completedCallCount + 1
        assert(completedCallCount % 2 == 0, "Should always be even - second in call queue.")
        ---------------
        -- copy to here to slot1.completed()
        ---------------
    end
    mock:mockRegisterCompleted(completedHandler1)
    mock:mockRegisterCompleted(completedHandler2)

    -- status changed handlers
    local statusChangedHandler = function(status)
        ---------------
        -- copy from here to slot1.statusChanged(status): *
        ---------------
        statusChangedCallCount = statusChangedCallCount + 1
        assert(slot1.getStatus() == status)
        if statusChangedCallCount == 1 or statusChangedCallCount == 3 then
            assert(status == "RUNNING", status)
            -- TODO game behavior currently unsupported in mock
            -- assert(slot1.getEfficiency() == 0.0,
            --     "Odd, but 0.0 is expected game behavior here: " .. slot1.getEfficiency())
        elseif statusChangedCallCount == 2 then
            assert(status == "JAMMED_MISSING_INGREDIENT", status)
        else
            assert(status == "STOPPED", status)
        end

        if statusChangedCallCount == 3 then
            slot1.softStop()
        end
        ---------------
        -- copy to here to slot1.statusChanged(status): *
        ---------------
    end
    local statusChangedStoppedHandler = function(status)
        ---------------
        -- copy from here to slot1.statusChanged(status): STOPPED
        ---------------
        statusChangedCallCount = statusChangedCallCount + 1
        assert(status == "STOPPED", "Should only be called on stop event.")
        assert(slot1.getCycleCountSinceStartup() == 2, slot1.getCycleCountSinceStartup())
        assert(completedCallCount == 4, "Should only be called after all completed calls.")

        unit.exit()
        ---------------
        -- copy to here to slot1.statusChanged(status): STOPPED
        ---------------
    end
    mock:mockRegisterStatusChanged(statusChangedHandler)
    mock:mockRegisterStatusChanged(statusChangedStoppedHandler, "STOPPED")

    mock.currentTime = 0.0

    ---------------
    -- copy from here to unit.start()
    ---------------
    local expectedFunctions = {"start", "startAndMaintain", "batchStart", "softStop", "hardStop", "getStatus",
                               "getCycleCountSinceStartup", "getEfficiency", "getUptime", "getCurrentSchematic",
                               "setCurrentSchematic"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getElementClass() == "IndustryUnit")
    assert(slot1.getData() == "{}")
    assert(slot1.getDataId() == "")
    assert(slot1.getWidgetType() == "")
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() >= 1329.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() > 100)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    assert(slot1.getStatus() == "STOPPED", slot1.getStatus())
    completedCallCount = 0
    statusChangedCallCount = 0

    slot1.batchStart(3) -- start 3, but will softStop on 2
    ---------------
    -- copy to here to unit.start()
    ---------------

    -- simulate two 10-second jobs finishing with a 10-second gap waiting for ingredients
    mock.currentTime = 10.0
    mock.hasInputIngredients = false
    mock:mockDoCompleted()
    mock.currentTime = 20.0
    mock.hasInputIngredients = true
    mock:mockDoEvaluateStatus()
    mock.currentTime = 30.0
    mock:mockDoCompleted()

    ---------------
    -- copy from here to unit.stop()
    ---------------
    assert(slot1.getStatus() == "STOPPED", slot1.getStatus())
    assert(slot1.getCycleCountSinceStartup() == 2, slot1.getCycleCountSinceStartup())
    assert(completedCallCount == 4)
    assert(statusChangedCallCount == 5)
    -- despite STOPPED state test currently reports efficiency at this point in the test
    -- assert(slot1.getEfficiency() == 0.0, "Not running, can't be efficient: " .. slot1.getEfficiency())
    assert(slot1.getUptime() >= 30.0,
        "Should have taken ~30 seconds to run two jobs with a 10 second wait for ingredients: " .. slot1.getUptime())

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
