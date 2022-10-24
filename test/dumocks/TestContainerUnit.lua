#!/usr/bin/env lua
--- Tests on dumocks.ContainerUnit.
-- @see dumocks.ContainerUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mcu = require("dumocks.ContainerUnit")
local utilities = require("test.Utilities")

_G.TestContainerUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestContainerUnit.testConstructor()

    -- default element:
    -- ["basic container s"] = {mass = 1281.31, maxHitPoints = 999.0, itemId = 1594689569 class = S_GROUP, maxVolume = 8000}

    local container1 = mcu:new(nil, 1, "Basic Container XS")
    local container2 = mcu:new(nil, 2, "invalid")
    local container3 = mcu:new(nil, 3, "Basic Container S")
    local container4 = mcu:new(nil, 4, "Basic Container L")
    local container5 = mcu:new()

    local container1Closure = container1:mockGetClosure()
    local container2Closure = container2:mockGetClosure()
    local container3Closure = container3:mockGetClosure()
    local container4Closure = container4:mockGetClosure()
    local container5Closure = container5:mockGetClosure()

    lu.assertEquals(container1Closure.getLocalId(), 1)
    lu.assertEquals(container2Closure.getLocalId(), 2)
    lu.assertEquals(container3Closure.getLocalId(), 3)
    lu.assertEquals(container4Closure.getLocalId(), 4)
    lu.assertEquals(container5Closure.getLocalId(), 0)

    -- prove default element is selected
    local defaultMass = 1281.31
    lu.assertEquals(container2Closure.getMass(), defaultMass)
    lu.assertEquals(container3Closure.getMass(), defaultMass)
    lu.assertEquals(container5Closure.getMass(), defaultMass)

    -- non-defaults (proves independence)
    lu.assertEquals(container1Closure.getMass(), 229.09)
    lu.assertEquals(container4Closure.getMass(), 14842.7)

    local defaultId = 1594689569
    lu.assertNotEquals(container1Closure.getItemId(), defaultId)
    lu.assertEquals(container2Closure.getItemId(), defaultId)
    lu.assertEquals(container3Closure.getItemId(), defaultId)
    lu.assertNotEquals(container4Closure.getItemId(), defaultId)
    lu.assertEquals(container5Closure.getItemId(), defaultId)
end

--- Verify element class is correct for various types.
function _G.TestContainerUnit.testGetClass()
    local container

    -- default - item container
    container = mcu:new():mockGetClosure()
    lu.assertEquals(container.getClass(), "ContainerMediumGroup")

    -- selected item container
    container = mcu:new(nil, 0, "basic container m"):mockGetClosure()
    lu.assertEquals(container.getClass(), "ContainerLargeGroup")

    -- atmo fuel container
    container = mcu:new(nil, 0, "atmospheric fuel tank s"):mockGetClosure()
    lu.assertEquals(container.getClass(), "AtmoFuelContainer")

    -- space fuel container
    container = mcu:new(nil, 0, "space fuel tank s"):mockGetClosure()
    lu.assertEquals(container.getClass(), "SpaceFuelContainer")
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
function _G.TestContainerUnit.testGetContent()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local actual, expected

    expected = {
        {
            id = 947806142,
            quantity = 20.0
        }
    }

    actual = closure.getContent()
    lu.assertEquals(actual, nil)
    lu.assertEquals(utilities.verifyDeprecated("getItemsList", closure.getItemsList), "")

    mock.storageItems = expected
    actual = closure.getContent()
    lu.assertEquals(actual, expected)
    -- getItemsList seems to no longer function, always returns ""
    lu.assertEquals(utilities.verifyDeprecated("getItemsList", closure.getItemsList), "")
end

