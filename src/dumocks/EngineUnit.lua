--- Engines provide the thrust to move your ship forward. Atmospheric engines only work in the atmosphere, space
-- engines only work in space, and rocket engines work in both but can't be throttled.
--
-- Element class:
-- <ul>
--   <li>AtmosphericEngineXtraSmallGroup</li>
--   <li>AtmosphericEngineSmallGroup</li>
--   <li>SpaceEngineXtraSmallGroup</li>
--   <li>SpaceEngineSmallGroup</li>
--   <li>RocketEngine</li>
-- </ul>
--
-- Extends: @{Element} &gt; @{Engine} &gt; @{FueledEngine}
-- @module EngineUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockFueledEngine = require "dumocks.FueledEngine"

local CLASS_ATMO_XS = "AtmosphericEngineXtraSmallGroup"
local CLASS_ATMO_S = "AtmosphericEngineSmallGroup"
local CLASS_SPACE_XS = "SpaceEngineXtraSmallGroup"
local CLASS_SPACE_S = "SpaceEngineSmallGroup"
local CLASS_ROCKET = "RocketEngine"

local elementDefinitions = {}
elementDefinitions["basic atmospheric engine xs"] = {mass = 100.0, maxHitPoints = 50.0, itemId = 710193240, class = CLASS_ATMO_XS, maxThrust = 10000.0}
elementDefinitions["basic space engine xs"] = {mass = 146.23, maxHitPoints = 100.0, itemId = 2243775376, class = CLASS_SPACE_XS, maxThrust = 15000.0}
elementDefinitions["rocket engine s"] = {mass = 223.76, maxHitPoints = 113.0, itemId = 2112772336, class = CLASS_ROCKET, maxThrust = 500000.0}
elementDefinitions["rocket engine m"] = {mass = 680.05, maxHitPoints = 715.0, itemId = 3623903713, class = CLASS_ROCKET, maxThrust = 3000000.0}
elementDefinitions["rocket engine l"] = {mass = 3392.98, maxHitPoints = 9689.0, itemId = 359938916, class = CLASS_ROCKET, maxThrust = 18000000.0}
local DEFAULT_ELEMENT = "basic atmospheric engine xs"

local M = MockFueledEngine:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockFueledEngine:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    o.maxThrustBase = elementDefinition.maxThrust
    o.currentMaxThrust = o.maxThrustBase
    o.currentMinThrust = 0

    return o
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockFueledEngine.mockGetClosure(self)
    return closure
end

return M