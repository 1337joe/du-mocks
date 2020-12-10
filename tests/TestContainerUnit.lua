#!/usr/bin/env lua
--- Tests on dumocks.ContainerUnit.
-- @see dumocks.ContainerUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.ContainerUnit")
require("tests.Utilities")

_G.TestContainerUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestContainerUnit.testConstructor()

    -- default element:
    -- ["container s"] = {mass = 1281.31, maxHitPoints = 999.0}

    local databank1 = mcu:new(nil, 1, "Container XS")
    local databank2 = mcu:new(nil, 2, "invalid")
    local databank3 = mcu:new(nil, 3, "Container S")
    local databank4 = mcu:new(nil, 4, "Container L")
    local databank5 = mcu:new()

    local databank1Closure = databank1:mockGetClosure()
    local databank2Closure = databank2:mockGetClosure()
    local databank3Closure = databank3:mockGetClosure()
    local databank4Closure = databank4:mockGetClosure()
    local databank5Closure = databank5:mockGetClosure()

    lu.assertEquals(databank1Closure.getId(), 1)
    lu.assertEquals(databank2Closure.getId(), 2)
    lu.assertEquals(databank3Closure.getId(), 3)
    lu.assertEquals(databank4Closure.getId(), 4)
    lu.assertEquals(databank5Closure.getId(), 0)

    -- prove default element is selected
    local defaultMass = 1281.31
    lu.assertEquals(databank2Closure.getMass(), defaultMass)
    lu.assertEquals(databank3Closure.getMass(), defaultMass)
    lu.assertEquals(databank5Closure.getMass(), defaultMass)

    -- non-defaults (proves independence)
    lu.assertEquals(databank1Closure.getMass(), 229.09)
    lu.assertEquals(databank4Closure.getMass(), 14842.7)
end

--- Verify element class is correct for various types.
function _G.TestContainerUnit.testGetElementClass()
    local container

    -- default - item container
    container = mcu:new():mockGetClosure()
    lu.assertEquals(container.getElementClass(), "ItemContainer")

    -- selected item container
    container = mcu:new(nil, 0, "container m"):mockGetClosure()
    lu.assertEquals(container.getElementClass(), "ItemContainer")

    -- atmo fuel container
    container = mcu:new(nil, 0, "atmospheric fuel tank s"):mockGetClosure()
    lu.assertEquals(container.getElementClass(), "AtmoFuelContainer")

    -- space fuel container
    container = mcu:new(nil, 0, "space fuel tank s"):mockGetClosure()
    lu.assertEquals(container.getElementClass(), "SpaceFuelContainer")
end

--- Get mass is a function of self mass and item mass, verify relationhip.
function _G.TestContainerUnit.testGetMass()
    local expected, actual
    local container = mcu:new()

    container.selfMass = 10
    container.itemsMass = 0
    expected = 10
    actual = container:getMass()
    lu.assertEquals(actual, expected)

    container.selfMass = 10
    container.itemsMass = 20
    expected = 30
    actual = container:getMass()
    lu.assertEquals(actual, expected)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x item container or fuel tank, connected to Programming Board on slot1
--
-- Exercises: getElementClass, getData, deactivate, activate, toggle, getState
function _G.TestContainerUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _,element in pairs({"container xs", "atmospheric fuel tank xs", "space fuel tank s", "rocket fuel tank xs"}) do
        mock = mcu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestContainerUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestContainerUnit.gameBehaviorHelper(mock, slot1)

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getSelfMass", "getItemsMass", "getItemsVolume", "getMaxVolume", "acquireStorage", "getItemsList"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getElementClass()
    local isItem, isAtmo, isSpace, isRocket
    if class == "ItemContainer" then
        isItem = true
    elseif class == "AtmoFuelContainer" then
        isAtmo = true
    elseif class == "SpaceFuelContainer" then
        isSpace = true
    elseif class == "RocketFuelContainer" then
        isRocket = true
    else
        assert(false, "Unexpected class: " .. class)
    end
    local data = slot1.getData()
    if isItem then
        assert(slot1.getData() == "{}")
        assert(slot1.getDataId() == "")
        assert(slot1.getWidgetType() == "")
    else
        local expectedFields = {"percentage", "timeLeft", "helperId", "name", "type"}
        local unexpectedFields = {}
        local expectedValues = {}
        if isAtmo then
            expectedValues["helperId"] = '"fuel_container_atmo_fuel"'
        elseif isSpace then
            expectedValues["helperId"] = '"fuel_container_space_fuel"'
        elseif isRocket then
            expectedValues["helperId"] = '"fuel_container_rocket_fuel"'
        end
        expectedValues["type"] = '"fuel_container"'
        _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

        assert(string.match(slot1.getDataId(), "e%d+"), "Expected dataId to match e%d pattern: " .. slot1.getDataId())
        assert(slot1.getWidgetType() == "fuel_container")
    end
    slot1.show()
    slot1.hide()
    assert(slot1.getIntegrity() == 100.0 * slot1.getHitPoints() / slot1.getMaxHitPoints())
    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getId() > 0)
    assert(slot1.getMass() > 35.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 5)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())