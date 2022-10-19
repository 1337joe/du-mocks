#!/usr/bin/env lua
--- Tests on dumocks.DatabankUnit.
-- @see dumocks.DatabankUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mdu = require("dumocks.DatabankUnit")
local utilities = require("test.Utilities")

_G.TestDatabankUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestDatabankUnit.testConstructor()

    -- default element:
    -- ["databank xs"] = {mass = 17.09, maxHitPoints = 50.0, itemId = 812400865}

    local databank1 = mdu:new(nil, 1, "Databank XS")
    local databank2 = mdu:new(nil, 2, "invalid")
    local databank3 = mdu:new()

    local databank1Closure = databank1:mockGetClosure()
    local databank2Closure = databank2:mockGetClosure()
    local databank3Closure = databank3:mockGetClosure()

    lu.assertEquals(databank1Closure.getLocalId(), 1)
    lu.assertEquals(databank2Closure.getLocalId(), 2)
    lu.assertEquals(databank3Closure.getLocalId(), 0)

    -- prove default element is selected
    local defaultMass = 17.09
    lu.assertEquals(databank1Closure.getMass(), defaultMass)
    lu.assertEquals(databank2Closure.getMass(), defaultMass)
    lu.assertEquals(databank3Closure.getMass(), defaultMass)

    -- do some damage, max hit points is 50 (prove independance)
    databank1.hitPoints = 25.0
    databank2.hitPoints = 12.5
    databank3.hitPoints = 0.25

    lu.assertEquals(databank1Closure.getIntegrity(), 50.0)
    lu.assertEquals(databank2Closure.getIntegrity(), 25.0)
    lu.assertEquals(databank3Closure.getIntegrity(), 0.5)

    local defaultId = 812400865
    lu.assertEquals(databank1Closure.getItemId(), defaultId)
    lu.assertEquals(databank2Closure.getItemId(), defaultId)
    lu.assertEquals(databank3Closure.getItemId(), defaultId)
end

--- Verify that clear empties the databank.
function _G.TestDatabankUnit.testClear()
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    databank.data = {
        key = 1
    }
    closure.clear()
    lu.assertEquals(databank.data, {})

    databank.data = {
        key = 1,
        key2 = "string"
    }
    closure.clear()
    lu.assertEquals(databank.data, {})
end

--- Verify number of keys counts properly.
function _G.TestDatabankUnit.testGetNbKeys()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    expected = 0
    actual = closure.getNbKeys()
    lu.assertEquals(actual, expected)

    databank.data[1] = 5
    databank.data[5] = 1
    expected = 2
    actual = closure.getNbKeys()
    lu.assertEquals(actual, expected)
end

--- Verify keys can be retrieved in the proper format.
function _G.TestDatabankUnit.testGetKeyList()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    databank.data = {}
    expected = {}
    actual = closure.getKeyList()
    lu.assertItemsEquals(actual, expected)
    lu.assertEquals(utilities.verifyDeprecated("getKeys", closure.getKeys), '[]')

    databank.data = {
        key = "value"
    }
    expected = {"key"}
    actual = closure.getKeyList()
    lu.assertItemsEquals(actual, expected)
    lu.assertEquals(utilities.verifyDeprecated("getKeys", closure.getKeys), '["key"]')

    databank.data = {
        key1 = "value1",
        key2 = 8
    }
    expected = {"key1", "key2"}
    actual = closure.getKeyList()
    lu.assertItemsEquals(actual, expected)
end

--- Verify keys are detected and indicated with 0 or 1.
function _G.TestDatabankUnit.testHasKey()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    expected = 0
    actual = closure.hasKey("key")
    lu.assertEquals(actual, expected)

    local key = "key"
    databank.data[key] = "value"
    expected = 1
    actual = closure.hasKey(key)
    lu.assertEquals(actual, expected)

    local key = 1
    databank.data[tostring(key)] = "value"
    expected = 1
    actual = closure.hasKey(key)
    lu.assertEquals(actual, expected)
end

--- Verify keys are deleted as expected.
function _G.TestDatabankUnit.testClearValue()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    databank.data["found"] = 1

    lu.assertEquals(closure.clearValue("not found"), 0)
    lu.assertEquals(closure.clearValue("found"), 1)

    lu.assertEquals({}, databank.data)
    lu.assertEquals(closure.clearValue("found"), 0)
end

