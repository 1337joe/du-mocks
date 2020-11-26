--- Based on the principle of the Alcubierre drive, this unit creates a powerful negative energy-density field capable
-- to distort space-time and transport your ship at hyper speeds through space.
--
-- Element class: WarpDriveUnit
--
-- Displayed widget fields:
-- <ul>
--   <li>elementId</li>
--   <li>buttonMsg</li>
--   <li>errorMsg</li>
--   <li>showError</li>
--   <li>cellCount</li>
--   <li>destination</li>
--   <li>distance</li>
-- </ul>
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

    o.warpActivated = false

    return o
end

local DATA_TEMPLATE = '{\"helperId\":\"warpdrive\",\"type\":\"%s\",\"name\":\"%s [%d]\",\"elementId\":\"%d\",\"' ..
                      'buttonMsg\":\"%s\",\"errorMsg\":\"%s\",\"showError\":%s,\"cellCount\":\"%s\",' ..
                      '\"destination\":\"%s\",\"distance\":%d}'
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
               showError, cellCount, destination, distance)
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Start the warp drive, if a warp destination has been selected. Displays an error message to the player's screen if
-- unable to warp, but doesn't throw a script error.
function M:activateWarp()
    self.warpActivated = true
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activateWarp = function() return self:activateWarp() end
    return closure
end

return M