#!/usr/bin/env lua
--- Tests on dumocks.CoreUnit.
-- @see dumocks.CoreUnit

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.CoreUnit")

_G.TestCoreUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestCoreUnit.testConstructor()

    -- default element:
    -- ["dynamic core unit xs"] = {mass = 70.89, maxHitPoints = 50.0, class = "CoreUnitDynamic"}

    local control0 = mcu:new()
    local control1 = mcu:new(nil, 1, "Dynamic Core Unit XS")
    local control2 = mcu:new(nil, 2, "invalid")
    local control3 = mcu:new(nil, 3, "Static Core Unit M")

    local controlClosure0 = control0:mockGetClosure()
    local controlClosure1 = control1:mockGetClosure()
    local controlClosure2 = control2:mockGetClosure()
    local controlClosure3 = control3:mockGetClosure()

    lu.assertEquals(controlClosure0.getId(), 0)
    lu.assertEquals(controlClosure1.getId(), 1)
    lu.assertEquals(controlClosure2.getId(), 2)
    lu.assertEquals(controlClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 70.89
    lu.assertEquals(controlClosure0.getMass(), defaultMass)
    lu.assertEquals(controlClosure1.getMass(), defaultMass)
    lu.assertEquals(controlClosure2.getMass(), defaultMass)
    lu.assertNotEquals(controlClosure3.getMass(), defaultMass)
end

--- Verify element class is correct.
function _G.TestCoreUnit.testGetElementClass()
    local element

    element = mcu:new(nil, 1, "dynamic core unit xs"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CoreUnitDynamic")

    element = mcu:new(nil, 1, "space core unit xs"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CoreUnitSpace")

    element = mcu:new(nil, 1, "static core unit m"):mockGetClosure()
    lu.assertEquals(element.getElementClass(), "CoreUnitStatic")
end

--- Sample block to test in-game behavior, can run on mock and uses assert instead of luaunit to run in-game.
function _G.TestCoreUnit.skipTestGameBehavior()
    local mock = mcu:new()
    local slot1 = mock:mockGetClosure()

    -- copy from here to unit.start
    assert(slot1.getElementClass() == "CoreUnitDynamic")

    assert(false, "Not Yet Implemented")
    -- copy to here to unit.start
end

os.exit(lu.LuaUnit.run())