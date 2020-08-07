--- Industry unit.
-- Can mass-produce produce any item/element.
-- @module MockIndustryUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {
-- Assembler XS: mass = 100.93, maxHitPoints = 2250.0
-- Assembler S: mass = 522.14, maxHitPoints = 7829.0
-- Assembler M: mass = 2802.36, maxHitPoints = 26422.0
-- Assembler L: mass = 15382.4, maxHitPoints = 89176.0
-- Assembler XL: mass = 86293.68, maxHitPoints = 300967.0
-- Transfer Unit: mass=10147.65, maxHitPoints = 1329.0
-- Refiner M: mass = 2302.34, maxHitPoints = 5540.0
}

local M = MockElement:new()
M.elementClass = "IndustryUnit"

function M:new(o, id, size)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    return o
end

-- @see MockElement:getClosure
function M:getClosure()
    local closure = MockElement.getClosure(self)
--    closure.getSelfMass = function() return self:getSelfMass() end
    return closure
end

return M