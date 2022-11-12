--- Extracts a regular amount of resources from the ground.
--
-- Element class: MiningUnit
--
-- Extends: @{Element}
-- @module MiningUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["basic mining unit s"] = {mass = 180.0, maxHitPoints = 2500.0, itemId = 1949562989}
elementDefinitions["basic mining unit l"] = {mass = 5130.0, maxHitPoints = 11250.0, itemId = 3204140760}
elementDefinitions["uncommon mining unit l"] = {mass = 5160.0, maxHitPoints = 11250.0, itemId = 3204140761}
elementDefinitions["advanced mining unit l"] = {mass = 7500.0, maxHitPoints = 11250.0, itemId = 3204140766}
elementDefinitions["rare mining unit l"] = {mass = 7800.0, maxHitPoints = 11250.0, itemId = 3204140767}
elementDefinitions["exotic mining unit l"] = {mass = 8500.0, maxHitPoints = 11250.0, itemId = 3204140764}
local DEFAULT_ELEMENT = "basic mining unit s"

local M = MockElement:new()
M.elementClass = "MiningUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    return o
end

--- <b>Deprecated:</b> Returns the current status of the mining unit.
--
-- This method is deprecated: getState should be used instead
-- @see getState
-- @treturn string The status of the mining unit can be: "STOPPED", "RUNNING", "JAMMED_OUTPUT_FULL".
function M:getStatus()
    M.deprecated("getStatus", "getState")
    return "STOPPED"
end

--- Returns the current state of the mining unit.
-- @treturn int The state of the mining unit can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no
--   output container = 4)
function M:getState()
    return 1
end

--- Returns the remaining time of the current batch extraction process.
-- @treturn float The remaining time in seconds.
function M:getRemainingTime()
end

--- Returns the item ID of the currently selected ore.
-- @treturn int The item ID of the selected ore.
function M:getActiveOre()
end

--- Returns the list of available ore pools.
-- @treturn table A list of tables composed with {[int] oreId, [float] available, [float] maximum}.
function M:getOrePools()
end

--- Returns the base production rate of the mining unit.
-- @treturn float The production rate in L/h.
function M:getBaseRate()
end

--- Returns the efficiency rate of the mining unit.
-- @treturn float The efficiency rate.
function M:getEfficiency()
end

--- Returns the calibration rate of the mining unit.
-- @treturn float The calibration rate of the mining unit.
function M:getCalibrationRate()
end

--- Returns the optimal calibration rate of the mining unit.
-- @treturn float the optimal calibration rate of the mining unit.
function M:getOptimalRate()
end

--- Returns the current production rate of the mining unit.
-- @treturn float The production rate in L/h.
function M:getProductionRate()
end

--- Returns the territory's adjacency bonus to the territory of the mining unit.
-- @treturn float The territory's adjacency bonus.
function M:getAdjacencyBonus()
end

--- Returns the position of the last calibration excavation, in world coordinates.
-- @treturn The coordinates in world coordinates.
function M:getLastExtractionPosition()
end

--- Returns the ID of the last player who calibrated the mining unit.
-- @treturn int The ID of the player.
function M:getLastExtractingPlayerId()
end

--- Returns the time in seconds since the last calibration of the mining unit.
-- @treturn float The time in seconds with milliseconds precision.
function M:getLastExtractionTime()
end

--- Returns the item ID of the ore extracted during the last calibration excavation.
-- @treturn int The item ID of the extracted ore.
function M:getLastExtractedOre()
end

--- Returns the volume of ore extracted during the last calibration excavation.
-- @treturn float The volume of ore extracted in L.
function M:getLastExtractedVolume()
end

--- <b>Deprecated:</b> Event: Emitted when the mining unit is calibrated.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onCalibrated should be used instead.
-- @see EVENT_onCalibrated
-- @tparam int oreId The item ID of the ore extracted during the calibration process.
-- @tparam float amount Amount of ore extracted during the calibration process.
-- @tparam float rate The new calibration rate after calibration process.
function M.EVENT_calibrated(oreId, amount, rate)
    M.deprecated("EVENT_calibrated", "EVENT_onCalibrated")
    M.EVENT_onCalibrated(oreId, rate, amount)
end

--- Event: Emitted when the mining unit is calibrated.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int oreId The item ID of the ore extracted during the calibration process.
-- @tparam float rate The new calibration rate after calibration process.
-- @tparam float amount Amount of ore extracted during the calibration process.
function M:EVENT_onCalibrated(oreId, rate, amount)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the mining unit started a new extraction process.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int oreId The item ID of the ore mined during the extraction process.
function M:EVENT_onStarted(oreId)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the mining unit completes a batch.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onCompleted should be used instead.
-- @see EVENT_onCompleted
-- @tparam int oreId The item ID of the ore mined during the extraction process.
-- @tparam float amount Amount of ore mined.
function M.EVENT_completed(oreId, amount)
    M.deprecated("EVENT_completed", "EVENT_onCompleted")
    M.EVENT_onCompleted(oreId, amount)
end

--- Event: Emitted when the mining unit completes a batch.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int oreId The item ID of the ore mined during the extraction process.
-- @tparam float amount Amount of ore mined.
function M.EVENT_onCompleted(oreId, amount)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the mining unit status is changed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onStateChanged should be used instead.
-- @see EVENT_onStateChanged
-- @tparam string status The new status of the mining unit, can be: "STOPPED", "RUNNING", "JAMMED_OUTPUT_FULL".
function M.EVENT_statusChanged(status)
    M.deprecated("EVENT_statusChanged", "EVENT_onStateChanged")
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the mining unit state is changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int state The state of the mining unit can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no
--   output container = 4)
function M.EVENT_onStateChanged(state)
    assert(false, "This is implemented for documentation purposes.")
end

--- Event: Emitted when the mining unit stopped the extraction process.
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
    closure.getStatus = function() return self:getStatus() end
    closure.getState = function() return self:getState() end
    closure.getRemainingTime = function() return self:getRemainingTime() end
    closure.getActiveOre = function() return self:getActiveOre() end
    closure.getOrePools = function() return self:getOrePools() end
    closure.getBaseRate = function() return self:getBaseRate() end
    closure.getEfficiency = function() return self:getEfficiency() end
    closure.getAdjacencyBonus = function() return self:getAdjacencyBonus() end
    closure.getCalibrationRate = function() return self:getCalibrationRate() end
    closure.getOptimalRate = function() return self:getOptimalRate() end
    closure.getProductionRate = function() return self:getProductionRate() end
    closure.getLastExtractionPosition = function() return self:getLastExtractionPosition() end
    closure.getLastExtractingPlayerId = function() return self:getLastExtractingPlayerId() end
    closure.getLastExtractionTime = function() return self:getLastExtractionTime() end
    closure.getLastExtractedOre = function() return self:getLastExtractedOre() end
    closure.getLastExtractedVolume = function() return self:getLastExtractedVolume() end
    return closure
end

return M