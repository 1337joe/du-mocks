--- Stores items.
--
-- Element class:
-- <ul>
--   <li>ItemContainer</li>
--   <li>MissionContainer</li>
--   <li>AtmoFuelContainer</li>
--   <li>SpaceFuelContainer</li>
--   <li>RocketFuelTank</li>
-- </ul>
--
-- Extends: Element
-- @see Element
-- @module ContainerUnit
-- @alias M

local MockElement = require "dumocks.Element"

local CLASS_ITEM = "ItemContainer"
local CLASS_PARCEL = "MissionContainer"
local CLASS_ATMO = "AtmoFuelContainer"
local CLASS_SPACE = "SpaceFuelContainer"
local CLASS_ROCKET = "RocketFuelContainer"

local elementDefinitions = {}
elementDefinitions["container xs"] = {mass = 229.09, maxHitPoints = 124.0, class = CLASS_ITEM, maxVolume = 1000}
elementDefinitions["container s"] = {mass = 1281.31, maxHitPoints = 999.0, class = CLASS_ITEM, maxVolume = 8000}
elementDefinitions["container m"] = {mass = 7421.35, maxHitPoints = 7997.0, class = CLASS_ITEM, maxVolume = 64000}
elementDefinitions["container l"] = {mass = 14842.7, maxHitPoints = 17316.0, class = CLASS_ITEM, maxVolume = 128000}
elementDefinitions["container xl"] = {mass = 44206.0, maxHitPoints = 34633.0, class = CLASS_ITEM, maxVolume = 256000}
elementDefinitions["expanded container xl"] = {mass = 88413.0, maxHitPoints = 69267.0, class = CLASS_ITEM, maxVolume = 512000}

elementDefinitions["parcel container xs"] = {mass = 224.68, maxHitPoints = 124.0, class = CLASS_PARCEL, maxVolume = 1000}
elementDefinitions["parcel container s"] = {mass = 1256.17, maxHitPoints = 999.0, class = CLASS_PARCEL, maxVolume = 8000}
elementDefinitions["parcel container m"] = {mass = 7273.75, maxHitPoints = 7997.0, class = CLASS_PARCEL, maxVolume = 64000}
elementDefinitions["parcel container l"] = {mass = 14547.5, maxHitPoints = 17316.0, class = CLASS_PARCEL, maxVolume = 128000}
elementDefinitions["parcel container xl"] = {mass = 43313.71, maxHitPoints = 34633.0, class = CLASS_PARCEL, maxVolume = 256000}
elementDefinitions["parcel expanded container xl"] = {mass = 86627.42, maxHitPoints = 69267.0, class = CLASS_PARCEL, maxVolume = 512000}

elementDefinitions["atmospheric fuel tank xs"] = {mass = 35.03, maxHitPoints = 50.0, class = CLASS_ATMO, maxVolume = 100}
elementDefinitions["atmospheric fuel tank s"] = {mass = 182.67, maxHitPoints = 163.0, class = CLASS_ATMO, maxVolume = 400}
elementDefinitions["atmospheric fuel tank m"] = {mass = 988.67, maxHitPoints = 1315.0, class = CLASS_ATMO, maxVolume = 1600}
elementDefinitions["atmospheric fuel tank l"] = {mass = 5481.27, maxHitPoints = 10461.0, class = CLASS_ATMO, maxVolume = 12800}

elementDefinitions["space fuel tank s"] = {mass = 182.67, maxHitPoints = 187.0, class = CLASS_SPACE, maxVolume = 400}
elementDefinitions["space fuel tank m"] = {mass = 988.67, maxHitPoints = 1496.0, class = CLASS_SPACE, maxVolume = 1600}
elementDefinitions["space fuel tank l"] = {mass = 5481.27, maxHitPoints = 15933.0, class = CLASS_SPACE, maxVolume = 12800}