--- Verify normal and error behavior of acquiring storage.
function _G.TestContainerUnit.testUpdateContent()
    local mock = mcu:new()
    local closure = mock:mockGetClosure()

    local systemPrint = ""
    system = {}
    function system.print(msg)
        systemPrint = systemPrint .. msg .. "\n"
    end

    local expected, actual

    -- success case
    expected = 0
    mock.remainingCooldown = expected
    mock.storageRequested = false
    actual = closure.updateContent()
    lu.assertTrue(mock.storageRequested)
    lu.assertEquals(actual, expected)
    lu.assertEquals(systemPrint, "")

    -- error case
    expected = 30
    mock.remainingCooldown = expected
    mock.storageRequested = false
    actual = closure.updateContent()
    lu.assertFalse(mock.storageRequested)
    lu.assertEquals(actual, expected)

    -- deprecated calls still work, no return to check
    mock.remainingCooldown = 0
    mock.storageRequested = false
    utilities.verifyDeprecated("acquireStorage", closure.acquireStorage)
    lu.assertTrue(mock.storageRequested)

    mock.remainingCooldown = 30
    mock.storageRequested = false
    utilities.verifyDeprecated("acquireStorage", closure.acquireStorage)
    lu.assertFalse(mock.storageRequested)
end

--- Verify storage callback works without errors.
function _G.TestContainerUnit.testOnContentUpdate()
    local mock = mcu:new()

    local called
    local callback = function()
        called = true
    end
    mock:mockRegisterContentUpdate(callback)

    lu.assertNil(mock.storageItems)

    called = false
    mock:mockDoContentUpdate({{ id = 1, quantity = 20.0 }})
    lu.assertTrue(called)

    lu.assertNotNil(mock.storageItems)
end

--- Verify storage callback works with and propagates errors.
function _G.TestContainerUnit.testContentUpdateError()
    local mock = mcu:new()

    local calls = 0
    local callback1Order, callback2Order
    local callbackError = function()
        calls = calls + 1
        callback1Order = calls
        error("I'm a bad callback.")
    end
    mock:mockRegisterContentUpdate(callbackError)

    local callback2 = function()
        calls = calls + 1
        callback2Order = calls
        error("I'm a bad callback, too.")
    end
    mock:mockRegisterContentUpdate(callback2)

    lu.assertNil(mock.storageItems)

    -- both called, proper order, errors thrown
    lu.assertErrorMsgContains("bad callback", mock.mockDoContentUpdate, mock, {{ id = 1, quantity = 20.0 }})
    lu.assertEquals(calls, 2)
    lu.assertEquals(callback1Order, 1)
    lu.assertEquals(callback2Order, 2)

    lu.assertNotNil(mock.storageItems)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x item container or fuel tank, connected to Programming Board on slot1
