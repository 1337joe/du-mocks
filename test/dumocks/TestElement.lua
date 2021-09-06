#!/usr/bin/env lua
--- Tests on dumocks.Element.
-- @see Element

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local me = require("dumocks.Element")

TestElement = {}

--- Verify element definition helper method behaves properly.
function TestElement.testFindElement()
    local expected, actual
    local elementDefinitions = {}
    elementDefinitions["container xs"] = {mass = 229.09, maxHitPoints = 124.0}
    elementDefinitions["container s"] = {mass = 1281.31,maxHitPoints = 999.0}
    elementDefinitions["container m"] = {mass = 7421.35,maxHitPoints = 7997.0}
    elementDefinitions["container l"] = {mass = 14842.7,maxHitPoints = 17316.0}
    local elementName
    local DEFAULT_ELEMENT = "container s"

    -- unset
    elementName = nil
    expected = {name = "container s", mass = 1281.31,maxHitPoints = 999.0}
    actual = me.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)

    -- invalid
    elementName = "invalid"
    expected = {name = "container s", mass = 1281.31,maxHitPoints = 999.0}
    actual = me.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)

    -- valid, not default
    elementName = "container xs"
    expected = {name = "container xs", mass = 229.09, maxHitPoints = 124.0}
    actual = me.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)

    -- valid, not default, capitalized
    elementName = "Container XS"
    expected = {name = "container xs", mass = 229.09, maxHitPoints = 124.0}
    actual = me.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)

    -- valid, default
    elementName = "container s"
    expected = {name = "container s", mass = 1281.31,maxHitPoints = 999.0}
    actual = me.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)

    -- default is nil
    elementName = nil
    expected = nil
    actual = me.findElement(elementDefinitions, elementName, nil)
    lu.assertEquals(actual, expected)

    -- elements map is empty
    elementName = nil
    expected = nil
    actual = me.findElement({}, elementName, DEFAULT_ELEMENT)
    lu.assertEquals(actual, expected)
end

--- Verify constructor passes ID through properly and that instances are independant.
function TestElement.testGetId()
    local element1 = me:new(nil, 1)
    local element2 = me:new(nil, 2)

    lu.assertEquals(element1:getId(), 1)
    lu.assertEquals(element2:getId(), 2)

    local closure1 = element1:mockGetClosure()
    local closure2 = element2:mockGetClosure()

    lu.assertEquals(closure1.getId(), 1)
    lu.assertEquals(closure2.getId(), 2)
end

function TestElement.testGetIntegrity()
    local expected, actual
    local element = me:new()
    local closure = element:mockGetClosure()
    element.maxHitPoints = 100

    element.hitPoints = 50
    expected = 50
    actual = closure.getIntegrity()
    lu.assertEquals(actual, expected)

    element.hitPoints = 30
    expected = 30
    actual = closure.getIntegrity()
    lu.assertEquals(actual, expected)

    element.hitPoints = 100
    expected = 100
    actual = closure.getIntegrity()
    lu.assertEquals(actual, expected)
end

os.exit(lu.LuaUnit.run())