--- Base type for all mock DU elements.
--
-- Extended by:
-- <ul>
--   <li>ContainerUnit</li>
--   <li>ControlUnit</li>
--   <li>CoreUnit</li>
--   <li>CounterUnit</li>
--   <li>DatabankUnit</li>
--   <li>DetectionZoneUnit</li>
--   <li>ElementWithState</li>
--   <li>EmitterUnit</li>
--   <li>IndustryUnit</li>
--   <li>RadarUnit</li>
--   <li>ReceiverUnit</li>
--   <li>TelemeterUnit</li>
--   <li>WarpDriveUnit</li>
-- </ul>
-- @see ContainerUnit
-- @see ControlUnit
-- @see CoreUnit
-- @see CounterUnit
-- @see DatabankUnit
-- @see DetectionZoneUnit
-- @see ElementWithState
-- @see EmitterUnit
-- @see IndustryUnit
-- @see RadarUnit
-- @see ReceiverUnit
-- @see TelemeterUnit
-- @see WarpDriveUnit
-- @module Element
-- @alias M

-- define class fields
local M = {
    elementClass = "",
    widgetType = "",
}

-- Helper function, looks up an element definition by name, defaulting to defaultName if not found.
-- @tparam table elementDefinitions The element definitions to search, keys are lower case element names.
-- @tparam string elementName The name to search the definitions for.
-- @tparam string defaultName The name to fall back to if elementName is not found.
function M.findElement(elementDefinitions, elementName, defaultName)
    if not elementName then
        elementName = defaultName
    else
        elementName = string.lower(elementName)
        if not elementDefinitions[elementName] then
            elementName = defaultName
        end
    end

    local chosenDefinition = elementDefinitions[elementName]
    if chosenDefinition then
        chosenDefinition.name = elementName
    end
    return chosenDefinition
end

function M:new(o, id, elementDefinition)
    -- define default instance fields
    o = o or {
        widgetShown = true,
        mass = 0, -- kg
        maxHitPoints = 100,
        hitPoints = 100,
    }
    setmetatable(o, self)
    self.__index = self

    o.id = id or 0
    o.name = "" -- not directly accessible but used to label default widgets; defaults to name of element type

    if elementDefinition then
        o.name = elementDefinition.name or ""
        o.mass = elementDefinition.mass or 0
        o.maxHitPoints = elementDefinition.maxHitPoints or 100
        o.hitPoints = elementDefinition.maxHitPoints or 100
    end

    return o
end

--- Show the element widget in the in-game widget stack.
function M:show()
    self.widgetShown = true
end

--- Hide the element widget in the in-game widget stack.
function M:hide()
    self.widgetShown = false
end

--- Get element data as JSON.
-- @treturn string Data as JSON.
function M:getData()
    return "{}"
end

--- Get element data ID.
-- @treturn string Data ID. "" if invalid.
function M:getDataId()
    return ""
end

--- Get widget type compatible with the element data.
-- @treturn string Widget type. "" if invalid.
function M:getWidgetType()
    return self.widgetType
end

--- The element integrity between 0 and 100.
-- @treturn 0..100 0 = element fully destroyed, 100 = element fully functional
function M:getIntegrity()
    return 100 * self.hitPoints / self.maxHitPoints
end

--- The element current hit points (0 = destroyed).
-- @return The hit points, where 0 = element fully destroyed.
function M:getHitPoints()
    return self.hitPoints
end

--- The element's maximal hit points when it's fully functional.
-- @return The max hit points of the element.
function M:getMaxHitPoints()
    return self.maxHitPoints
end

--- A construct unique ID for the element.
-- @return The element ID.
function M:getId()
    return self.id
end

--- The mass of the element.
-- @treturn kg The mass of the element (includes the included items' mass when the element is a container).
function M:getMass()
    return self.mass
end

--- The class of the element.
-- @treturn string The class name of the element.
function M:getElementClass()
    return self.elementClass
end

--- Set the value of a signal in the specified IN plug of the element.
-- Standard plug names are composed with the following syntax => direction-type-index where 'direction' can be IN or
-- OUT, 'type' is one of the following => ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number
-- between 0 and the total number of plugs of the given type in the given direction. Some plugs have special names like
-- "on" or "off" for the manual switch unit, just check in-game for the plug names if you have a doubt.
--
-- Note: This will have no effect if called on a plug that is connected to something that generates a signal, such as a
-- switch or button.
-- @param plug The plug name, of the form IN-SIGNAL-index
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    -- TODO store state
end

--- Return the value of a signal in the specified IN plug of the element.
-- Standard plug names are composed with the following syntax => direction-type-index where 'direction' can be IN or
-- OUT, 'type' is one of the following => ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number
-- between 0 and the total number of plugs of the given type in the given direction. Some plugs have special names like
-- "on" or "off" for the manual switch unit, just check in-game for the plug names if you have a doubt.
-- @param plug The plug name of the form IN-SIGNAL-index
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    -- default response for invalid plug name
    return -1
end

--- Return the value of a signal in the specified OUT plug of the element.
-- Standard plug names are composed with the following syntax => direction-type-index where 'direction' can be IN or
-- OUT, 'type' is one of the following => ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number
-- between 0 and the total number of plugs of the given type in the given direction. Some plugs have special names like
-- "on" or "off" for the manual switch unit, just check in-game for the plug names if you have a doubt.
-- @param plug The plug name of the form OUT-SIGNAL-index
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    -- default response for invalid plug name
    return -1
end

---Unknown use, but present in all elements.
function M:load()
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.show = function() return self:show() end
    closure.hide = function() return self:hide() end
    closure.getData = function() return self:getData() end
    closure.getDataId = function() return self:getDataId() end
    closure.getWidgetType = function() return self:getWidgetType() end
    closure.getIntegrity = function() return self:getIntegrity() end
    closure.getHitPoints = function() return self:getHitPoints() end
    closure.getMaxHitPoints = function() return self:getMaxHitPoints() end
    closure.getId = function() return self:getId() end
    closure.getMass = function() return self:getMass() end
    closure.getElementClass = function() return self:getElementClass() end

    -- not applicable to all elements, add in individual element definitions where appropriate
    -- closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    -- closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    -- closure.getSignalOut = function(plug) return self:getSignalOut(plug) end

    closure.load = function() return self:load() end
    return closure
end

return M