--- A unit capable of doing damage in construct PVP.
--
-- Element class: Weapon<Type><Size>
--
-- Extends: Element
-- @see Element
-- @module WeaponUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["uncommon railgun xs"] = {mass = 232.02, maxHitPoints = 300, class = "WeaponRailgunExtraSmall",
    staticProperties = [[{"baseDamage":5000.0,"cycleTime":8.0,"magazineVolume":100.0,"optimalAimingCone":5.0,"optimalDistance":20000.0,"optimalTracking":5.0,"reloadTime":15.0,"size":"xs","unloadTime":2.0}]]
    }
elementDefinitions["uncommon missile xs"] = {mass = 207.67, maxHitPoints = 300, class = "WeaponMissileExtraSmall",
    staticProperties = [[{"baseDamage":7500.0,"cycleTime":5.0,"magazineVolume":25.0,"optimalAimingCone":89.0,"optimalDistance":7500.0,"optimalTracking":15.0,"reloadTime":30.0,"size":"xs","unloadTime":2.0}]]
    }
local DEFAULT_ELEMENT = "uncommon railgun xs"

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
            "cycleAnimationRemainingTime":0.0,
            "fireBlocked":false,
            "fireCounter":0,
            "fireReady":false,
            "hitProbability":0.0,
            "hitResult":2,
            "operationalStatus":0,
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
--       <li><b><span class="parameter">cycleAnimationRemainingTime</span></b> (<span class="type">float</span>) Remaining time for current action (s), only appears to affect status codes 3 and 4.</li>
--       <li><span class="parameter">fireBlocked</span> (<span class="type">boolean</span>) Indicates weapon is blocked (?).</li>
--       <li><span class="parameter">fireCounter</span> (<span class="type">int</span>) Number of shots fired (?).</li>
--       <li><span class="parameter">fireReady</span> (<span class="type">boolean</span>) Indicates weapon is ready to fire (?).</li>
--       <li><span class="parameter">hitProbability</span> (<span class="type">float</span>) Likelyhood of hitting target (?).</li>
--       <li><span class="parameter">hitResult</span> (<span class="type">int</span>) (?).</li>
--       <li><span class="parameter">operationalStatus</span> (<span class="type">int</span>) (?).</li>
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
--       <li><span class="parameter">optimalAimingCone</span> (<span class="type">float</span>) Optimal aim cone (deg).</li>
--       <li><span class="parameter">optimalDistance</span> (<span class="type">float</span>) Optimal distance (m).</li>
--       <li><span class="parameter">optimalTracking</span> (<span class="type">float</span>) Optimal tracking rate (deg/s).</li>
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
function M:getData()
    local weaponId = 123456789
    local targetConstruct = [[{"constructId":"0"}]]
    return string.format(DATA_TEMPLATE, weaponId, self.helperId, self.name, self.staticProperties, targetConstruct,
        self:getWidgetType())
end

-- Override default with realistic patten to id.
function M:getDataId()
    return "e123456"
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    return closure
end

return M