#!/usr/bin/env lua
--- Tests on dumocks.ElementWithToggle.
-- @see dumocks.ElementWithToggle

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")
local utilities = require("test.Utilities")
local AbstractTestElementWithState = require("test.dumocks.AbstractTestElementWithState")

local AbstractTestElementWithToggle = AbstractTestElementWithState

--- Factory to produce the non-deprecated activate function for the element.
-- @tparam table closure The closure to extract the function from.
-- @treturn function The correct activate function.
    function AbstractTestElementWithToggle.getActivateFunction(closure)
    lu.fail("getActivateFunction must be overridden to test activate functionality.")
end

--- Factory to produce the non-deprecated deactivate function for the element.
-- @tparam table closure The closure to extract the function from.
-- @treturn function The correct deactivate function.
    function AbstractTestElementWithToggle.getDeactivateFunction(closure)
    lu.fail("getDeactivateFunction must be overridden to test deactivate functionality.")
end

--- Verify that activate leaves the element on.
function AbstractTestElementWithToggle.testActivate()
    local mock = AbstractTestElementWithToggle.getTestElement()
    local closure = mock:mockGetClosure()
    local activateOverride = AbstractTestElementWithToggle.getActivateFunction(closure)

    mock.state = false
    activateOverride()
    lu.assertTrue(mock.state)

    if activateOverride ~= closure.activate then
        mock.state = false
        utilities.verifyDeprecated("activate", closure.activate)
        lu.assertTrue(mock.state)
    end

    mock.state = true
    activateOverride()
    lu.assertTrue(mock.state)

    if activateOverride ~= closure.activate then
        mock.state = true
        utilities.verifyDeprecated("activate", closure.activate)
        lu.assertTrue(mock.state)
    end
end

--- Verify that deactivate leaves the element off.
function AbstractTestElementWithToggle.testDeactivate()
    local mock = AbstractTestElementWithToggle.getTestElement()
    local closure = mock:mockGetClosure()
    local deactivateOverride = AbstractTestElementWithToggle.getDeactivateFunction(closure)

    mock.state = false
    deactivateOverride()
    lu.assertFalse(mock.state)

    if deactivateOverride ~= closure.deactivate then
        mock.state = false
        utilities.verifyDeprecated("deactivate", closure.deactivate)
        lu.assertFalse(mock.state)
    end

    mock.state = true
    deactivateOverride()
    lu.assertFalse(mock.state)

    if deactivateOverride ~= closure.deactivate then
        mock.state = true
        utilities.verifyDeprecated("deactivate", closure.deactivate)
        lu.assertFalse(mock.state)
    end
end

--- Verify that toggle changes the state.
function AbstractTestElementWithToggle.testToggle()
    local mock = AbstractTestElementWithToggle.getTestElement()
    local closure = mock:mockGetClosure()

    mock.state = false
    closure.toggle()
    lu.assertTrue(mock.state)

    mock.state = true
    closure.toggle()
    lu.assertFalse(mock.state)
end

return AbstractTestElementWithToggle
