--- Stores items.
--
-- Element class: ItemContainer (item containers), AtmoFuelContainer (atmospheric fuel tanks),
--   SpaceFuelContainer (space fuel tanks), RocketFuelTank (rocket fuel tanks)
--
-- Displayed widget fields (fuel tanks only):
-- <ul>
--   <li>percentage</li>
--   <li>timeLeft</li>
-- </ul>
--
-- Extends: Element
-- @see Element
-- @module ContainerUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_ITEM = "ItemContainer"
local CLASS_ATMO = "AtmoFuelContainer"
local CLASS_SPACE = "SpaceFuelContainer"
local CLASS_ROCKET = "RocketFuelContainer"

local elementDefinitions = {}
elementDefinitions["container xs"] = {mass = 229.09, maxHitPoints = 124.0, class = CLASS_ITEM}
elementDefinitions["container s"] = {mass = 1281.31, maxHitPoints = 999.0, class = CLASS_ITEM}
elementDefinitions["container m"] = {mass = 7421.35, maxHitPoints = 7997.0, class = CLASS_ITEM}
elementDefinitions["container l"] = {mass = 14842.7, maxHitPoints = 17316.0, class = CLASS_ITEM}

elementDefinitions["atmospheric fuel tank xs"] = {mass = 35.03, maxHitPoints = 50.0, class = CLASS_ATMO}
elementDefinitions["atmospheric fuel tank s"] = {mass = 182.67, maxHitPoints = 163.0, class = CLASS_ATMO}
elementDefinitions["atmospheric fuel tank m"] = {mass = 988.67, maxHitPoints = 1315.0, class = CLASS_ATMO}
elementDefinitions["atmospheric fuel tank l"] = {mass = 5481.27, maxHitPoints = 10461.0, class = CLASS_ATMO}

elementDefinitions["space fuel tank s"] = {mass = 182.67, maxHitPoints = 187.0, class = CLASS_SPACE}
elementDefinitions["space fuel tank m"] = {mass = 988.67, maxHitPoints = 1496.0, class = CLASS_SPACE}
elementDefinitions["space fuel tank l"] = {mass = 5481.27, maxHitPoints = 15933.0, class = CLASS_SPACE}

elementDefinitions["rocket fuel tank xs"] = {mass = 173.42, maxHitPoints = 366.0, class = CLASS_ROCKET}
elementDefinitions["rocket fuel tank s"] = {mass = 886.72, maxHitPoints = 736.0, class = CLASS_ROCKET}
elementDefinitions["rocket fuel tank m"] = {mass = 4724.43, maxHitPoints = 6231.0, class = CLASS_ROCKET}
elementDefinitions["rocket fuel tank l"] = {mass = 25741.76, maxHitPoints = 68824.0, class = CLASS_ROCKET}


local DEFAULT_ELEMENT = "container s"

local M = MockElement:new()

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    if o.elementClass == CLASS_ITEM then
    else
        o.widgetType = "fuel_container"
        if o.elementClass == CLASS_ATMO then
            o.helperId = "fuel_container_atmo_fuel"
        elseif o.elementClass == CLASS_SPACE then
            o.helperId = "fuel_container_space_fuel"
        elseif o.elementClass == CLASS_ROCKET then
            o.helperId = "fuel_container_rocket_fuel"
        end
    end

    -- undefine mass in favor of self and items mass
    o.selfMass = o.mass
    o.mass = nil
    o.itemsMass = 0

    -- for fuel tanks
    o.percentage = 0.0
    o.timeLeft = "n/a"

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

local DATA_TEMPLATE = '{\"name\":\"%s [%d]\","percentage":%.16f,"timeLeft":%s,\"helperId\":\"%s\",\"type\":\"%s\"}'
function M:getData()
    if self.elementClass == CLASS_ITEM then
        return MockElement:getData()
    end
    return string.format(DATA_TEMPLATE, self.name, self:getId(), self.percentage, self.timeLeft, self.helperId, self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    if self.elementClass == CLASS_ITEM then
        return MockElement:getDataId()
    end
    return "e123456"
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