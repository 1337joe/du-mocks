--- All elements share the same generic methods described below.
--
-- Extended by:
-- <ul>
--   <li>@{ContainerUnit}</li>
--   <li>@{ControlUnit}</li>
--   <li>@{CoreUnit}</li>
--   <li>@{CounterUnit}</li>
--   <li>@{DatabankUnit}</li>
--   <li>@{DetectionZoneUnit}</li>
--   <li>@{ElementWithState}</li>
--   <li>@{EmitterUnit}</li>
--   <li>@{FireworksUnit}</li>
--   <li>@{IndustryUnit}</li>
--   <li>@{MiningUnit}</li>
--   <li>@{PlasmaExtractorUnit}</li>
--   <li>@{RadarUnit}</li>
--   <li>@{ReceiverUnit}</li>
--   <li>@{TelemeterUnit}</li>
--   <li>@{WarpDriveUnit}</li>
--   <li>@{WeaponUnit}</li>
-- </ul>
-- @module Element
-- @alias M

-- define class fields
local M = {
    elementClass = "",
    widgetType = "",
    remainingRestorations = 3,
    maxRestorations = 3,
}

-- Non ldoc: Helper function, looks up an element definition by name, defaulting to defaultName if not found.
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
        chosenDefinition.name = chosenDefinition.name or elementName
    end
    return chosenDefinition
end

function M:new(o, localId, elementDefinition)
    -- define default instance fields
    o = o or {
        widgetShown = true,
        mass = 0, -- kg
        maxHitPoints = 100,
        hitPoints = 100,
    }
    setmetatable(o, self)
    self.__index = self

    o.localId = localId or 0
    o.name = ""

    if elementDefinition then
        o.name = string.format("%s [%d]", elementDefinition.name, o.localId)
        o.mass = elementDefinition.mass or 0
        o.maxHitPoints = elementDefinition.maxHitPoints or 100
        o.hitPoints = elementDefinition.maxHitPoints or 100
        o.itemId = elementDefinition.itemId or 0
    end

    -- element orientation vectors, named to avoid collision with deprecated GyroUnit methods
    o.up = {0, 0, 1}
    o.right = {1, 0, 0}
    o.forward = {0, 1, 0}
    o.upWorld = {0, 0, 1}
    o.rightWorld = {1, 0, 0}
    o.forwardWorld = {0, 1, 0}

    o.loaded = 1

    return o
end

-- Non ldoc: prints the deprecation message with optional method to use instead. Tacked onto Element for easy access.
-- @tparam strin oldMethodName The method that is deprecated.
-- @tparam string newMethodName The replacement method.
function M.deprecated(oldMethodName, newMethodName)
    local replacementMessage = ""
    if newMethodName then
        replacementMessage = string.format(", use %s instead", newMethodName)
    end
    local message = string.format("Warning: method %s is deprecated%s", oldMethodName, replacementMessage)

    if _G.system and _G.system.print and type(_G.system.print) == "function" then
        _G.system.print(message)
    else
        print(message)
    end
end

--- <b>Deprecated:</b> Show the element's widget in the in-game widget stack.
--
-- This method is deprecated: showWidget should be used instead.
-- @see showWidget
function M:show()
    M.deprecated("show", "showWidget")
    self:showWidget()
end

--- Show the element's widget in the in-game widget stack.
function M:showWidget()
    self.widgetShown = true
end

--- <b>Deprecated:</b> Hide the element's widget in the in-game widget stack.
--
-- This method is deprecated: hideWidget should be used instead.
-- @see hideWidget
function M:hide()
    M.deprecated("hide", "hideWidget")
    self:hideWidget()
end

--- Hide the element's widget in the in-game widget stack.
function M:hideWidget()
    self.widgetShown = false
end

--- Returns the widget type compatible with the element data.
-- @treturn string Widget type. "" if invalid.
function M:getWidgetType()
    return self.widgetType
end

--- <b>Deprecated:</b> Returns the element data as JSON.
--
-- This method is deprecated: getWidgetData should be used instead.
-- @see getWidgetData
-- @treturn string Data as JSON.
function M:getData()
    M.deprecated("getData", "getWidgetData")
    return self:getWidgetData()
end

--- Returns the element data as JSON.
-- @treturn string Data as JSON.
function M:getWidgetData()
    return "{}"
