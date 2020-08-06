#!/usr/bin/env lua
--- Tests on MockDatabankUnit
-- @see MockDatabankUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mdu = require("MockDatabankUnit")

--- Verify constructor passes ID through properly and that instances are independant.
function testGetId()
    local databank1 = mdu:new(nil, 1):getClosure()
    local databank2 = mdu:new(nil, 2):getClosure()

    lu.assertEquals(databank1.getId(), 1)
    lu.assertEquals(databank2.getId(), 2)
end

--- Verify element class is correct.
function testGetElementClass()
    local databank = mdu:new():getClosure()
    lu.assertEquals(databank.getElementClass(), "DataBankUnit")
end

--- Verify that clear empties the databank.
function testClear()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:getClosure()

    databank.data = {key = 1}
    closure.clear()
    lu.assertEquals(databank.data, {})

    databank.data = {key = 1, key2 = "string"}
    closure.clear()
    lu.assertEquals(databank.data, {})
end

--- Verify number of keys counts properly.
function testGetNbKeys()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:getClosure()

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
function testGetKeys()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:getClosure()

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
function testHasKey()
    local actual, expected
    local databank = mdu:new()
    local closure = databank:getClosure()

    expected = 0
    actual = closure.hasKey("key")
    lu.assertEquals(actual, expected)

    databank.data["key"] = "value"
    expected = 1
    actual = closure.hasKey("key")
    lu.assertEquals(actual, expected)
end

--- Verify storage as string works.
function testSetStringValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:getClosure()

    -- string value
    key = "key1"
    expected = "value1"
    closure.setStringValue(key, expected)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- int value
    key = "key2"
    expected = "2"
    closure.setStringValue(key, 2)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- float value
    key = "key3"
    expected = "3.1"
    closure.setStringValue(key, 3.1)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsString(actual)

    -- TODO unknown edge case behavior, test in-game
    -- nil value
    key = "key4"
    expected = ""
    closure.setStringValue(key, nil)
    actual = databank.data[key]
    lu.fail("NYI")
--    lu.assertEquals(actual, expected)
--    lu.assertIsString(actual)

    -- boolean value
    key = "key5"
    expected = "true"
    closure.setStringValue(key, true)
    actual = databank.data[key]
    lu.fail("NYI")
--    lu.assertEquals(actual, expected)
--    lu.assertIsString(actual)
end

--- Verify retrieval as string works.
function testGetStringValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:getClosure()

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

--- Verify storage as int works.
function testSetIntValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:getClosure()

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
    lu.assertIsNil(actual)

    -- TODO unknown edge case behavior, test in-game
    -- string
    -- boolean
    lu.fail("NYI")
end

--- Verify retrieval as int works.
function testGetIntValue()
    lu.fail("NYI")
end

--- Verify storage as int works.
function testSetFloatValue()
    local actual, expected, key
    local databank = mdu:new()
    local closure = databank:getClosure()

    -- float value
    key = "key1"
    expected = 1.2
    closure.setFloatValue(key, expected)
    actual = databank.data[key]
    lu.assertEquals(actual, expected)
    lu.assertIsNumber(actual)

    -- TODO unknown edge case behavior, test in-game
    -- 1
    -- string
    -- boolean
    lu.fail("NYI")
end

--- Verify retrieval as float works.
function testGetFloatValue()
    lu.fail("NYI")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function testGameBehavior()
    local databank = mdu:new()
    local slot1 = databank:getClosure()

    -- copy from here
    local key

    key = "key1"
    slot1.setStringValue(key, "string")
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "string")
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

    key = "key5"
    slot1.setStringValue(key, 5.5)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "5.5")
    assert(slot1.getIntValue(key) == 5)
    assert(slot1.getFloatValue(key) == 5.5)

    key = "key6"
    slot1.setIntValue(key, "string")
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

    key = "key10"
    slot1.setIntValue(key, 10.1)
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

    key = "key15"
    slot1.setFloatValue(key, 15.15)
    assert(slot1.hasKey(key) == 1)
    assert(slot1.getStringValue(key) == "15.15")
    assert(slot1.getIntValue(key) == 15)
    assert(slot1.getFloatValue(key) == 15.15)
    -- copy to here
end

os.exit(lu.LuaUnit.run())