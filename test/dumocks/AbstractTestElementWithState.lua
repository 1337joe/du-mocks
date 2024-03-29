#!/usr/bin/env lua
--- Tests on dumocks.ElementWithState.
-- @see dumocks.ElementWithState

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")
local utilities = require("test.Utilities")

local AbstractTestElementWithState = {}

--- Factory to create an element for testing. Must be overridden for tests to work.
-- @return A mock of the element to test.
function AbstractTestElementWithState.getTestElement()
    lu.fail("getTestElement must be overridden for AbstractTestElementWithState to work.")
end

--- Factory to produce the non-deprecated getState function for the element.
-- @tparam table closure The closure to extract the function from.
-- @treturn function The correct getState function.
function AbstractTestElementWithState.getStateFunction(closure)
    lu.fail("getStateFunction must be overridden to test getState functionality.")
end

--- Verify that get state retrieves the state properly.
function AbstractTestElementWithState.testGetState()
    local mock = AbstractTestElementWithState.getTestElement()
    local closure = mock:mockGetClosure()
    local getStateOverride = AbstractTestElementWithState.getStateFunction(closure)

    mock.state = false
    lu.assertEquals(getStateOverride(), 0)
    lu.assertEquals(utilities.verifyDeprecated("getState", closure.getState), 0)

    mock.state = true
    lu.assertEquals(getStateOverride(), 1)
    lu.assertEquals(utilities.verifyDeprecated("getState", closure.getState), 1)
end

return AbstractTestElementWithState