end

--- <b>Deprecated:</b> Returns the element data ID. Used to link en element to a custom widget.
--
-- This method is deprecated: getWidgetDataId should be used instead.
-- @see getWidgetDataId
-- @treturn string Data ID. "" if invalid.
-- @see system.addDataToWidget
function M:getDataId()
    M.deprecated("getDataId", "getWidgetDataId")
    return self:getWidgetDataId()
end

--- Returns the element data ID. Used to link en element to a custom widget.
-- @treturn string Data ID. "" if invalid.
-- @see system.addDataToWidget
function M:getWidgetDataId()
    return ""
end

--- Returns the element's name.
-- @treturn string The element's name.
function M:getName()
    return self.name
end

--- <b>Deprecated:</b> The class of the element.
--
-- This method is deprecated: getClass should be used instead.
-- @see getClass
-- @treturn string The class name of the element.
function M:getElementClass()
    M.deprecated("getElementClass", "getClass")
    return self:getClass()
end

--- The class of the element.
-- @treturn string The class name of the element.
function M:getClass()
    return self.elementClass
end

--- Returns the mass of the element (includes the included items' mass when the element is a container).
-- @treturn float The mass of the element in kg.
function M:getMass()
    return self.mass
end

--- Returns the element item ID (to be used with system.getItem() function to get information about the element).
-- @treturn int The element item ID.
function M:getItemId()
    return self.itemId
end

--- <b>Deprecated:</b> A construct unique ID for the element.
--
-- This method is deprecated: getLocalId should be used instead.
-- @see getLocalId
-- @return The element ID.
function M:getId()
    M.deprecated("getId", "getLocalId")
    return self:getLocalId()
end

--- Returns the unique local ID of the element.
-- @treturn int The element local ID.
function M:getLocalId()
    return self.localId
end

--- Returns the element's integrity between 0 and 100.
-- @treturn float 0 = element fully destroyed, 100 = element fully functional.
function M:getIntegrity()
    return 100 * self.hitPoints / self.maxHitPoints
end

--- Returns the element's current hit points (0 = destroyed).
-- @treturn float The hit points, where 0 = element fully destroyed.
function M:getHitPoints()
    return self.hitPoints
end

--- Returns the element's maximal hit points.
-- @treturn float The max hit points of the element.
function M:getMaxHitPoints()
    return self.maxHitPoints
end

--- Returns the element's remaining number of restorations.
-- @treturn int The number of restorations before the element is ultimately destroyed.
function M:getRemainingRestorations()
    return self.remainingRestorations
end

--- Returns the element's maximal number of restorations.
-- @treturn int The max number of restorations of the element.
function M:getMaxRestorations()
    return self.maxRestorations
end

--- Returns the position of the element in construct local coordinates.
-- @treturn vec3 The position of the element in construct local coordinates.
function M:getPosition()
end

--- Returns the bounding box dimensions of the element.
-- @treturn vec3 The dimensions of the element bounding box.
function M:getBoundingBoxSize()
end

--- Returns the position of the center of bounding box of the element in local construct coordinates.
-- @treturn vec3 The position of the center of the bounding box.
function M:getBoundingBoxCenter()
end

--- Returns the up direction vector of the element in construct local coordinates.
-- @treturn vec3 Up direction vector of the element in construct local coordinates.
function M:getUp()
    return self.up
end

--- Returns the right direction vector of the element in construct local coordinates.
-- @treturn vec3 Right direction vector of the element in construct local coordinates.
function M:getRight()
    return self.right
end

--- Returns the forward direction vector of the element in construct local coordinates.
-- @treturn vec3 Forward direction vector of the element in construct local coordinates.
function M:getForward()
    return self.forward
end

--- Returns the up direction vector of the element in world coordinates.
-- @treturn vec3 Up direction vector of the element in world coordinates.
function M:getWorldUp()
    return self.upWorld
end

--- Returns the right direction vector of the element in world coordinates.
-- @treturn vec3 Right direction vector of the element in world coordinates.
function M:getWorldRight()
    return self.rightWorld
end

--- Returns the forward direction vector of the element in world coordinates.
-- @treturn vec3 Forward direction vector of the element in world coordinates.
function M:getWorldForward()
    return self.forwardWorld
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Standard plug names are built with the following syntax: direction-type-index.
-- <ul>
--   <li><span class="parameter">direction</span>IN or OUT</li>
--   <li><span class="parameter">type</span>ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, or CONTROL</li>
--   <li><span class="parameter">index</span>A number between 0 and the total number of plugs of the given type in the
--     given direction.</li>
-- </ul>
--
-- Some plugs have special names like "on" or "off" for the manual switch unit, just check in-game for the plug names
-- if you have a doubt.
--
-- Note: This will have no effect if called on a plug that is connected to something that generates a signal, such as a
-- switch or button.
-- @tparam string plug The plug name, of the form IN-SIGNAL-index
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    -- TODO store state
end

--- Returns the value of a signal in the specified IN plug of the element.
--
-- Standard plug names are built with the following syntax: direction-type-index.
-- <ul>
--   <li><span class="parameter">direction</span>IN or OUT</li>
--   <li><span class="parameter">type</span>ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, or CONTROL</li>
--   <li><span class="parameter">index</span>A number between 0 and the total number of plugs of the given type in the
--     given direction.</li>
-- </ul>
--
-- Some plugs have special names like "on" or "off" for the manual switch unit, just check in-game for the plug names
-- if you have a doubt.
-- @tparam string plug The plug name of the form IN-SIGNAL-index
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    -- default response for invalid plug name
    return -1
end

--- Returns the value of a signal in the specified OUT plug of the element.
--
-- Standard plug names are built with the following syntax: direction-type-index.
-- <ul>
--   <li><span class="parameter">direction</span>IN or OUT</li>
--   <li><span class="parameter">type</span>ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, or CONTROL</li>
--   <li><span class="parameter">index</span>A number between 0 and the total number of plugs of the given type in the
--     given direction.</li>
-- </ul>
--
-- Some plugs have special names like "on" or "off" for the manual switch unit, just check in-game for the plug names
-- if you have a doubt.
-- @tparam string plug The plug name of the form OUT-SIGNAL-index
-- @treturn 0/1 The plug signal state
function M:getSignalOut(plug)
    -- default response for invalid plug name
    return -1
end

--- Returns 1 if element is loaded and 0 otherwise. Elements may unload if the player gets too far away from them, at
-- which point calls to their api will stop responding as expected. This state can only be recovered from by restarting
-- the script.
-- @treturn 0/1 The element load state.
function M:load()
    return self.loaded
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.show = function() return self:show() end
    closure.showWidget = function() return self:showWidget() end
    closure.hide = function() return self:hide() end
    closure.hideWidget = function() return self:hideWidget() end
    closure.getWidgetType = function() return self:getWidgetType() end
    closure.getData = function() return self:getData() end
    closure.getWidgetData = function() return self:getWidgetData() end
    closure.getDataId = function() return self:getDataId() end
    closure.getWidgetDataId = function() return self:getWidgetDataId() end
    closure.getName = function() return self:getName() end
    closure.getElementClass = function() return self:getElementClass() end
    closure.getClass = function() return self:getClass() end
    closure.getMass = function() return self:getMass() end
    closure.getItemId = function() return self:getItemId() end
    closure.getId = function() return self:getId() end
    closure.getLocalId = function() return self:getLocalId() end
    closure.getIntegrity = function() return self:getIntegrity() end
    closure.getHitPoints = function() return self:getHitPoints() end
    closure.getMaxHitPoints = function() return self:getMaxHitPoints() end
    closure.getRemainingRestorations = function() return self:getRemainingRestorations() end
    closure.getMaxRestorations = function() return self:getMaxRestorations() end
    closure.getPosition = function() return self:getPosition() end
    closure.getBoundingBoxSize = function() return self:getBoundingBoxSize() end
    closure.getBoundingBoxCenter = function() return self:getBoundingBoxCenter() end
    closure.getUp = function() return self:getUp() end
    closure.getRight = function() return self:getRight() end
    closure.getForward = function() return self:getForward() end
    closure.getWorldUp = function() return self:getWorldUp() end
    closure.getWorldRight = function() return self:getWorldRight() end
    closure.getWorldForward = function() return self:getWorldForward() end

    -- not applicable to all elements, add in individual element definitions where appropriate
    -- closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    -- closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    -- closure.getSignalOut = function(plug) return self:getSignalOut(plug) end

    closure.load = function() return self:load() end
    return closure
end

return M