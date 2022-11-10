--- Extracts a regular amount of plasma from the space surrounding an alien core.
--
-- <p style="color:red;">Note: This is generated from patch notes and in-game codex and has not yet been tested
--   against the actual element. Accuracy not guaranteed.</p>
--
-- Element class: ???
--
-- Extends: @{Element}
-- @module PlasmaExtractorUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["relic plasma extractor l"] = {mass = 16500.0, itemId = 4024529716}
local DEFAULT_ELEMENT = "relic plasma extractor l"

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    return o
end

-- <b>Deprecated:</b> Returns the current status of the plasma extractor.
--
-- This method is deprecated: getState should be used instead
-- @see getState
-- @treturn string The status of the plasma extractor can be: "STOPPED", "RUNNING", "JAMMED_OUTPUT_FULL".
function M:getStatus()
    M.deprecated("getStatus", "getState")
    return "STOPPED"
end

--- Returns the current state of the plasma extractor.
-- @treturn int The state of the plasma extractor can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no
--   output container = 4)
function M:getState()
    return 1
end

--- Returns the remaining time of the current batch extraction process.
-- @treturn float The remaining time in seconds.
function M:getRemainingTime()
end

--- Returns the list of available plasma pools.
-- @treturn table A list of tables composed with {[int] oreId, [int] quantity}.
function M:getPlasmaPools()
end

--- Event: Emitted when the plasma extractor started a new extraction process.
--
-- Note: This is documentation on an event handler, not a callable method.
function M:EVENT_onStarted()
    assert(false, "This is implemented for documentation purposes.")
end

-- <b>Deprecated:</b> Event: Emitted when the plasma extractor completes a batch.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onCompleted should be used instead.
-- @see EVENT_onCompleted
function M.EVENT_completed()
    M.deprecated("EVENT_completed", "EVENT_onCompleted")
    M.EVENT_onCompleted()
end

--- Event: Emitted when the plasma extractor completes a batch.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_onCompleted()
    assert(false, "This is implemented for documentation purposes.")
end

-- <b>Deprecated:</b> Event: Emitted when the plasma extractor status is changed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onStateChanged should be used instead.
-- @see EVENT_onStateChanged
-- @tparam string status The new status of the plasma extractor, can be: "STOPPED", "RUNNING", "JAMMED_OUTPUT_FULL".
function M.EVENT_statusChanged(status)
    M.deprecated("EVENT_statusChanged", "EVENT_onStateChanged")
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the plasma extractor state is changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int state The state of the plasma extractor can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no
--   output container = 4)
function M.EVENT_onStateChanged(state)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the plasma extractor stopped the extraction process.
--
-- Note: This is documentation on an event handler, not a callable method.
function M:EVENT_onStopped()
    assert(false, "This is implemented for documentation purposes.")
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getState = function() return self:getState() end
    closure.getRemainingTime = function() return self:getRemainingTime() end
    closure.getPlasmaPools = function() return self:getPlasmaPools() end
    return closure
end

return M