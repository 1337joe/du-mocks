#!/usr/bin/env lua
--- Tests on MockContainerUnit
-- @see MockContainerUnit

package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("MockContainerUnit")

--- Verify constructor arguments properly handled and independent between instances.
function testConstructor()

    -- default element:
    -- ["container s"] = {mass = 1281.31,maxHitPoints = 999.0}

    local databank1 = mcu:new(nil, 1, "Container XS")
    local databank2 = mcu:new(nil, 2, "invalid")
    local databank3 = mcu:new(nil, 3, "Container S")
    local databank4 = mcu:new(nil, 4, "Container L")
    local databank5 = mcu:new()

    local databank1Closure = databank1:getClosure()
    local databank2Closure = databank2:getClosure()
    local databank3Closure = databank3:getClosure()
    local databank4Closure = databank4:getClosure()
    local databank5Closure = databank5:getClosure()

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