#!/usr/bin/env lua
--- Tests on dumocks.ContainerUnit.
-- @see dumocks.ContainerUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.ContainerUnit")

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

os.exit(lu.LuaUnit.run())