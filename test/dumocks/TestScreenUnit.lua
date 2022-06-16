#!/usr/bin/env lua
--- Tests on dumocks.ScreenUnit.
-- @see dumocks.ScreenUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local msu = require("dumocks.ScreenUnit")
require("test.Utilities")

_G.TestScreenUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestScreenUnit.testConstructor()

    -- default element:
    -- ["screen xs"] = {mass = 18.67, maxHitPoints = 50.0}

    local screen0 = msu:new()
    local screen1 = msu:new(nil, 1, "Screen XS")
    local screen2 = msu:new(nil, 2, "invalid")
    local screen3 = msu:new(nil, 3, "Screen XL")
    local screen4 = msu:new(nil, 3, "Sign L")

    local screenClosure0 = screen0:mockGetClosure()
    local screenClosure1 = screen1:mockGetClosure()
    local screenClosure2 = screen2:mockGetClosure()
    local screenClosure3 = screen3:mockGetClosure()
    local screenClosure4 = screen4:mockGetClosure()

    lu.assertEquals(screenClosure0.getId(), 0)
    lu.assertEquals(screenClosure1.getId(), 1)
    lu.assertEquals(screenClosure2.getId(), 2)
    lu.assertEquals(screenClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 18.67
    lu.assertEquals(screenClosure0.getMass(), defaultMass)
    lu.assertEquals(screenClosure1.getMass(), defaultMass)
    lu.assertEquals(screenClosure2.getMass(), defaultMass)
    lu.assertNotEquals(screenClosure3.getMass(), defaultMass)

    -- verify different classes for different types
    lu.assertNotEquals(screenClosure3.getElementClass(), screenClosure4.getElementClass())
end

--- Verify listener is registered and notified on non-error updates.
function _G.TestScreenUnit.testRegisterHtmlCallback()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    local called = false
    local providedHtml = nil
    local callback = function(html)
        called = true
        providedHtml = html
    end
    mock:mockRegisterHtmlCallback(callback)

    lu.assertNil(providedHtml)

    -- specific set methods verify against mock.html
    -- just need to check to make sure that's what was sent to the callback
    closure.setCenteredText("1")
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    closure.setHTML("<div>test</div>")
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    closure.setSVG('<rect width="100" height="100" />')
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    -- addContent with existing SVG
    local id = closure.addContent(25, 50, "<div>text</div>")
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    closure.addText(50, 75, 10, "test")
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    closure.resetContent(id, "<div>new text</div>")
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    -- hide first content
    called = false
    closure.showContent(id, 0)
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    -- move hidden content
    called = false
    closure.moveContent(id, 75, 50)
    lu.assertTrue(called)

    -- delete hidden content
    called = false
    closure.deleteContent(id)
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)

    called = false
    closure.clear()
    lu.assertEquals(providedHtml, mock.html)
    lu.assertTrue(called)
end

--- Verify listener is registered and supresses errors in callbacks.
function _G.TestScreenUnit.testRegisterHtmlCallbackSuppressError()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.propagateHtmlErrors = false

    local callSequence = 0
    local call1Order, call2Order
    local providedHtml = nil
    local callback1Finished = false
    local callback1 = function(_)
        callSequence = callSequence + 1
        call1Order = callSequence

        error("This callback is problematic.")

        callback1Finished = true
    end
    mock:mockRegisterHtmlCallback(callback1)
    local callback2 = function(html)
        providedHtml = html

        callSequence = callSequence + 1
        call2Order = callSequence
    end
    mock:mockRegisterHtmlCallback(callback2)

    lu.assertNil(providedHtml)

    -- just need to set something to trigger the callbacks
    closure.setCenteredText("1")

    lu.assertNotNil(call1Order, "Callback 1 not called.")
    lu.assertFalse(callback1Finished, "Callback 1 finished despite error.")
    lu.assertNotNil(call2Order, "Callback 2 not called.")
    lu.assertTrue(call1Order < call2Order, "Callbacks called out of order.")

    -- might as well verify content
    lu.assertEquals(providedHtml, mock.html)
