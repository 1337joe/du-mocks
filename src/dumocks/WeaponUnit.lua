--- Displays information about the weapon's state.
--
-- Element class: Weapon<Type><Size>
--
-- Extends: @{Element}
-- @module WeaponUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["railgun xs"] = {mass = 232.0, maxHitPoints = 300, class = "WeaponRailgunExtraSmall", itemId = 31327772,
    staticProperties = [[{"cycleTime":7.0,"magazineVolume":150.0,"reloadTime":20.0,"size":"xs","unloadTime":2.0}]]
    }
elementDefinitions["missile xs"] = {mass = 207.67, maxHitPoints = 300, class = "WeaponMissileExtraSmall",
    staticProperties = [[{"cycleTime":5.0,"magazineVolume":25.0,"reloadTime":30.0,"size":"xs","unloadTime":2.0}]]
    }
local DEFAULT_ELEMENT = "railgun xs"

local M = MockElement:new()
M.helperId = "weapon"
M.widgetType = "weapon"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.elementClass = elementDefinition.class
    o.staticProperties = elementDefinition.staticProperties

    return o
end

local DATA_TEMPLATE = [[
    {"elementId":"%d","helperId":"%s","name":"%s",
        "properties": {
            "ammoCount":0,
            "ammoMax":0,
            "ammoName":"",
            "ammoTypeId":"0",
            "baseDamage":16000.0,
            "cycleAnimationRemainingTime":0.0,
            "disableFire":0,
            "fireBlocked":false,
            "fireCounter":0,
            "fireReady":false,
            "hitProbability":0.0,
            "hitResult":2,
            "impactCounter":0,
            "maxDistance":60000.0,
            "missCounter":0,
            "operationalStatus":0,
            "optimalAimingCone":30.0,
            "optimalDistance":20000.0,
            "optimalTracking":3.5,
            "outOfZone":true,
            "repeatedFire":false,
            "weaponStatus":0
        },
        "staticProperties":%s,
        "targetConstruct":%s,
        "type":"%s"}
      ]]