--   a. Add 20L of oxygen, 20 Railgun Antimatter Ammo xs, or appropriate fuel to container
--
-- Exercises: getClass, getWidgetData, getMaxVolume, getItemsVolume, getItemsMass, getSelfMass, updateContent, getContent
function _G.TestContainerUnit.testGameBehavior()
    local items = {
        [947806142] = {
            displayName = "Pure Oxygen",
            unitMass = 1.0,
            unitVolume = 1.0
        },
        [3669030673] = {
            displayName = "Railgun Antimatter Ammo",
            unitMass = 2.01,
            unitVolume = 10.0
        },
        [2579672037] = {
            displayName = "Nitron Fuel",
            unitMass = 4.0,
            unitVolume = 1.0
        },
        [840202980] = {
            displayName = "Kergon-X1 Fuel",
            unitMass = 6,
            unitVolume = 1.0
        }
    }
    local containers = {
        ["basic container xs"] = {
            id = 947806142,
            quantity = 20.0
        },
        ["parcel container xs"] = {
            id = 947806142,
            quantity = 20.0
        },
        ["ammo container xs"] = {
            id = 3669030673,
            quantity = 20
        },
        ["atmospheric fuel tank xs"] = {
            id = 2579672037,
            quantity = 20
        },
        ["space fuel tank xs"] = {
            id = 840202980,
            quantity = 20
        },
        -- ["rocket fuel tank xs"] = {
        --     name = "Xeron Fuel",
        --     unitMass = 0.8,
        --     class = "Xeron"
        -- }
    }

    local mock, closure
    local result, message
    for element, contents in pairs(containers) do
        mock = mcu:new(nil, 1, element)

        local itemQuantity = 20
        mock.itemsVolume = itemQuantity * (items[contents.id].unitVolume or 1.0)
        mock.itemsMass = itemQuantity * items[contents.id].unitMass
        mock.storageItems = { contents }

        closure = mock:mockGetClosure()

        result, message = pcall(_G.TestContainerUnit.gameBehaviorHelper, mock, closure, items)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestContainerUnit.gameBehaviorHelper(mock, slot1, items)

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.getWidgetData = function()
        return '"showScriptError":false'
    end
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end
    system.getItem = function(id)
        return items[id]
    end

    -- use locals here since all code is in this method
    local isItem, isParcel, isAmmo, isAtmo, isSpace, isRocket
    local contentUpdate

    -- contentUpdate handlers
    local contentUpdateHandler = function(id)
        ---------------
        -- copy from here to slot1.onContentUpdate()
        ---------------
        contentUpdate = true
        unit.exit()
        ---------------
        -- copy to here to slot1.onContentUpdate()
        ---------------
    end
    mock:mockRegisterContentUpdate(contentUpdateHandler)

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"getSelfMass", "getItemsMass", "getItemsVolume", "getMaxVolume", "acquireStorage",
                               "getItemsList", "updateContent", "getContent"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getClass()
    local expectedName, expectedId
    if string.match(class, "Container%a+Group") ~= nil then
        isItem = true
        expectedName = "basic container xs %[%d+%]"
        expectedId = 1689381593
    elseif class == "MissionContainer" then
        isParcel = true
        expectedName = "parcel container xs %[%d+%]"
        expectedId = 386276308
    elseif class == "AmmoContainerUnit" then
        isAmmo = true
        expectedName = "ammo container xs %[%d+%]"
        expectedId = 300986010
    elseif class == "AtmoFuelContainer" then
        isAtmo = true
        expectedName = "atmospheric fuel tank xs %[%d+%]"
        expectedId = 3273319200
    elseif class == "SpaceFuelContainer" then
        isSpace = true
        expectedName = "space fuel tank xs %[%d+%]"
        expectedId = 2421673145
    elseif class == "RocketFuelContainer" then
        isRocket = true
        expectedName = "rocket fuel tank xs %[%d+%]"
        expectedId = 0
    else
        assert(false, "Unexpected class: " .. class)
    end
    assert(string.match(string.lower(slot1.getName()), expectedName), slot1.getName())
    assert(slot1.getItemId() == expectedId, slot1.getItemId())

    local data = slot1.getWidgetData()
    local widgetType = ""
    if not (isItem or isParcel or isAmmo) then
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
    elseif isAmmo then
        volumeBase = 1000
        volumeMaxMultiplier = 1
    elseif isAtmo then
        volumeBase = 100
        volumeMaxMultiplier = 2.0
    elseif isSpace then
        volumeBase = 100
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
    contentUpdate = false

    local secondsRemaining = slot1.updateContent()
    if secondsRemaining > 0 then
        system.print(string.format("Please wait an additional %.0f seconds and retry.", secondsRemaining))
        unit.exit()
    end
    ---------------
    -- copy to here to unit.onStart()
    ---------------

    mock.remainingCooldown = 30
    mock:mockDoContentUpdate(mock.storageItems)

    ---------------
    -- copy from here to unit.onStop()
    ---------------

    assert(contentUpdate)
    assert(slot1.updateContent() > 0, "Expected delay before being allowed to query again.")
    local items = slot1.getContent()
    assert(#items == 1, string.format("Expected a single stack of contents, found %d", #items))

    local quantity = items[1].quantity
    local item = system.getItem(items[1].id)
    local unitMass = item.unitMass

    local expectedQuantity = 20
    local epsilon = 0.000001
    local expectedVolume = expectedQuantity * item.unitVolume
    assert(quantity == expectedQuantity, string.format("Expected %f but was %f", expectedQuantity, quantity))
    local itemsVolume = slot1.getItemsVolume()
    assert(math.abs(itemsVolume - expectedVolume) < epsilon, string.format("Expected %f L but was %f L", expectedVolume, itemsVolume))

    local expectedMass = expectedQuantity * unitMass
    local itemsMass = slot1.getItemsMass()
    local matched = false
    local reduction = 0.05
    for skill = 0, 5 do
        matched = matched or math.abs(itemsMass - expectedMass * (1.0 - reduction * skill)) < epsilon
    end
    assert(matched, string.format("Expected %f kg to %f kg but was %f kg", expectedMass * (1.0 - reduction * 5), expectedMass, itemsMass))

    assert(slot1.getSelfMass() + slot1.getItemsMass() == slot1.getMass())

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
