--- Containers are elements designed to store items and resources.
--
-- Element class:
-- <ul>
--   <li>ContainerSmallGroup (for XS item containers)</li>
--   <li>ContainerMediumGroup (for S item containers)</li>
--   <li>ContainerLargeGroup (for M item containers)</li>
--   <li>ContainerXLGroup (for L item containers)</li>
--   <li>ContainerXXLGroup (for XL item containers)</li>
--   <li>ContainerXXXLGroup (for expanded XL item containers)</li>
--   <li>MissionContainer</li>
--   <li>AtmoFuelContainer</li>
--   <li>SpaceFuelContainer</li>
--   <li>RocketFuelTank</li>
-- </ul>
--
-- Extends: @{Element}
-- @module ContainerUnit
-- @alias M

local MockElement = require "dumocks.Element"

local XS_GROUP = "ContainerSmallGroup"
local S_GROUP = "ContainerMediumGroup"
local M_GROUP = "ContainerLargeGroup"
local L_GROUP = "ContainerXLGroup"
local XL_GROUP = "ContainerXXLGroup"
local EXL_GROUP = "ContainerXXXLGroup"
local CLASS_PARCEL = "MissionContainer"
local CLASS_AMMO = "AmmoContainerUnit"
local CLASS_ATMO = "AtmoFuelContainer"
local CLASS_SPACE = "SpaceFuelContainer"
local CLASS_ROCKET = "RocketFuelContainer"

local elementDefinitions = {}
elementDefinitions["basic container xs"] = {mass = 229.09, maxHitPoints = 124.0, itemId = 1689381593, class = XS_GROUP, maxVolume = 1000}
elementDefinitions["basic container s"] = {mass = 1281.31, maxHitPoints = 999.0, itemId = 1594689569, class = S_GROUP, maxVolume = 8000}
elementDefinitions["basic container m"] = {mass = 7421.35, maxHitPoints = 7997.0, class = M_GROUP, maxVolume = 64000}
elementDefinitions["basic container l"] = {mass = 14842.7, maxHitPoints = 17316.0, class = L_GROUP, maxVolume = 128000}
elementDefinitions["basic container xl"] = {mass = 44206.0, maxHitPoints = 34633.0, class = XL_GROUP, maxVolume = 256000}
elementDefinitions["basic expanded container xl"] = {mass = 88413.0, maxHitPoints = 69267.0, class = EXL_GROUP, maxVolume = 512000}

elementDefinitions["parcel container xs"] = {mass = 224.68, maxHitPoints = 124.0, itemId = 386276308, class = CLASS_PARCEL, maxVolume = 1000}
elementDefinitions["parcel container s"] = {mass = 1256.17, maxHitPoints = 999.0, class = CLASS_PARCEL, maxVolume = 8000}
elementDefinitions["parcel container m"] = {mass = 7273.75, maxHitPoints = 7997.0, class = CLASS_PARCEL, maxVolume = 64000}
elementDefinitions["parcel container l"] = {mass = 14547.5, maxHitPoints = 17316.0, class = CLASS_PARCEL, maxVolume = 128000}
elementDefinitions["parcel container xl"] = {mass = 43313.71, maxHitPoints = 34633.0, class = CLASS_PARCEL, maxVolume = 256000}
elementDefinitions["expanded parcel container xl"] = {mass = 86627.42, maxHitPoints = 69267.0, class = CLASS_PARCEL, maxVolume = 512000}

elementDefinitions["ammo container xs"] = {mass = 216.15, maxHitPoints = 124.0, itemId = 300986010, class = CLASS_AMMO, maxVolume = 1000}
elementDefinitions["ammo container s"] = {mass = 1168.95, maxHitPoints = 999.0, class = CLASS_AMMO, maxVolume = 8000}
elementDefinitions["ammo container m"] = {mass = 6439.05, maxHitPoints = 7997.0, class = CLASS_AMMO, maxVolume = 64000}
elementDefinitions["ammo container l"] = {mass = 12878.1, maxHitPoints = 17316.0, class = CLASS_AMMO, maxVolume = 128000}

elementDefinitions["atmospheric fuel tank xs"] = {mass = 35.03, maxHitPoints = 50.0, itemId = 3273319200, class = CLASS_ATMO, maxVolume = 100}
elementDefinitions["atmospheric fuel tank s"] = {mass = 182.67, maxHitPoints = 163.0, class = CLASS_ATMO, maxVolume = 400}
elementDefinitions["atmospheric fuel tank m"] = {mass = 988.67, maxHitPoints = 1315.0, class = CLASS_ATMO, maxVolume = 1600}
elementDefinitions["atmospheric fuel tank l"] = {mass = 5481.27, maxHitPoints = 10461.0, class = CLASS_ATMO, maxVolume = 12800}

