--- Based on the principle of the Alcubierre drive, this unit creates a powerful negative energy-density field capable
-- to distort space-time and transport your ship at hyper speeds through space.
--
-- Element class: WarpDriveUnit
--
-- Extends: Element
-- @see Element
-- @module WarpDriveUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["warp drive l"] = {mass = 31360.0, maxHitPoints = 43117.0}
local DEFAULT_ELEMENT = "warp drive l"

local M = MockElement:new()
M.elementClass = "WarpDriveUnit"
M.widgetType = "warpdrive"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    return o
end

local DATA_TEMPLATE = '{\"helperId\":\"warpdrive\",\"type\":\"%s\",\"name\":\"%s [%d]\",\"elementId\":\"%d\",\"' ..
                      'buttonMsg\":\"%s\",\"errorMsg\":\"%s\",\"cellCount\":\"%s\",\"showError\":%s,' ..
                      '\"destination\":\"%s\",\"distance\":%d}'
--- Get element data as JSON.
--
-- Warp drives have a <code>warpdrive</code> widget, which contains the following fields (bold fields are visible when
-- making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">errorMsg</span></b> (<span class="type">string</span>) The error message to
--     display, if applicable.
--   <li><b><span class="parameter">showError</span></b> (<span class="type">boolean</span>) True if the error banner
--     should be shown, false otherwise.</li>
--   <li><b><span class="parameter">destination</span></b> (<span class="type">string</span>) The name of the current
--     warp destination.</li>
--   <li><b><span class="parameter">distance</span></b> (<span class="type">float</span>) The distance (in meters) to
--     the current warp target.</li>
--   <li><b><span class="parameter">cellCount</span></b> (<span class="type">string</span>) The number of warp cells
--     available over the number that will be consumed during travel to the current destination.</li>
--   <li><b><span class="parameter">buttonMsg</span></b> (<span class="type">string</span>) The button message to
--     display, defaults to "Activate Warp".
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">elementId</span> (<span class="type">int</span>) The (globally unique?) id of the 
--     warp drive element, may be related to linking the commands to the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>warpdrive</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>warpdrive</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getData()
    local warpDriveId = 123456789
    local buttonMsg = "CANNOT WARP"
    local errorMsg = "PLANET TOO CLOSE"
    local showError = true
    local totalCells = 0
    local requiredCells = 0
    local cellCount = string.format("%d / %d", totalCells, requiredCells)
    local destination = "Unknown"
    local distance = 0

    return string.format(DATA_TEMPLATE, self:getWidgetType(), self.name, self:getId(), warpDriveId, buttonMsg, errorMsg,
               cellCount, showError, destination, distance)
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    return closure
end

return M