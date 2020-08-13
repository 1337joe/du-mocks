--- Stores items.
-- @module ContainerUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["container xs"] = {mass = 229.09, maxHitPoints = 124.0, class = "ItemContainer"}
elementDefinitions["container s"] = {mass = 1281.31, maxHitPoints = 999.0, class = "ItemContainer"}
elementDefinitions["container m"] = {mass = 7421.35, maxHitPoints = 7997.0, class = "ItemContainer"}
elementDefinitions["container l"] = {mass = 14842.7, maxHitPoints = 17316.0, class = "ItemContainer"}

elementDefinitions["atmospheric fuel tank xs"] = {mass = 35.03, maxHitPoints = 50.0, class = "AtmoFuelContainer"}
elementDefinitions["atmospheric fuel tank s"] = {mass = 182.67, maxHitPoints = 163.0, class = "AtmoFuelContainer"}
elementDefinitions["atmospheric fuel tank m"] = {mass = 988.67, maxHitPoints = 1315.0, class = "AtmoFuelContainer"}
elementDefinitions["atmospheric fuel tank l"] = {mass = 5481.27, maxHitPoints = 10461.0, class = "AtmoFuelContainer"}

elementDefinitions["space fuel tank s"] = {mass = 182.67, maxHitPoints = 187.0, class = "SpaceFuelContainer"}
elementDefinitions["space fuel tank m"] = {mass = 988.67, maxHitPoints = 1496.0, class = "SpaceFuelContainer"}
elementDefinitions["space fuel tank m"] = {mass = 5481.27, maxHitPoints = 15933.0, class = "SpaceFuelContainer"}

local DEFAULT_ELEMENT = "container s"

local M = MockElement:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    self.elementClass = elementDefinition.class

    -- undefine mass in favor of self and items mass
    o.selfMass = o.mass
    o.mass = nil
    o.itemsMass = 0

    return o
end

-- @see Element:getMass
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

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getMass = function() return self:getMass() end
    closure.getItemsMass = function() return self:getItemsMass() end
    closure.getSelfMass = function() return self:getSelfMass() end
    return closure
end

return M