elementDefinitions["space fuel tank xs"] = {mass = 35.03, maxHitPoints = 50, itemId = 2421673145, class = CLASS_SPACE, maxVolume = 100}
elementDefinitions["space fuel tank s"] = {mass = 182.67, maxHitPoints = 187.0, class = CLASS_SPACE, maxVolume = 400}
elementDefinitions["space fuel tank m"] = {mass = 988.67, maxHitPoints = 1496.0, class = CLASS_SPACE, maxVolume = 1600}
elementDefinitions["space fuel tank l"] = {mass = 5481.27, maxHitPoints = 15933.0, class = CLASS_SPACE, maxVolume = 12800}

elementDefinitions["rocket fuel tank xs"] = {mass = 173.42, maxHitPoints = 366.0, class = CLASS_ROCKET, maxVolume = 400}
elementDefinitions["rocket fuel tank s"] = {mass = 886.72, maxHitPoints = 736.0, class = CLASS_ROCKET, maxVolume = 800}
elementDefinitions["rocket fuel tank m"] = {mass = 4724.43, maxHitPoints = 6231.0, class = CLASS_ROCKET, maxVolume = 6400}
elementDefinitions["rocket fuel tank l"] = {mass = 25741.76, maxHitPoints = 68824.0, class = CLASS_ROCKET, maxVolume = 50000}

local DEFAULT_ELEMENT = "basic container s"

local M = MockElement:new()
M.remainingRestorations = 5
M.maxRestorations = 5

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    if o.elementClass == CLASS_ATMO then
        o.widgetType = "fuel_container"
        o.helperId = "fuel_container_atmo_fuel"
    elseif o.elementClass == CLASS_SPACE then
        o.widgetType = "fuel_container"
        o.helperId = "fuel_container_space_fuel"
    elseif o.elementClass == CLASS_ROCKET then
        o.widgetType = "fuel_container"
        o.helperId = "fuel_container_rocket_fuel"
    end

    -- undefine mass in favor of self and items mass
    o.selfMass = o.mass
    o.mass = nil
    o.itemsMass = 0
    o.itemsVolume = 0
    o.maxVolume = elementDefinition.maxVolume

    -- for fuel tanks
    o.percentage = 0.0
    o.timeLeft = "n/a"

    o.storageRequested = false
    o.storageCallbacks = {}
    o.storageItems = nil
    o.remainingCooldown = 0

    return o
end

-- @see Element:getMass
function M:getMass()
    return self.selfMass + self.itemsMass
end

--- Returns the mass of the container element (as if it were empty).
-- @treturn float The mass of the container in kilograms.
function M:getSelfMass()
    return self.selfMass
end

--- Returns the container content mass (the sum of the mass of all the items it contains).
-- @treturn float The total mass of the contents of the container, excluding the container's own mass, in kilograms.
function M:getItemsMass()
    return self.itemsMass
end

--- Returns the container content volume (the sum of the volume of all items it contains).
-- @treturn float The total volume of the contents of the container in liters.
function M:getItemsVolume()
    return self.itemsVolume
end

--- Returns the maximum volume of the container.
-- @treturn float The maximum volume of the container in liters.
function M:getMaxVolume()
    return self.maxVolume
end

--- <b>Deprecated:</b> Returns the list of items in the container, as a json string you need to parse with json.decode.
-- @treturn jsonstr The container content as a json list of json objects with fields: name, quantity, unitVolume, unitMass, type, class
function M:getItemsList()
    M.deprecated("getItemsList", "getContent")
    return ""
end

--- Returns a table describing the contents of the container, as a pair itemId and quantity per slot.
--
-- Note: You have to request the contents of the container from the server by calling updateContent first.
-- @treturn table The contents of the container as a table with fields {[int] id, [float] quantity} per slot.
-- @see updateContent
function M:getContent()
    return self.storageItems
end

--- <b>Deprecated:</b>Initiate the acquisition of the storage in the container, required before calls to getItemsList.
-- Simply wait for the event 'storageAcquired' to be emitted by the container, and you can then use the storage related
-- functions.
--
-- Note: This is rate-limited to 10 queries / 5 minutes. Attempting to call more frequently will result in console error messages.
--
-- This method is deprecated: updateContent should be used instead.
-- @see getItemsList
-- @see EVENT_storageAcquired
-- @see updateContent
function M:acquireStorage()
    M.deprecated("acquireStorage", "updateContent")
    self:updateContent()
