#!/usr/bin/env lua
--- Tests on MockContainerUnit
-- @see MockContainerUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("MockContainerUnit")

--- Verify constructor passes ID through properly and that instances are independant.
function testGetId()
    local container1 = mcu:new(nil, 1)
    local container2 = mcu:new(nil, 2)

    lu.assertEquals(container1:getId(), 1)
    lu.assertEquals(container2:getId(), 2)

    local closure1 = container1:getClosure()
    local closure2 = container2:getClosure()

    lu.assertEquals(closure1.getId(), 1)
    lu.assertEquals(closure2.getId(), 2)
end

--- Verify element class is correct.
function testGetElementClass()
    local container = mcu:new():getClosure()
    lu.assertEquals(container.getElementClass(), "ItemContainer")
end

--- Get mass is a function of self mass and item mass, verify relationhip.
function testGetMass()
    local expected, actual
    local container = mcu:new()

    mcu.selfMass = 10
    mcu.itemsMass = 0
    expected = 10
    actual = mcu:getMass()
    lu.assertEquals(actual, expected)

    mcu.selfMass = 10
    mcu.itemsMass = 20
    expected = 30
    actual = mcu:getMass()
    lu.assertEquals(actual, expected)
end

os.exit(lu.LuaUnit.run())