--- Verify storage as string works. In-game storage not visible, simply test that the key is set, not what's in storage.
function _G.TestDatabankUnit.testSetStringValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- string value
    key = "key1"
    expected = "value1"
    closure.setStringValue(key, expected)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- int value
    key = "key2"
    closure.setStringValue(key, 2)
    actual = databank.data[key]
    lu.assertNotNil(actual)

    -- float value
    key = "key3"
    closure.setStringValue(key, 3.1)
    actual = databank.data[key]
    lu.assertNotNil(actual)

    -- nil value
    key = "key4"
    closure.setStringValue(key, nil)
    actual = databank.data[key]
    lu.assertNotNil(actual)

    -- boolean value
    key = "key5"
    closure.setStringValue(key, true)
    actual = databank.data[key]
    lu.assertNotNil(actual)

    -- default value
    key = "key6"
    closure.setStringValue(key, "")
    actual = databank.data[key]
    lu.assertNotNil(actual)

    -- non-string key
    key = 1
    closure.setStringValue(key, "String")
    actual = databank.data[tostring(key)]
    lu.assertNotNil(actual)
end

--- Verify retrieval as string works.
function _G.TestDatabankUnit.testGetStringValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- string value
    key = "key1"
    expected = "value1"
    databank.data[key] = expected
    actual = closure.getStringValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- int value
    key = "key2"
    expected = "2"
    databank.data[key] = 2
    actual = closure.getStringValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- float value
    key = "key3"
    expected = "3.1"
    databank.data[key] = 3.1
    actual = closure.getStringValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- nil value
    key = "key4"
    expected = ""
    -- not set, defaults to nil
    actual = closure.getStringValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- non-string key
    key = 5
    expected = "value"
    databank.data[tostring(key)] = "value"
    actual = closure.getStringValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)
end

--- Verify storage as int works. In-game storage not visible, simply test that the key is set, not what's in storage.
function _G.TestDatabankUnit.testSetIntValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- int value
    key = "key1"
    expected = 1
    closure.setIntValue(key, expected)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- float value
    key = "key2"
    closure.setIntValue(key, 2.1)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- string value
    key = "key3"
    closure.setIntValue(key, "key 3")
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- boolean value
    key = "key4"
    closure.setIntValue(key, true)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- nil value
    key = "key5"
    closure.setIntValue(key, nil)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- default value
    key = "key6"
    closure.setIntValue(key, 0)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- non-string key
    key = 1
    closure.setIntValue(key, 1)
    actual = databank.data[tostring(key)]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)
end

--- Verify retrieval as int works.
function _G.TestDatabankUnit.testGetIntValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- string value
    key = "key1"
    expected = 0
    databank.data[key] = expected
    actual = closure.getIntValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- int value
    key = "key2"
    expected = 2
    databank.data[key] = 2
    actual = closure.getIntValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- float value
    key = "key3"
    expected = 0
    databank.data[key] = 3.1
    actual = closure.getIntValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- nil value
    key = "key4"
    expected = 0
    -- not set, defaults to 0
    actual = closure.getIntValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- non-string key
    key = 5
    expected = 2
    databank.data[tostring(key)] = 2
    actual = closure.getIntValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)
end

--- Verify storage as float works. In-game storage not visible, simply test that the key is set, not what's in storage.
function _G.TestDatabankUnit.testSetFloatValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- float value
    key = "key1"
    expected = 1.2
    closure.setFloatValue(key, expected)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- int value
    key = "key2"
    closure.setFloatValue(key, 2)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- string value
    key = "key3"
    closure.setFloatValue(key, "key 3")
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- boolean value
    key = "key4"
    closure.setFloatValue(key, true)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- nil value
    key = "key5"
    closure.setFloatValue(key, nil)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- default value
    key = "key6"
    closure.setFloatValue(key, 0.0)
    actual = databank.data[key]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)

    -- non-string key
    key = 1
    closure.setFloatValue(key, 1.1)
    actual = databank.data[tostring(key)]
    lu.assertNotNil(actual)
    lu.assertIsNumber(actual)
end

