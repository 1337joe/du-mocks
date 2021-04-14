#!/usr/bin/env lua
--- Tests on dumocks.ElementWithState.
-- @see dumocks.ElementWithState

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mews = require("dumocks.ElementWithState")

_G.TestElementWithState = {}

--- Verify that get state retrieves the state properly.
function _G.TestElementWithState.testGetState()
    local mock = mews:new()
    local closure = mock:mockGetClosure()

    mock.state = false
    lu.assertEquals(closure.getState(), 0)

    mock.state = true
    lu.assertEquals(closure.getState(), 1)
end

os.exit(lu.LuaUnit.run())
