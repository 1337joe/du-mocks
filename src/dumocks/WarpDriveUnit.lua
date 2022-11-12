--- Based on the principle of the Alcubierre drive, this unit creates a powerful negative energy-density field capable
-- to distort space-time and transport your ship at hyper speeds through space.
--
-- <p style="color:red;">Note: This is generated from patch notes and in-game codex and has not yet been tested
--   against the actual element. Accuracy not guaranteed.</p>
--
-- Element class: WarpDriveUnit
--
-- Extends: @{Element}
-- @module WarpDriveUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["warp drive l"] = {mass = 75000.0, maxHitPoints = 43117.0, itemId = 4015850440}
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

local DATA_TEMPLATE = '{\"helperId\":\"warpdrive\",\"type\":\"%s\",\"name\":\"%s\",\"elementId\":\"%d\",\"' ..
                      'buttonText\":\"%s\",\"statusText\":\"%s\",\"cellCount\":\"%s\",\"showError\":%s,' ..
                      '\"destination\":\"%s\",\"distance\":%d,\"enableButton\":%s}'
--- Get element data as JSON.
--
-- Warp drives have a <code>warpdrive</code> widget, which contains the following fields (bold fields are visible when
-- making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">statusText</span></b> (<span class="type">string</span>) The status message to
--     display.
--   <li><b><span class="parameter">showError</span></b> (<span class="type">boolean</span>) True if the status banner
--     should be red, false otherwise.</li>
--   <li><b><span class="parameter">destination</span></b> (<span class="type">string</span>) The name of the current
--     warp destination.</li>
--   <li><b><span class="parameter">distance</span></b> (<span class="type">float</span>) The distance (in meters) to
--     the current warp target.</li>
--   <li><b><span class="parameter">cellCount</span></b> (<span class="type">string</span>) The number of warp cells
--     available over the number that will be consumed during travel to the current destination.</li>
--   <li><b><span class="parameter">buttonText</span></b> (<span class="type">string</span>) The button message to
--     display, defaults to "Activate Warp".
--   <li><b><span class="parameter">enableButton</span></b> (<span class="type">boolean</span>) True if the button
--     should be enabled, false otherwise.
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">elementId</span> (<span class="type">int</span>) The (globally unique?) id of the 
--     warp drive element, may be related to linking the commands to the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>warpdrive</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>warpdrive</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    local warpDriveId = 123456789
    local buttonText = "Cannot Warp"
    local statusText = "INVALID CONSTRUCT"
    local showError = true
    local totalCells = self:getAvailableWarpCells()
    local requiredCells = self:getRequiredWarpCells()
    local cellCount = string.format("%d / %d", totalCells, requiredCells)
    local destination = "Unknown"
    local distance = self:getDistance()
    local enableButton = false

    return string.format(DATA_TEMPLATE, self:getWidgetType(), self.name, warpDriveId, buttonText, statusText, cellCount,
        showError, destination, distance, enableButton)
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Initiate the warp jump process.
function M:initiate()
end

--- Returns the current status of the warp drive.
--
-- Possible states:
-- <ul>
--   <li>1: NoWarpDrive</li>
--   <li>2: Broken</li>
--   <li>3: Warping</li>
--   <li>4: ParentWarping</li>
--   <li>5: NotAnchored</li>
--   <li>6: WarpCooldown</li>
--   <li>7: PvPCooldown</li>
--   <li>8: MovingChild</li>
--   <li>9: NoContainer</li>
--   <li>10: PlanetTooClose</li>
--   <li>11: DestinationNotSet</li>
--   <li>12: DestinationTooClose</li>
--   <li>13: DestinationTooFar</li>
--   <li>14: NotEnoughWarpCells</li>
--   <li>15: Ready</li>
-- </ul>
-- @treturn int The current status of the warp drive.
function M:getStatus()
    return 15
end

--- Returns the distance to the current warp destination.
-- @treturn float The distance to the current warp destination.
function M:getDistance()
    return 0
end

--- Returns the construct ID of the current warp destination.
-- @treturn int The construct ID of the warp destination.
function M:getDestination()
    return 0
end

--- Returns the name of the current warp destination construct.
-- @treturn string The warp destination name.
function M:getDestinationName()
end

--- Returns the local ID of the container linked to the warp drive.
-- @treturn int The local ID of the container.
function M:getContainerId()
    return 0
end

--- Returns the quantity of warp cells available in the linked container.
-- @treturn int The quantity of warp cells.
function M:getAvailableWarpCells()
    return 0
end

--- Returns the quantity of warp cells required to warp to the warp destination set.
-- @treturn int The quantity of warp cells.
function M:getRequiredWarpCells()
    return 0
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.initiate = function() return self:initiate() end
    closure.getStatus = function() return self:getStatus() end
    closure.getDistance = function() return self:getDistance() end
    closure.getDestination = function() return self:getDestination() end
    closure.getDestinationName = function() return self:getDestinationName() end
    closure.getContainerId = function() return self:getContainerId() end
    closure.getAvailableWarpCells = function() return self:getAvailableWarpCells() end
    closure.getRequiredWarpCells = function() return self:getRequiredWarpCells() end
    return closure
end

return M