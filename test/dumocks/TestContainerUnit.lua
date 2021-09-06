#!/usr/bin/env lua
--- Tests on dumocks.ContainerUnit.
-- @see dumocks.ContainerUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mcu = require("dumocks.ContainerUnit")
require("test.Utilities")

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

--- Verify behavior when storage not available and when it is.
function _G.TestContainerUnit.testGetItemsList()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local actual, expected

    expected = "{" .. string.format(mcu.JSON_ITEM_TEMPLATE, "OxygenPure", "Pure Oxygen", 20, "material", 1.0, 1.0) ..
                   "}"
    mock.storageJson = expected

    mock.storageAvailable = false
    actual = closure.getItemsList()
    lu.assertEquals(actual, "")

    mock.storageAvailable = true
    actual = closure.getItemsList()
    lu.assertEquals(actual, expected)
end

--- Verify normal and error behavior of acquiring storage.
function _G.TestContainerUnit.testAcquireStorage()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local actual, expected

    local systemPrint = ""
    system = {}
    function system.print(msg)
        systemPrint = systemPrint .. msg .. "\n"
    end

    -- success case
    mock.requestsExceeded = false
    mock.storageRequested = false
    closure.acquireStorage()
    lu.assertTrue(mock.storageRequested)
    lu.assertEquals(systemPrint, "")

    -- error case
    mock.requestsExceeded = true
    mock.storageRequested = false
    closure.acquireStorage()
    lu.assertFalse(mock.storageRequested)
    lu.assertStrContains(systemPrint, "You have reached the maximum of 10 requests")
end

--- Verify storage callback works without errors.
function _G.TestContainerUnit.testStorageAcquired()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local called, available
    local callback = function()
        called = true
        available = mock.storageAvailable -- examining internal state
       
    end
    mock:mockRegisterStorageAcquired(callback)

    lu.assertFalse(mock.storageAvailable)

    called = false
    mock:mockDoStorageAcquired()
    lu.assertTrue(called)
    lu.assertTrue(available) -- changes before callback

    lu.assertTrue(mock.storageAvailable)
end

--- Verify storage callback works with and propagates errors.
function _G.TestContainerUnit.testStorageAcquiredError()
    local mock = mcu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterStorageAcquired(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterStorageAcquired(callback2)

    lu.assertFalse(mock.storageAvailable)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoStorageAcquired, mock)
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertTrue(mock.storageAvailable)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x item container or fuel tank, connected to Programming Board on slot1
--   a. Add 20L of oxygen or appropriate fuel to container
--
-- Exercises: getElementClass, getData, getMaxVolume, getItemsVolume, getItemsMass, getSelfMass, acquireStorage, getItemsList
function _G.TestContainerUnit.testGameBehavior()
    local containers = {
        ["container xs"] = {
            name = "Pure Oxygen",
            density = 1,
            class = "OxygenPure"
        },
        ["parcel container xs"] = {
            name = "Pure Oxygen",
            density = 1,
            class = "OxygenPure"
        },
        ["atmospheric fuel tank xs"] = {
            density = 4
        },
        ["space fuel tank s"] = {
            density = 6
        },
        ["rocket fuel tank xs"] = {
            name = "Xeron Fuel",
            density = 0.8,
            class = "Xeron"
        }
    }

    local mock, closure
    local result, message
    for element, contents in pairs(containers) do
        mock = mcu:new(nil, 1, element)

        mock.itemsVolume = 20
        mock.itemsMass = mock.itemsVolume * contents.density
        mock.storageJson = "{" ..
                               string.format(mcu.JSON_ITEM_TEMPLATE, contents.class, contents.name, mock.itemsVolume,
                                   "material", contents.density, 1.0) .. "}"

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
    unit.getData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    -- use locals here since all code is in this method
    local isItem, isParcel, isAtmo, isSpace, isRocket
    local storageAcquired

    -- storageAcquired handlers
    local storageAcquiredHandler = function(id)
        ---------------
        -- copy from here to slot1.storageAcquired()
        ---------------
        storageAcquired = true
        unit.exit()
        ---------------
        -- copy to here to slot1.storageAcquired()
        ---------------
    end
    mock:mockRegisterStorageAcquired(storageAcquiredHandler)

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getSelfMass", "getItemsMass", "getItemsVolume", "getMaxVolume", "acquireStorage",
                               "getItemsList"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getElementClass()
    if class == "ItemContainer" then
        isItem = true
    elseif class == "MissionContainer" then
        isParcel = true
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
    local widgetType = ""
    if not (isItem or isParcel) then
        local expectedFields = {"timeLeft", "helperId", "name", "type"}
        local expectedValues = {}
        local ignoreFields = {"percentage"} -- doesn't always show up on initial load
        if isAtmo then
            expectedValues["helperId"] = '"fuel_container_atmo_fuel"'
        elseif isSpace then
            expectedValues["helperId"] = '"fuel_container_space_fuel"'
        elseif isRocket then
            expectedValues["helperId"] = '"fuel_container_rocket_fuel"'
        end
        expectedValues["type"] = '"fuel_container"'
        _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues, ignoreFields)

        widgetType = "fuel_container"
    end
    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() > 35.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 5, widgetType)

    local volumeBase, volumeMaxMultiplier
    if isItem then
        volumeBase = 1000
        volumeMaxMultiplier = 1.5
    elseif isParcel then
        volumeBase = 1000
        volumeMaxMultiplier = 1
    elseif isAtmo then
        volumeBase = 100
        volumeMaxMultiplier = 2.0
    elseif isSpace then
        volumeBase = 400
        volumeMaxMultiplier = 2.0
    elseif isRocket then
        volumeBase = 400
        volumeMaxMultiplier = 1.5
    end
    local maxVolume = slot1.getMaxVolume()
    assert(maxVolume >= volumeBase and maxVolume <= volumeBase * volumeMaxMultiplier,
        string.format("Expected volume to be in range [%f, %f] but was %f", volumeBase,
            volumeBase * volumeMaxMultiplier, maxVolume))

    -- ensure initial state, set up globals
    storageAcquired = false

    slot1.acquireStorage()
    ---------------
    -- copy to here to unit.start()
    ---------------

    mock:mockDoStorageAcquired()

    ---------------
    -- copy from here to unit.stop()
    ---------------

    assert(storageAcquired)
    local itemsJson = slot1.getItemsList()
    assert(itemsJson ~= "" and not itemsJson:match("%[%]"), "itemsJson is empty, does the container have contents?")

    -- local class = string.match(itemsJson, [["class" : "(.-)"]])
    -- local name = string.match(itemsJson, [["name" : "(.-)"]])
    local quantity = tonumber(string.match(itemsJson, [["quantity" : ([0-9.]+)]]))
    local density = tonumber(string.match(itemsJson, [["unitMass" : ([0-9.]+)]]))

    local expectedVolume = 20
    assert(quantity == expectedVolume, string.format("Expected %f L but was %f", expectedVolume, quantity))
    local itemsVolume = slot1.getItemsVolume()
    assert(itemsVolume == expectedVolume, string.format("Expected %f L but was %f", expectedVolume, itemsVolume))

    local expectedMass = expectedVolume * density
    local itemsMass = slot1.getItemsMass()
    assert(itemsMass == expectedMass, string.format("Expected %f kg but was %f", expectedMass, itemsMass))

    assert(slot1.getSelfMass() + slot1.getItemsMass() == slot1.getMass())

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