elementDefinitions["rocket fuel tank xs"] = {mass = 173.42, maxHitPoints = 366.0, class = CLASS_ROCKET, maxVolume = 400}
elementDefinitions["rocket fuel tank s"] = {mass = 886.72, maxHitPoints = 736.0, class = CLASS_ROCKET, maxVolume = 800}
elementDefinitions["rocket fuel tank m"] = {mass = 4724.43, maxHitPoints = 6231.0, class = CLASS_ROCKET, maxVolume = 6400}
elementDefinitions["rocket fuel tank l"] = {mass = 25741.76, maxHitPoints = 68824.0, class = CLASS_ROCKET, maxVolume = 50000}

local DEFAULT_ELEMENT = "container s"

local M = MockElement:new()
M.remainingRestorations = 5
M.maxRestorations = 5

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class

    if o.elementClass == CLASS_ITEM or o.elementClass == CLASS_PARCEL then
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
    o.itemsVolume = 0
    o.maxVolume = elementDefinition.maxVolume

    -- for fuel tanks
    o.percentage = 0.0
    o.timeLeft = "n/a"

    o.storageRequested = false
    o.storageCallbacks = {}
    o.storageAvailable = false
    o.storageJson = string.char(91, 93, 10)
    o.requestsExceeded = false

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

--- Returns volume occupied by items currently inside the container.
-- @treturn L The volume in liters.
function M:getItemsVolume()
    return self.itemsVolume
end

--- Returns the container max volume
-- @treturn L The volume in liters.
function M:getMaxVolume()
    return self.maxVolume
end

--- Initiate the acquisition of the storage in the container, required before calls to getItemsList. Simply wait for the
-- event 'storageAcquired' to be emitted by the container, and you can then use the storage related functions.
--
-- Note: This is rate-limited to 10 queries / 5 minutes. Attempting to call more frequently will result in console error messages.
-- @see getItemsList
-- @see EVENT_storageAcquired
function M:acquireStorage()
    if self.requestsExceeded then
        local message =
            "You have reached the maximum of 10 requests to 'acquireStorage' before entering a period of 5 min of cooldown, retry later"
        if system and type(system.print) == "function" then
            system.print(message)
        else
            print(message)
        end
    else
        self.storageRequested = true
    end
end

M.JSON_ITEM_TEMPLATE =
    [[{ "class" : "%s", "name" : "%s", "quantity" : %f, "type" : "%s", "unitMass" : %f, "unitVolume" : %f}]]

--- Returns the list of items in the container, as a json string you need to parse with json.decode.
-- @treturn jsonstr The container content as a json list of json objects with fields: name, quantity, unitVolume, unitMass, type, class
function M:getItemsList()
    if not self.storageAvailable then
        return ""
    end
    return self.storageJson
end

local DATA_TEMPLATE = '{\"name\":\"%s [%d]\","percentage":%.16f,"timeLeft":%s,\"helperId\":\"%s\",\"type\":\"%s\"}'
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
function M:getData()
    if self.elementClass == CLASS_ITEM or self.elementClass == CLASS_PARCEL then
        return MockElement:getData()
    end
    return string.format(DATA_TEMPLATE, self.name, self:getId(), self.percentage, self.timeLeft, self.helperId,
               self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    if self.elementClass == CLASS_ITEM or self.elementClass == CLASS_PARCEL then
        return MockElement:getDataId()
    end
    return "e123456"
end

--- Event: The access to the container storage is granted. Required before using getItemsList, for example.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @see acquireStorage
function M.EVENT_storageAcquired()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterStatusChanged")
end

--- Mock only, not in-game: Register a handler for the in-game `storageAcquired()` event.
-- @tparam function callback The function to call when the storage data is available.
-- @treturn int The index of the callback.
-- @see EVENT_storageAcquired
function M:mockRegisterStorageAcquired(callback)
    local index = #self.storageCallbacks + 1
    self.storageCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the storage data becoming available, calling all registered callbacks.
function M:mockDoStorageAcquired()
    -- state changes before calling handlers
    self.storageAvailable = true

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
    closure.getItemsMass = function() return self:getItemsMass() end
    closure.getSelfMass = function() return self:getSelfMass() end
    closure.getItemsVolume = function() return self:getItemsVolume() end
    closure.getMaxVolume = function() return self:getMaxVolume() end
    closure.acquireStorage = function() return self:acquireStorage() end
    closure.getItemsList = function() return self:getItemsList() end
    return closure
end

return M
