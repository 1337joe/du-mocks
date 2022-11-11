#!/usr/bin/env lua
--- Tests on dumocks.IndustryUnit.
-- @see dumocks.IndustryUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local miu = require("dumocks.IndustryUnit")
local utilities = require("test.Utilities")

TestIndustryUnit = {}

--- Verify element class is correct.
function TestIndustryUnit.testGetClass()
    local element = miu:new():mockGetClosure()
    lu.assertEquals(element.getClass(), "IndustryUnit")
end

function TestIndustryUnit.testStartRun()
    local mock = miu:new()
    local closure = mock:mockGetClosure()

    -- verify default state is stopped
    lu.assertEquals(closure.getState(), miu.status.STOPPED)

    -- nominal - goes to running
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.RUNNING)

    -- nominal - goes to running (deprecated)
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = true
    utilities.verifyDeprecated("start", closure.start)
    lu.assertEquals(closure.getState(), miu.status.RUNNING)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = false
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = false
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing inputs
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = false
    mock.hasInputIngredients = false
    mock.hasOutput = true
    mock.hasOutputSpace = true
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.JAMMED_MISSING_INGREDIENT)

    -- not nominal - missing output
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = false
    mock.hasOutputSpace = true
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.RUNNING)

    -- not nominal - missing output space
    mock = miu:new()
    closure = mock:mockGetClosure()
    mock.hasInputContainer = true
    mock.hasInputIngredients = true
    mock.hasOutput = true
    mock.hasOutputSpace = false
    closure.startRun()
    lu.assertEquals(closure.getState(), miu.status.RUNNING)
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
-- Exercises: startFor, stop, getState, getCyclesCompleted, getEfficiency, getUptime, EVENT_onCompleted,
--   EVENT_onStatusChanged (with and without filter)
function TestIndustryUnit.testGameBehavior()
    local mock = miu:new(nil, 1, "transfer unit l")
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {
        getWidgetData = function()
            return '"showScriptError":false'
        end,
        exit = function()
        end
    }
    local system = {}
    system.print = function(_)
    end

    -- use locals here since all code is in this method
    local completedCallCount, statusChangedCallCount

    -- completed handlers
    local completedHandler1 = function()
        ---------------
        -- copy from here to slot1.onCompleted(id,quantity) * *
        ---------------
        completedCallCount = completedCallCount + 1
        assert(completedCallCount % 2 == 1, "Should always be odd - first in call queue.")
        assert(slot1.getState() == 2, "Unexpected state: " .. slot1.getState())
        assert(slot1.getCyclesCompleted() == math.floor(completedCallCount / 2) + 1)

        if slot1.getCyclesCompleted() == 1 then
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
        -- copy to here to slot1.onCompleted(id,quantity) * *
        ---------------
    end
    local completedHandler2 = function()
        ---------------
        -- copy from here to slot1.onCompleted(id,quantity) * *
        ---------------
        completedCallCount = completedCallCount + 1
        assert(completedCallCount % 2 == 0, "Should always be even - second in call queue.")
        ---------------
        -- copy to here to slot1.onCompleted(id,quantity) * *
        ---------------
    end
    mock:mockRegisterCompleted(completedHandler1)
    mock:mockRegisterCompleted(completedHandler2)

    -- status changed handlers
    local statusChangedHandler = function(status)
        ---------------
        -- copy from here to slot1.onStatusChanged(status): *
        ---------------
        statusChangedCallCount = statusChangedCallCount + 1
        assert(slot1.getState() == status)
        if statusChangedCallCount == 1 or statusChangedCallCount == 3 then
            assert(status == 2, "Unexpected state: " .. status)
            -- TODO game behavior currently unsupported in mock
            -- assert(slot1.getEfficiency() == 0.0,
            --     "Odd, but 0.0 is expected game behavior here: " .. slot1.getEfficiency())
        elseif statusChangedCallCount == 2 then
            assert(status == 3, "Unexpected state: " .. status)
        else
            assert(status == 1, "Unexpected state: " .. status)
        end

        if statusChangedCallCount == 3 then
            slot1.stop()
        end
        ---------------
        -- copy to here to slot1.onStatusChanged(status): *
        ---------------
    end
    local statusChangedStoppedHandler = function(status)
        ---------------
        -- copy from here to slot1.onStatusChanged(status): 1
        ---------------
        statusChangedCallCount = statusChangedCallCount + 1
        assert(status == 1, "Should only be called on stop event.")
        assert(slot1.getCyclesCompleted() == 2, "Unexpected cycles: " .. slot1.getCyclesCompleted())
        -- TODO debug: currently not calling onStarted/onCompleted in-game on transfer unit
        -- assert(completedCallCount == 4, "Should only be called after all completed calls.")

        unit.exit()
        ---------------
        -- copy to here to slot1.onStatusChanged(status): 1
        ---------------
    end
    mock:mockRegisterStatusChanged(statusChangedHandler)
    mock:mockRegisterStatusChanged(statusChangedStoppedHandler, 1)

    mock.currentTime = 0.0

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    local expectedFunctions = {"start", "startAndMaintain", "batchStart", "softStop", "hardStop", "getStatus",
                               "getCycleCountSinceStartup", "getEfficiency", "getUptime", "getCurrentSchematic",
                               "setCurrentSchematic", "getCyclesCompleted", "getBank", "startRun", "startFor",
                               "setOutput", "getInfo", "getOutputs", "updateBank", "getInputs", "getState", "stop",
                               "startMaintain"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "IndustryUnit")
    assert(string.match(string.lower(slot1.getName()), "transfer unit l %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 4139262245, "Unexpected id: " .. slot1.getItemId())
    assert(slot1.getMaxHitPoints() >= 1329.0)
    assert(slot1.getMass() > 100)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- ensure initial state, set up globals
    assert(slot1.getState() == 1, "Should be stopped (1): " .. slot1.getState())
    completedCallCount = 0
    statusChangedCallCount = 0

    slot1.startFor(3) -- start 3, but will softStop on 2
    ---------------
    -- copy to here to unit.onStart()
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
    -- copy from here to unit.onStop()
    ---------------
    assert(slot1.getState() == 1, "Should be stopped (1): " .. slot1.getState())
    assert(slot1.getCyclesCompleted() == 2, "Expected 2 cycles: " .. slot1.getCyclesCompleted())
    -- assert(completedCallCount == 4) TODO debug: currently not calling onStarted/onCompleted in-game on transfer unit
    assert(statusChangedCallCount == 5)
    -- despite STOPPED state test currently reports efficiency at this point in the test
    -- assert(slot1.getEfficiency() == 0.0, "Not running, can't be efficient: " .. slot1.getEfficiency())
    assert(slot1.getUptime() >= 30.0,
        "Should have taken ~30 seconds to run two jobs with a 10 second wait for ingredients: " .. slot1.getUptime())

    -- multi-part script, can't just print success because end of script was reached
    if string.find(unit.getWidgetData(), '"showScriptError":false') then
        system.print("Success")
    else
        system.print("Failed")
    end
    ---------------
    -- copy to here to unit.onStop()
    ---------------
end

os.exit(lu.LuaUnit.run())
