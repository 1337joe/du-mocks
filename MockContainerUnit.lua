--- Container unit.
-- Stores items.
-- @module MockContainerUnit
-- @alias M

local MockElement = require "MockElement"

local M = MockElement:new()
M.elementClass = "ItemContainer"

function M:new(o, id)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    -- undefine mass in favor of self and items mass
    o.mass = nil
    o.itemsMass = 0
    o.selfMass = 0

    return o
end

-- @see MockElement:getMass
function M:getMass()
    return self.selfMass + self.itemsMass
end

--- Returns the container content mass (the sum of the mass of all the items it contains).
-- @treturn kg The total mass of the container's content, excluding the container's own mass itself.
function M:getItemsMass()
    return self.itemsMass
end

--- Returns the container self mass.
-- @treturn kg The container self mass, as if it were empty.
function M:getSelfMass()
    return self.selfMass
end

-- @see MockElement:getClosure
function M:getClosure()
    local closure = MockElement.getClosure(self)
    closure.getMass = function() return self:getMass() end
    closure.getItemsMass = function() return self:getItemsMass() end
    closure.getSelfMass = function() return self:getSelfMass() end
    return closure
end

return M