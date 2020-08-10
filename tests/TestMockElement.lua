#!/usr/bin/env lua
--- Tests on MockElement
-- @see MockElement

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local me = require("MockElement")

--- Verify constructor passes ID through properly and that instances are independant.
function testGetId()
    local element1 = me:new(nil, 1)
    local element2 = me:new(nil, 2)

    lu.assertEquals(element1:getId(), 1)
    lu.assertEquals(element2:getId(), 2)

    local closure1 = element1:mockGetClosure()
    local closure2 = element2:mockGetClosure()

    lu.assertEquals(closure1.getId(), 1)
    lu.assertEquals(closure2.getId(), 2)
end

function testGetIntegrity()
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