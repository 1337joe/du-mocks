#!/usr/bin/env lua
--- Tests on dumocks.ElementWithState.
-- @see dumocks.ElementWithState

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")
local utilities = require("test.Utilities")

local TestElementWithState = {}

--- Factory to create an element for testing. Must be overridden for tests to work.
-- @return A mock of the element to test.
function TestElementWithState.getTestElement()
    lu.fail("getTestElement must be overridden for TestElementWithState to work.")
end

--- Factory to produce the non-deprecated getState function for the element.
-- @tparam table closure The closure to extract the function from.
-- @treturn function The correct getState function.
function TestElementWithState.getStateFunction(closure)
    lu.fail("getStateFunction must be overridden to test getState functionality.")
end

--- Verify that get state retrieves the state properly.
function TestElementWithState.testGetState()
    local mock = TestElementWithState.getTestElement()
    local closure = mock:mockGetClosure()
    local getStateOverride = TestElementWithState.getStateFunction(closure)

    mock.state = false
    lu.assertEquals(getStateOverride(), 0)
    lu.assertEquals(utilities.verifyDeprecated("getState", closure.getState), 0)

    mock.state = true
    lu.assertEquals(getStateOverride(), 1)
    lu.assertEquals(utilities.verifyDeprecated("getState", closure.getState), 1)
end

return TestElementWithState