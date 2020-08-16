#!/usr/bin/env lua
--- Tests on dumocks.DatabankUnit.
-- @see dumocks.DatabankUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdu = require("dumocks.DatabankUnit")

TestDatabankUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function TestDatabankUnit.testConstructor()

    -- default element:
    -- ["databank"] = {mass = 17.09, maxHitPoints = 50.0}

    local databank1 = mdu:new(nil, 1, "Databank")
    local databank2 = mdu:new(nil, 2, "invalid")
    local databank3 = mdu:new()

    local databank1Closure = databank1:mockGetClosure()
    local databank2Closure = databank2:mockGetClosure()
    local databank3Closure = databank3:mockGetClosure()

    lu.assertEquals(databank1Closure.getId(), 1)
    lu.assertEquals(databank2Closure.getId(), 2)
    lu.assertEquals(databank3Closure.getId(), 0)

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
end

--- Verify element class is correct.
function TestDatabankUnit.testGetElementClass()
    local databank = mdu:new():mockGetClosure()
    lu.assertEquals(databank.getElementClass(), "DataBankUnit")
end

--- Verify that clear empties the databank.
function TestDatabankUnit.testClear()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    databank.data = {key = 1}
    closure.clear()
    lu.assertEquals(databank.data, {})

    databank.data = {key = 1, key2 = "string"}
    closure.clear()
    lu.assertEquals(databank.data, {})
end

--- Verify number of keys counts properly.
function TestDatabankUnit.testGetNbKeys()
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
function TestDatabankUnit.testGetKeys()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:mockGetClosure()

    databank.data = {}
    expected = '[]'
    actual = closure.getKeys()
    lu.assertEquals(actual, expected)

    databank.data = {key="value"}
    expected = '["key"]'
    actual = closure.getKeys()
    lu.assertEquals(actual, expected)

    databank.data = {key1 = "value1", key2 = 8}
    actual = closure.getKeys()
    -- order of iterating table keys not deterministic
    lu.assertStrContains(actual, '"key1"')
    lu.assertStrContains(actual, '"key2"')
end

--- Verify keys are detected and indicated with 0 or 1.
function TestDatabankUnit.testHasKey()
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
end

--- Verify storage as string works. In-game storage not visible, simply test that the key is set, not what's in storage.
function TestDatabankUnit.testSetStringValue()
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
    expected = ""
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
    closure.setIntValue(key, "")
    actual = databank.data[key]
    lu.assertNotNil(actual)
end

--- Verify retrieval as string works.
function TestDatabankUnit.testGetStringValue()
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
end

--- Verify storage as int works. In-game storage not visible, simply test that the key is set, not what's in storage.
function TestDatabankUnit.testSetIntValue()
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
end

--- Verify retrieval as int works.
function TestDatabankUnit.testGetIntValue()
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
    expected = 3
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
end

--- Verify storage as float works. In-game storage not visible, simply test that the key is set, not what's in storage.
function TestDatabankUnit.testSetFloatValue()
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
end

--- Verify retrieval as float works.
function TestDatabankUnit.testGetFloatValue()
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
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function TestDatabankUnit.testGameBehavior()
    local databank = mdu:new()
    local slot1 = databank:mockGetClosure()

    ---------------
    -- copy from here to unit.start()
    ---------------
    assert(slot1.getElementClass() == "DataBankUnit")

    local key

    key = "key1"
    slot1.setStringValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)

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
    assert(slot1.getIntValue(key) == 5)
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
    assert(slot1.getIntValue(key) == 15)
    assert(slot1.getFloatValue(key) == 15.15)

    key = "key15.5"
    slot1.setFloatValue(key, 0.0)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "0")
    assert(slot1.getIntValue(key) == 0)
    assert(slot1.getFloatValue(key) == 0.0)
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())