--- Get element data as JSON.
--
-- Weapons have a <code>weapon</code> widget, which contains the following fields (bold fields are visible when making
-- custom use of the widget):
-- <ul>
--   <li><b><span class="parameter">properties</span></b> (<span class="type">table</span>) Current weapon properties.
--     <ul>
--       <li><b><span class="parameter">ammoCount</span></b> (<span class="type">int</span>) Remaining ammo. Not present while reloading.</li>
--       <li><b><span class="parameter">ammoMax</span></b> (<span class="type">int</span>) Max capacity for current ammo. Not present while reloading.</li>
--       <li><b><span class="parameter">ammoName</span></b> (<span class="type">int</span>) Name of current ammo.</li>
--       <li><span class="parameter">ammoTypeId</span> (<span class="type">int</span>) Type id of current ammo.</li>
--       <li><span class="parameter">baseDamage</span> (<span class="type">float</span>) (?).</li>
--       <li><b><span class="parameter">cycleAnimationRemainingTime</span></b> (<span class="type">float</span>) Remaining time for current action (s), only appears to affect status codes 3 and 4.</li>
--       <li><span class="parameter">disableFire</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">fireBlocked</span> (<span class="type">boolean</span>) Indicates weapon is blocked (?).</li>
--       <li><span class="parameter">fireCounter</span> (<span class="type">int</span>) Number of shots fired (?).</li>
--       <li><span class="parameter">fireReady</span> (<span class="type">boolean</span>) Indicates weapon is ready to fire (?).</li>
--       <li><span class="parameter">hitProbability</span> (<span class="type">float</span>) Likelyhood of hitting target (?).</li>
--       <li><span class="parameter">hitResult</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">impactCounter</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">maxDistance</span> (<span class="type">float</span>) (?).</li>
--       <li><span class="parameter">missCounter</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">operationalStatus</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">optimalAimingCone</span> (<span class="type">float</span>) Optimal aim cone (deg).</li>
--       <li><span class="parameter">optimalDistance</span> (<span class="type">float</span>) Optimal distance (m).</li>
--       <li><span class="parameter">optimalTracking</span> (<span class="type">float</span>) Optimal tracking rate (deg/s).</li>
--       <li><span class="parameter">outOfZone</span> (<span class="type">boolean</span>) Indicates out of PVP zone (?).</li>
--       <li><span class="parameter">repeatedFire</span> (<span class="type">boolean</span>) Indicates weapon will fire repeatedly (?).</li>
--       <li><b><span class="parameter">weaponStatus</span></b> (<span class="type">int</span>) Status code:
--         <ul>
--           <li><b>0</b>: No animation in progress.</li>
--           <li><b>1</b>: Firing(?).</li>
--           <li><b>2</b>: (?)</li>
--           <li><b>3</b>: Loading/Reloading(?) ammo.</li>
--           <li><b>4</b>: Unloading ammo.</li>
--         </ul></li>
--     </ul></li>
--   <li><span class="parameter">staticProperties</span> (<span class="type">table</span>) Weapon attributes.
--     <ul>
--       <li><span class="parameter">baseDamage</span> (<span class="type">float</span>) Weapon base damage.</li>
--       <li><span class="parameter">magazineVolume</span> (<span class="type">float</span>) Magazine volume (L).</li>
--       <li><span class="parameter">cycleTime</span> (<span class="type">float</span>) Weapon rate of fire (s).</li>
--       <li><span class="parameter">reloadTime</span> (<span class="type">float</span>) Weapon reload time (s).</li>
--       <li><span class="parameter">unloadTime</span> (<span class="type">float</span>) Weapon unload time (s).</li>
--       <li><span class="parameter">size</span> (<span class="type">float</span>) Weapon cycle time (s).</li>
--     </ul></li>
--   <li><b><span class="parameter">targetConstruct</span></b> (<span class="type">table</span>) Target attributes.
--     <ul>
--       <li><b><span class="parameter">name</span></b> (<span class="type">string</span>) Name of target, will be blank if not provided.</li>
--       <li><span class="parameter">constructId</span> (<span class="type">int</span>) Id of target.</li>
--     </ul></li>
--   <li><b><span class="parameter">name</span></b> (<span class="type">string</span>) The name of the element.</li>
--   <li><span class="parameter">elementId</span> (<span class="type">int</span>) The (globally unique?) id of the 
--     weapon element, may be related to linking the commands to the element.</li>
--   <li><span class="parameter">helperId</span> (<span class="type">string</span>) <code>weapon</code></li>
--   <li><span class="parameter">type</span> (<span class="type">string</span>) <code>weapon</code></li>
-- </ul>
--
-- Descriptions of fields with a (?) are uncertain and need more testing.
-- @treturn string Data as JSON.
function M:getWidgetData()
    local weaponId = 123456789
    local targetConstruct = [[{"constructId":"0"}]]
    return string.format(DATA_TEMPLATE, weaponId, self.helperId, self.name, self.staticProperties, targetConstruct,
        self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getWidgetDataId()
    return "e123456"
end

--- Returns the item ID of the currently equipped ammo.
-- @treturn int The item ID of the ammunition in the weapon.
function M:getAmmo()
end

--- Returns the current amount of remaining ammunition.
-- @treturn int The remaining ammunition count (0 when reloading).
function M:getAmmoCount()
    return 0
end

--- Returns the maximum amount of ammunition the weapon can carry.
-- @treturn int The maximum amount of ammunition.
function M:getMaxAmmo()
end

--- Checks if the weapon is out of ammo.
-- @treturn 0/1 1 if the weapon is out of ammo.
function M:isOutOfAmmo()
end

--- <b>Deprecated:</b> Returns 1 if the wapon is not broken and compatible with the construct size.
--
-- This method is deprecated: getOperationalState should be used instead
-- @see getOperationalState
-- @treturn 0/1 1 if the weapon is operational, otherwise 0.
function M:isOperational()
    M.deprecated("isOperational", "getOperationalState")
    if self:getOperationalState() == 1 then
        return 1
    end
    return 0
end

--- Returns 1 if the wapon is not broken and compatible with the construct size.
-- @treturn int 1 if the weapon is operational, otherwise 0 = broken, -1 = incompatible size.
function M:getOperationalState()
end

--- Returns the current weapon status.
--
-- Possible status:
-- <ul>
--   <li>1: Idle</li>
--   <li>2: Firing</li>
--   <li>3: Reloading</li>
--   <li>4: Unloading</li>
-- </ul>
-- @treturn int The current status of the weapon.
function M:getStatus()
end

--- Returns the local ID of the container linked to the weapon.
-- @treturn int The local ID of the container.
function M:getContainerId()
end

--- Returns the current hit probability of the weapon for the current target.
-- @treturn float The hit probability of the weapon.
function M:getHitProbability()
end

--- Returns the base weapon damage.
-- @treturn float The base weapon damage in hitpoints.
function M:getBaseDamage()
end

--- Returns the optimal aim cone.
-- @treturn float The optimal aim cone in degrees.
function M:getOptimalAimingCone()
end

--- Returns the optimal distance to target.
-- @treturn float The optimal distance in meters.
function M:getOptimalDistance()
end

--- Returns the maximum distance to target.
-- @treturn float The optimal distance in meters.
function M:getMaxDistance()
end

--- Returns the optimal tracking rate.
-- @treturn float The optimal tracking rate in degrees per second.
function M:getOptimalTracking()
end

--- Returns the magazine volume.
-- @treturn float The magazine volume in liters.
function M:getMagazineVolume()
end

--- Returns the weapon cycle time.
-- @treturn float The weapon cycle time in seconds.
function M:getCycleTime()
end

--- Returns the weapon reload time.
-- @treturn float The weapon reload time in seconds.
function M:getReloadTime()
end

--- Returns the weapon unload time.
-- @treturn float The weapon unload time in seconds.
function M:getUnloadTime()
end

--- Returns the ID of the current target construct of the weapon.
-- @treturn int The target construct ID.
function M:getTargetId()
end


--- Event: Emitted when the weapon starts reloading.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int ammoId The item ID of the ammo.
function M.EVENT_onReload(ammoId)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the weapon has reloaded.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int ammoId The item ID of the ammo.
function M.EVENT_onReloaded(ammoId)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the weapon has missed its target.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int targetId The construct ID of the target.
function M.EVENT_onMissed(targetId)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the weapon target has been destroyed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int targetId The construct ID of the target.
function M.EVENT_onDestroyed(targetId)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when an element on the weapon target has been destroyed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int targetId The construct ID of the target.
-- @tparam int itemId The item ID of the destroyed element.
function M.EVENT_onElementDestroyed(targetId, itemId)
    assert(false, "This is implemented for documentation purposes only.")
end

--- Event: Emitted when the weapon has hit.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int targetId The construct ID of the target.
-- @tparam float damage The damage amount dealt by the hit.
function M.EVENT_onHit(targetId, damage)
    assert(false, "This is implemented for documentation purposes only.")
end


--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.getAmmo = function() return self:getAmmo() end
    closure.getAmmoCount = function() return self:getAmmoCount() end
    closure.getMaxAmmo = function() return self:getMaxAmmo() end
    closure.isOutOfAmmo = function() return self:isOutOfAmmo() end
    closure.isOperational = function() return self:isOperational() end
    closure.getOperationalState = function() return self:getOperationalState() end
    closure.getStatus = function() return self:getStatus() end
    closure.getContainerId = function() return self:getContainerId() end
    closure.getHitProbability = function() return self:getHitProbability() end
    closure.getBaseDamage = function() return self:getBaseDamage() end
    closure.getOptimalAimingCone = function() return self:getOptimalAimingCone() end
    closure.getOptimalDistance = function() return self:getOptimalDistance() end
    closure.getMaxDistance = function() return self:getMaxDistance() end
    closure.getOptimalTracking = function() return self:getOptimalTracking() end
    closure.getMagazineVolume = function() return self:getMagazineVolume() end
    closure.getCycleTime = function() return self:getCycleTime() end
    closure.getReloadTime = function() return self:getReloadTime() end
    closure.getUnloadTime = function() return self:getUnloadTime() end
    closure.getTargetId = function() return self:getTargetId() end
    return closure
end

return M