--- Verify retrieval as float works.
function _G.TestDatabankUnit.testGetFloatValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    -- string value
    key = "key1"
    expected = 0
    databank.data[key] = expected
    actual = closure.getFloatValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- int value
    key = "key2"
    expected = 2
    databank.data[key] = 2
    actual = closure.getFloatValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- float value
    key = "key3"
    expected = 3.1
    databank.data[key] = 3.1
    actual = closure.getFloatValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- nil value
    key = "key4"
    expected = 0
    -- not set, defaults to 0
    actual = closure.getFloatValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- non-string key
    key = 5
    expected = 3.1
    databank.data[tostring(key)] = 3.1
    actual = closure.getFloatValue(key)
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Databank, connected to Programming Board on slot1
--
-- Exercises: getClass, hasKey, getKeyList, getNbKeys, clear, setStringValue, getStringValue, setIntValue,
-- getIntValue, setFloatValue, getFloatValue
function _G.TestDatabankUnit.testGameBehavior()
    local databank = mdu:new(nil, 1)
    local slot1 = databank:mockGetClosure()

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
    local expectedFunctions = {"clear", "getNbKeys", "getKeys", "getKeyList", "hasKey", "clearValue", "setStringValue",
                               "getStringValue", "setIntValue", "getIntValue", "setFloatValue", "getFloatValue"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    assert(slot1.getClass() == "DataBankUnit")
    assert(string.match(string.lower(slot1.getName()), "databank xs %[%d+%]"), slot1.getName())
    assert(slot1.getItemId() == 812400865, slot1.getItemId())
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 17.09)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    slot1.clear()

    local key, keyList

    key = "key1"
    slot1.setStringValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    keyList = slot1.getKeyList()
    assert(#keyList == 1)
    assert(keyList[1] == "key1")
    assert(slot1.getNbKeys() == 1, "Number of keys: " .. slot1.getNbKeys())

    assert(slot1.clearValue("key0"), 0)
    assert(slot1.clearValue("key1"), 1)
    assert(slot1.clearValue("key0"), 0)

    assert(slot1.getNbKeys() == 0)

    key = "key1.5"
    slot1.setStringValue(key, "")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key2"
    slot1.setStringValue(key, nil)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    keyList = slot1.getKeyList()
    assert(#keyList == 2)
    assert((keyList[1] == "key1.5" and keyList[2] == "key2") or (keyList[2] == "key1.5" and keyList[1] == "key2"))
    assert(slot1.getNbKeys() == 2, "Number of keys: " .. slot1.getNbKeys())

    key = "key3"
    slot1.setStringValue(key, true)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key4"
    slot1.setStringValue(key, 4)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "4")
    assert(slot1.getIntValue(key) == 4)
    assert(slot1.getFloatValue(key) == 4.0)

    key = "key4.5"
    slot1.setStringValue(key, 0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key5"
    slot1.setStringValue(key, 5.5)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "5.5")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 5.5)

    key = "key5.5"
    slot1.setStringValue(key, 0.0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0.0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0)

    key = "key6"
    slot1.setIntValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key6.5"
    slot1.setIntValue(key, "")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key7"
    slot1.setIntValue(key, nil)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key8"
    slot1.setIntValue(key, true)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "1")
    assert(slot1.getIntValue(key) == 1)
    assert(slot1.getFloatValue(key) == 1.0)

    key = "key8.5"
    slot1.setIntValue(key, false)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key9"
    slot1.setIntValue(key, 9)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "9")
    assert(slot1.getIntValue(key) == 9)
    assert(slot1.getFloatValue(key) == 9.0)

    key = "key9.5"
    slot1.setIntValue(key, 0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key10"
    slot1.setIntValue(key, 10.1)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0)

    key = "key10.5"
    slot1.setIntValue(key, 0.0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0)

    key = "key11"
    slot1.setFloatValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key11.5"
    slot1.setFloatValue(key, "")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key12"
    slot1.setFloatValue(key, nil)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key13"
    slot1.setFloatValue(key, true)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key14"
    slot1.setFloatValue(key, 14)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "14")
    assert(slot1.getIntValue(key) == 14)
    assert(slot1.getFloatValue(key) == 14.0)

    key = "key14.5"
    slot1.setFloatValue(key, 0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    key = "key15"
    slot1.setFloatValue(key, 15.15)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "15.15")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 15.15)

    key = "key15.5"
    slot1.setFloatValue(key, 0.0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

    -- non-string keys
    key = 1
    slot1.setStringValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")
    key = tostring(key)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")

    key = 1.2
    slot1.setStringValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")
    key = tostring(key)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")

    system.print("Success")
    unit.exit()

    ---------------
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
