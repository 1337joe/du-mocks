--- Base type for all mock DU elements.
-- @module MockElement
-- @alias M

-- define class fields
local M = {
    elementClass = "",
    widgetType = "",
}

function M:new(o, id)
    -- define default instance fields
    o = o or {
        widgetShown = true,
        mass = 0,
        maxHitPoints = 100,
        hitPoints = 100,
    }
    setmetatable(o, self)
    self.__index = self

    o.id = id or 0

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
    return nil
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
    -- TODO query state
    return 0
end

--- Return the value of a signal in the specified OUT plug of the element.
-- Standard plug names are composed with the following syntax => direction-type-index where 'direction' can be IN or
-- OUT, 'type' is one of the following => ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number
-- between 0 and the total number of plugs of the given type in the given direction. Some plugs have special names like
-- "on" or "off" for the manual switch unit, just check in-game for the plug names if you have a doubt.
-- @param plug The plug name of the form OUT-SIGNAL-index
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    -- TODO query state
    return 0
end

--- Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing this object.
function M:getClosure()
    local closure = {}
    closure.hide = function() return self:hide() end
    closure.show = function() return self:show() end
    closure.getIntegrity = function() return self:getIntegrity() end
    closure.getId = function() return self:getId() end
    closure.getElementClass = function() return self:getElementClass() end
    return closure
end

return M