end

--- Send a request to get an update of the content of the container, limited to one call allowed per 30 seconds. The
-- onContentUpdate event is emitted by the container when the content is updated.
-- @treturn float If the request is not yet possible, returns the remaining time to wait for in seconds.
-- @see getContent
-- @see EVENT_onContentUpdate
function M:updateContent()
    if self.remainingCooldown > 0 then
        return self.remainingCooldown
    end

    self.storageRequested = true
    return 0
end

local DATA_TEMPLATE = '{\"name\":\"%s\","percentage":%.16f,"timeLeft":%s,\"helperId\":\"%s\",\"type\":\"%s\"}'
--- Get element data as JSON.
--
-- Fuel containers (element classes <code>AtmoFuelContainer</code>, <code>SpaceFuelContainer</code>, and
-- <code>RocketFuelTank</code>) have a <code>fuel_container</code> widget, which contains the following fields (bold
-- fields are visible when making custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">percentage</span></b> (<span class="type">float</span>) The percent full.</li>
--   <li><b><span class="parameter">timeLeft</span></b> (<span class="type">float</span>) Time in seconds, pass "" to
--     leave blank.</li>
--   <li><span class="parameter">name</span> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>)
--     <code>fuel_container_atmo_fuel</code> | <code>fuel_container_space_fuel</code> |
--     <code>fuel_container_rocket_fuel</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>fuel_container</code></li>
-- </ul>
-- @treturn string Data as JSON.
function M:getWidgetData()
    if self.elementClass == CLASS_ATMO or self.elementClass == CLASS_SPACE or self.elementClass == CLASS_ROCKET then
        return string.format(DATA_TEMPLATE, self.name, self.percentage, self.timeLeft, self.helperId, self:getWidgetType())
    end
    return MockElement:getWidgetData()
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    if self.elementClass == CLASS_ATMO or self.elementClass == CLASS_SPACE or self.elementClass == CLASS_ROCKET then
        return "e123456"
    end
    return MockElement:getWidgetDataId()
end

--- <b>Deprecated:</b> Event: The access to the container storage is granted. Required before using getItemsList, for example.
--
-- Note: This is documentation of an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onContentUpdate should be used instead.
-- @see acquireStorage
-- @see EVENT_onContentUpdate
function M.EVENT_storageAcquired()
    M.deprecated("EVENT_storageAcquired", "EVENT_onContentUpdate")
    M.EVENT_onContentUpdate()
end

--- Event: Emitted when the container content is updated (storage update or after a manual request made with updateContent()).
--
-- Note: This is documentation of an event handler, not a callable method.
-- @see updateContent
function M.EVENT_onContentUpdate()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterStatusChanged")
end

-- Name changed to follow in-game API.
function M:mockRegisterStorageAcquired(callback)
    M.deprecated("mockRegisterStorageAcquired", "mockRegisterContentUpdate")
    self:mockRegisterContentUpdate(callback)
end

--- Mock only, not in-game: Register a handler for the in-game `onContentUpdate()` event.
-- @tparam function callback The function to call when the container content updates.
-- @treturn int The index of the callback.
-- @see EVENT_onContentUpdate
function M:mockRegisterContentUpdate(callback)
    local index = #self.storageCallbacks + 1
    self.storageCallbacks[index] = callback
    return index
end

-- Name changed to follow in-game API, argument added to pass in the update directly.
function M:mockDoStorageAcquired()
    M.deprecated("mockDoStorageAcquired", "mockDoContentUpdate")
    self:mockDoContentUpdate(nil)
end

--- Mock only, not in-game: Simulates the container content updating, calling all registered callbacks.
-- @tparam table newItems The new contents table, must conform to the table defined in getContent or be nil to not
--   change storageItems.
-- @see getContent
function M:mockDoContentUpdate(newItems)
    if newItems then
        self.storageItems = newItems
    end

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i, callback in pairs(self.storageCallbacks) do
        local status, err = pcall(callback)
        if not status then
            errors = errors .. "\nError while running callback " .. i .. ": " .. err
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:" .. errors)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getMass = function() return self:getMass() end
    closure.getSelfMass = function() return self:getSelfMass() end
    closure.getItemsMass = function() return self:getItemsMass() end
    closure.getItemsVolume = function() return self:getItemsVolume() end
    closure.getMaxVolume = function() return self:getMaxVolume() end
    closure.getItemsList = function() return self:getItemsList() end
    closure.getContent = function() return self:getContent() end
    closure.acquireStorage = function() return self:acquireStorage() end
    closure.updateContent = function() return self:updateContent() end
    return closure
end

return M