end

--- Verify listener is registered and propagates errors in callbacks.
function _G.TestScreenUnit.testRegisterHtmlCallbackPropagateError()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.propagateHtmlErrors = true

    local callSequence = 0
    local call1Order, call2Order
    local providedHtml = nil
    local callback1Finished = false
    local callback1 = function(_)
        callSequence = callSequence + 1
        call1Order = callSequence

        error("This callback is problematic.")

        callback1Finished = true
    end
    mock:mockRegisterHtmlCallback(callback1)
    local callback2 = function(html)
        providedHtml = html

        callSequence = callSequence + 1
        call2Order = callSequence
    end
    mock:mockRegisterHtmlCallback(callback2)

    lu.assertNil(providedHtml)

    -- just need to set something to trigger the callbacks
    lu.assertError(closure.setCenteredText, "1")

    lu.assertNotNil(call1Order, "Callback 1 not called.")
    lu.assertFalse(callback1Finished, "Callback 1 finished despite error.")
    lu.assertNotNil(call2Order, "Callback 2 not called.")
    lu.assertTrue(call1Order < call2Order, "Callbacks called out of order.")

    -- might as well verify content
    lu.assertEquals(providedHtml, mock.html)
end

--- Verify set centered text sets text correctly.
function _G.TestScreenUnit.testSetCenteredText()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    closure.setCenteredText(nil)
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:12.000000vw; "></div>')

    closure.setCenteredText("")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:12.000000vw; "></div>')

    closure.setCenteredText("1")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:12.000000vw; ">1</div>')

    closure.setCenteredText("12")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:11.000000vw; ">12</div>')

    closure.setCenteredText("123")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:10.415037vw; ">123</div>')

    closure.setCenteredText("1234")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:10.000000vw; ">1234</div>')

    closure.setCenteredText("12345678")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:9.000000vw; ">12345678</div>')

    closure.setCenteredText(1.0)
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:10.415037vw; ">1.0</div>')

    -- verify clears content
    table.insert(mock.contentList, {
        x = 0,
        y = 0,
        html = "<div>text</div>",
        visible = true
    })
    closure.setCenteredText("1234")
    lu.assertEquals(mock.html, '<div class="bootstrap" style="font-size:10.000000vw; ">1234</div>')
    lu.assertEquals(#mock.contentList, 0)
end

--- Verify set html does so.
function _G.TestScreenUnit.testSetHTML()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local html

    html = nil
    closure.setHTML(html)
    lu.assertEquals(mock.html, "")

    html = "<div>test</div>"
    closure.setHTML(html)
    lu.assertEquals(mock.html, html)

    html = 1.0
    closure.setHTML(html)
    lu.assertEquals(mock.html, "1.0")

    -- verify clears content
    table.insert(mock.contentList, {
        x = 0,
        y = 0,
        html = "<div>text</div>",
        visible = true
    })
    html = "<div>test</div>"
    closure.setHTML(html)
    lu.assertEquals(mock.html, html)
    lu.assertEquals(#mock.contentList, 0)
end

function _G.TestScreenUnit.testSetScriptInput()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local input

    input = nil
    closure.setScriptInput(input)
    lu.assertEquals(mock.scriptInput, "")

    input = ""
    closure.setScriptInput(input)
    lu.assertEquals(mock.scriptInput, input)

    input = "Text"
    closure.setScriptInput(input)
    lu.assertEquals(mock.scriptInput, input)

    input = 1.0
    closure.setScriptInput(input)
    lu.assertEquals(mock.scriptInput, "1.0")

    input = '{"json":"success"}'
    closure.setScriptInput(input)
    lu.assertEquals(mock.scriptInput, input)
end

function _G.TestScreenUnit.testClearScriptOutput()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    mock.scriptOutput = nil
    closure.clearScriptOutput()
    lu.assertEquals(mock.scriptOutput, "")

    mock.scriptOutput = ""
    closure.clearScriptOutput()
    lu.assertEquals(mock.scriptOutput, "")

    mock.scriptOutput = "Text"
    closure.clearScriptOutput()
    lu.assertEquals(mock.scriptOutput, "")
end

function _G.TestScreenUnit.testGetScriptOutput()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local output

    mock.scriptOutput = nil
    lu.assertEquals(closure.getScriptOutput(), "")

    output = ""
    mock.scriptOutput = output
    lu.assertEquals(closure.getScriptOutput(), output)

    output = "Text"
    mock.scriptOutput = output
    lu.assertEquals(closure.getScriptOutput(), output)

    output = 1.0
    mock.scriptOutput = output
    lu.assertEquals(closure.getScriptOutput(), "1.0")

    output = '{"json":"success"}'
    mock.scriptOutput = output
    lu.assertEquals(closure.getScriptOutput(), output)
end

--- Verify set svg sets fills template correctly.
function _G.TestScreenUnit.testSetSVG()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    closure.setSVG(nil)
    lu.assertEquals(mock.html, '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%; height:100%"></svg>')

    closure.setSVG("")
    lu.assertEquals(mock.html, '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%; height:100%"></svg>')

    closure.setSVG('<rect width="100" height="100" />')
    lu.assertEquals(mock.html, '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%; height:100%">' ..
        '<rect width="100" height="100" /></svg>')

    closure.setSVG(1.0)
    lu.assertEquals(mock.html,
        '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%; height:100%">1.0</svg>')

    -- verify clears content
    table.insert(mock.contentList, {
        x = 0,
        y = 0,
        html = "<div>text</div>",
        visible = true
    })
    closure.setSVG('<rect width="100" height="100" />')
    lu.assertEquals(mock.html, '<svg class="bootstrap" viewBox="0 0 1920 1080" style="width:100%; height:100%">' ..
        '<rect width="100" height="100" /></svg>')
    lu.assertEquals(#mock.contentList, 0)
end

function _G.TestScreenUnit.testAddContent()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y, id

    -- initial add
    x, y = 50, 75
    content = nil
    id = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"></div>')
    lu.assertEquals(1, id)

    -- second add is additive
    x, y = 25, 50
    content = "<div>test</div>"
    id = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>test</div></div>')
    lu.assertEquals(2, id)

    -- depends on clear working
    closure.clear()

    -- id number keeps counting up, no reset
    x, y = 75, 25
    content = "<div>test</div>"
    id = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:75.000000vw; top:25.000000vh; display: block;"><div>test</div></div>')
    lu.assertEquals(3, id)
end

function _G.TestScreenUnit.testAddText()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y, size, id

    -- initial add
    x, y, size = 50, 75, 10
    content = nil
    id = closure.addText(x, y, size, content)
    lu.assertEquals(mock.html, '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;">' ..
        '<div style="font-size:10.000000vw"></div></div>')
    lu.assertEquals(id, 1)

    -- second add is additive
    x, y, size = 25, 50, 20
    content = "test"
    id = closure.addText(x, y, size, content)
    lu.assertEquals(mock.html, '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;">' ..
        '<div style="font-size:10.000000vw"></div></div>' ..
        '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;">' ..
        '<div style="font-size:20.000000vw">test</div></div>')
    lu.assertEquals(id, 2)

    -- depends on clear working
    closure.clear()

    -- id number keeps counting up, no reset
    x, y = 75, 25
    content = "test"
    id = closure.addText(x, y, size, content)
    lu.assertEquals(mock.html, '<div style="position:absolute; left:75.000000vw; top:25.000000vh; display: block;">' ..
        '<div style="font-size:20.000000vw">test</div></div>')
    lu.assertEquals(3, id)
end

function _G.TestScreenUnit.testResetContent()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y, id

    -- depends on addContent working: initial add
    x, y = 50, 75
    content = nil
    id = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"></div>')
    lu.assertEquals(1, id)

    -- change content
    content = "<div>test</div>"
    closure.resetContent(id, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>test</div></div>')
end

function _G.TestScreenUnit.testDeleteContent()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y

    -- depends on addContent working: initial adds
    x, y = 50, 75
    content = "<div>1</div>"
    local id1 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>')
    lu.assertEquals(1, id1)

    x, y = 25, 50
    content = "<div>2</div>"
    local id2 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')
    lu.assertEquals(2, id2)

    -- delete visible content
    closure.deleteContent(id1)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- depends on showContent working: hide content
    closure.showContent(id2, 0)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: none;"><div>2</div></div>')

    -- delete non-visible content
    closure.deleteContent(id2)
    lu.assertEquals(mock.html, '')

    -- delete non-existent content
    closure.deleteContent(0)
    lu.assertEquals(mock.html, '')

    -- attempting to show deleted content has no effect
    closure.showContent(id1, 1)
    closure.showContent(id2, 1)
    lu.assertEquals(mock.html, '')
end

function _G.TestScreenUnit.testShowContent()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y

    -- depends on addContent working: initial adds
    x, y = 50, 75
    content = "<div>1</div>"
    local id1 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>')
    lu.assertEquals(1, id1)

    x, y = 25, 50
    content = "<div>2</div>"
    local id2 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')
    lu.assertEquals(2, id2)

    -- hide content
    closure.showContent(id1, 0)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: none;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- second hide makes no difference
    closure.showContent(id1, 0)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: none;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- set back to visible
    closure.showContent(id1, 1)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- second set visible true doesn't change result
    closure.showContent(id1, 1)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- doesn't exist, nothing changes
    closure.showContent(0, 1)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')
end

function _G.TestScreenUnit.testMoveContent()
    local mock = msu:new()
    local closure = mock:mockGetClosure()
    local content, x, y

    -- depends on addContent working: initial adds
    x, y = 50, 75
    content = "<div>1</div>"
    local id1 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>')
    lu.assertEquals(1, id1)

    x, y = 25, 50
    content = "<div>2</div>"
    local id2 = closure.addContent(x, y, content)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:50.000000vw; top:75.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')
    lu.assertEquals(2, id2)

    -- move visible content
    closure.moveContent(id1, 75, "50")
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:75.000000vw; top:50.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: block;"><div>2</div></div>')

    -- depends on showContent working: hide content
    closure.showContent(id2, 0)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:75.000000vw; top:50.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:25.000000vw; top:50.000000vh; display: none;"><div>2</div></div>')

    -- move non-visible content
    closure.moveContent(id2, "string", nil)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:75.000000vw; top:50.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:0.000000vw; top:0.000000vh; display: none;"><div>2</div></div>')

    -- move non-existent content
    closure.moveContent(0)
    lu.assertEquals(mock.html,
        '<div style="position:absolute; left:75.000000vw; top:50.000000vh; display: block;"><div>1</div></div>' ..
            '<div style="position:absolute; left:0.000000vw; top:0.000000vh; display: none;"><div>2</div></div>')
end

--- Verify clear blanks the screen.
function _G.TestScreenUnit.testClear()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    lu.assertEquals(mock.html, "")
    closure.clear()
    lu.assertEquals(mock.html, "")

    mock.directHtml = "<div>text</div>"
    -- this should not normally be directly set but trying not to rely on setters as those aren't being tested here
    mock.html = mock.directHtml
    lu.assertNotEquals(mock.html, "")
    closure.clear()
    lu.assertEquals(mock.html, "")

    -- verify clears content
    table.insert(mock.contentList, {
        x = 0,
        y = 0,
        html = "<div>text</div>",
        visible = true
    })
    closure.clear()
    lu.assertEquals(mock.html, "")
    lu.assertEquals(#mock.contentList, 0)
end

--- Verify getMouseX returns values within correct range.
function _G.TestScreenUnit.testGetMouseX()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    -- in bounds
    mock.mouseX = 0
    lu.assertEquals(closure.getMouseX(), 0.0)

    mock.mouseX = 0.5
    lu.assertEquals(closure.getMouseX(), 0.5)

    mock.mouseX = 1.0
    lu.assertEquals(closure.getMouseX(), 1.0)

    -- out of bounds
    mock.mouseX = -1
    lu.assertEquals(closure.getMouseX(), -1)

    mock.mouseX = -0.5
    lu.assertEquals(closure.getMouseX(), -1)

    mock.mouseX = 10
    lu.assertEquals(closure.getMouseX(), -1)
end

--- Verify getMouseY returns values within correct range.
function _G.TestScreenUnit.testGetMouseY()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    -- in bounds
    mock.mouseY = 0
    lu.assertEquals(closure.getMouseY(), 0.0)

    mock.mouseY = 0.5
    lu.assertEquals(closure.getMouseY(), 0.5)

    mock.mouseY = 1.0
    lu.assertEquals(closure.getMouseY(), 1.0)

    -- out of bounds
    mock.mouseY = -1
    lu.assertEquals(closure.getMouseY(), -1)

    mock.mouseY = -0.5
    lu.assertEquals(closure.getMouseY(), -1)

    mock.mouseY = 10
    lu.assertEquals(closure.getMouseY(), -1)
end

--- Verify getMouseState returns correct values.
function _G.TestScreenUnit.testGetMouseState()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    -- valid entries
    mock.mouseState = true
    lu.assertEquals(closure.getMouseState(), 1)

    mock.mouseState = false
    lu.assertEquals(closure.getMouseState(), 0)

    -- doesn't break on invalid entries: nil and false = 0, anything else = 1
    mock.mouseState = nil
    lu.assertEquals(closure.getMouseState(), 0)

    mock.mouseState = "String"
    lu.assertEquals(closure.getMouseState(), 1)
end

--- Verify unfiltered mouse down callback.
function _G.TestScreenUnit.testMouseDown()
    local mock = msu:new()

    local callSequence = 0
    local call1Order, call2Order, call3Order
    local expectedX, expectedY
    local actualX, actualY

    local callback1 = function(x, y)
        callSequence = callSequence + 1
        call1Order = callSequence

        actualX = x
        actualY = y
    end
    mock:mockRegisterMouseDown(callback1, "*", "*")

    local callback2 = function(_, _)
        callSequence = callSequence + 1
        call2Order = callSequence

        error("This callback is broken!")
    end
    mock:mockRegisterMouseDown(callback2, "*", "*")

    local callback3 = function(_, _)
        callSequence = callSequence + 1
        call3Order = callSequence
    end
    mock:mockRegisterMouseDown(callback3, "*", "*")

    expectedX = 0.5
    expectedY = 0.75

    -- verify error is propagated, all callbacks are hit in order, and values come through
    lu.assertError(mock.mockDoMouseDown, mock, expectedX, expectedY)
    lu.assertNotNil(call1Order)
    lu.assertNotNil(call2Order)
    lu.assertNotNil(call3Order)
    lu.assertTrue(call1Order < call2Order)
    lu.assertTrue(call2Order < call3Order)
    lu.assertEquals(actualX, expectedX)
    lu.assertEquals(actualY, expectedY)
end

--- Verify unfiltered mouse up callback.
function _G.TestScreenUnit.testMouseUp()
    local mock = msu:new()

    local callSequence = 0
    local call1Order, call2Order, call3Order
    local expectedX, expectedY
    local actualX, actualY

    local callback1 = function(x, y)
        callSequence = callSequence + 1
        call1Order = callSequence

        actualX = x
        actualY = y
    end
    mock:mockRegisterMouseUp(callback1, "*", "*")

    local callback2 = function(_, _)
        callSequence = callSequence + 1
        call2Order = callSequence

        error("This callback is broken!")
    end
    mock:mockRegisterMouseUp(callback2, "*", "*")

    local callback3 = function(_, _)
        callSequence = callSequence + 1
        call3Order = callSequence
    end
    mock:mockRegisterMouseUp(callback3, "*", "*")

    expectedX = 0.5
    expectedY = 0.75

    -- verify error is propagated, all callbacks are hit in order, and values come through
    lu.assertError(mock.mockDoMouseUp, mock, expectedX, expectedY)
    lu.assertNotNil(call1Order)
    lu.assertNotNil(call2Order)
    lu.assertNotNil(call3Order)
    lu.assertTrue(call1Order < call2Order)
    lu.assertTrue(call2Order < call3Order)
    lu.assertEquals(actualX, expectedX)
    lu.assertEquals(actualY, expectedY)
end

function _G.TestScreenUnit.testMockDoRenderScript()
    local mock = msu:new()
    local closure = mock:mockGetClosure()

    local script = [[
        assert(getInput() == "test input")
        local xRes, yRes = getResolution()
        setOutput(tostring(xRes))
    ]]

    closure.setScriptInput("test input")
    closure.setRenderScript(script)

    mock:mockDoRenderScript()

    lu.assertEquals(closure.getScriptOutput(), tostring(mock.resolutionX))
end

--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. 1x Screen or Sign (not XL), connected to Programming Board on slot1
--
-- Exercises: getElementClass, deactivate, activate, toggle, getState
function _G.TestScreenUnit.testGameBehavior()
    local mock = msu:new(nil, 1)
    local slot1 = mock:mockGetClosure()

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function()
    end
    local system = {}
    system.print = function()
    end

    ---------------
    -- copy from here to unit.start()
    ---------------
    -- verify expected functions
    local expectedFunctions = {"addText", "setCenteredText", "setHTML", "addContent", "setSVG", "resetContent",
                               "deleteContent", "showContent", "moveContent", "getMouseX", "getMouseY", "getMouseState",
                               "clear", "setRenderScript", "setScriptInput", "getScriptOutput", "clearScriptOutput",
                               "getSignalIn", "setSignalIn"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    for _, v in pairs(_G.Utilities.toggleFunctions) do
        table.insert(expectedFunctions, v)
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test element class and inherited methods
    local class = slot1.getElementClass()
    local isScreen
    if class == "ScreenUnit" then
        isScreen = true
    elseif class == "ScreenSignUnit" then
        isScreen = false
    else
        assert(false, "Unexpected class: " .. class)
    end
    assert(slot1.getMaxHitPoints() == 50.0)
    assert(slot1.getMass() == 18.67)
    _G.Utilities.verifyBasicElementFunctions(slot1, 3)

    -- play with set signal, has no actual effect on state when set programmatically
    local initialState = slot1.getState()
    slot1.setSignalIn("in", 0.0)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", 1.0)
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- fractions within [0,1] work, and string numbers are cast
    slot1.setSignalIn("in", 0.7)
    assert(slot1.getSignalIn("in") == 0.7)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.5")
    assert(slot1.getSignalIn("in") == 0.5)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "0.0")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", "7.0")
    assert(slot1.getSignalIn("in") == 1.0)
    assert(slot1.getState() == initialState)
    -- invalid sets to 0
    slot1.setSignalIn("in", "text")
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)
    slot1.setSignalIn("in", nil)
    assert(slot1.getSignalIn("in") == 0.0)
    assert(slot1.getState() == initialState)

    -- ensure initial state
    slot1.deactivate()
    assert(slot1.getState() == 0)

    -- validate methods
    slot1.activate()
    assert(slot1.getState() == 1)
    slot1.deactivate()
    assert(slot1.getState() == 0)
    slot1.toggle()
    assert(slot1.getState() == 1)

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())
