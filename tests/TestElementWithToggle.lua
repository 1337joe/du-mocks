#!/usr/bin/env lua
--- Tests on dumocks.ElementWithToggle.
-- @see dumocks.ElementWithToggle

-- set search path to include root of project
package.path = package.path .. ";../?.lua"

local lu = require("luaunit")

local mewt = require("dumocks.ElementWithToggle")

_G.TestElementWithToggle = {}

--- Verify that activate leaves the element on.
function _G.TestElementWithToggle.testActivate()
    local mock = mewt:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.activate()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.activate()
    lu.assertTrue(mock.state)
end

--- Verify that deactivate leaves the element off.
function _G.TestElementWithToggle.testDeactivate()
    local mock = mewt:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.deactivate()
    lu.assertFalse(mock.state)

    mock.state = true
    closure.deactivate()
    lu.assertFalse(mock.state)
end

--- Verify that toggle changes the state.
function _G.TestElementWithToggle.testToggle()
    local mock = mewt:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

os.exit(lu.LuaUnit.run())
