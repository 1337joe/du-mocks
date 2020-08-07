--- Container unit.
-- Stores items.
-- @module MockContainerUnit
-- @alias M

local MockElement = require "MockElement"

local containerDefinitions = {
    XS = {
        selfMass = 229.09,
        maxHitPoints = 124.0
    },
    S = {
        selfMass = 1281.31,
        maxHitPoints = 999.0
    },
    M = {
        selfMass = 7421.35,
        maxHitPoints = 7997.0
    },
    L = {
        selfMass = 14842.7
        maxHitPoints = 17316.0
    }
}

local M = MockElement:new()
M.elementClass = "ItemContainer"

function M:new(o, id, size)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    -- undefine mass in favor of self and items mass
    o.mass = nil
    o.itemsMass = 0

    -- default to S
    if containerDefinitions[size] == nil then
        size = "S"
    end
    o.selfMass = containerDefinitions[size].selfMass
    o.maxHitPoints = containerDefinitions[size].maxHitPoints
    o.hitPoints = containerDefinitions[size].hitPoints

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