--- A landing gear that can be opened or closed.
--
-- Element class: LandingGearUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module LandingGearUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["landing gear xs"] = {mass = 49.88, maxHitPoints = 1250.0, itemId = 4078067869}
elementDefinitions["landing gear s"] = {mass = 258.76, maxHitPoints = 5000.0, itemId = 1884031929}
elementDefinitions["landing gear m"] = {mass = 1460.65, maxHitPoints = 20000.0, itemId = 1899560165}
elementDefinitions["landing gear l"] = {mass = 8500.63, maxHitPoints = 80000.0, itemId = 2667697870}
local DEFAULT_ELEMENT = "landing gear s"

local M = MockElementWithToggle:new()
M.elementClass = "LandingGearUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.plugIn = 0.0

    return o
end

--- Deploys the landing gear.
function M:deploy()
    self.state = true
end

--- Retracts the landing gear.
function M:retract()
    self.state = false
end

--- Checks if the landing gear is deployed.
-- @treturn 0/1 1 if the landing gear is deployed.
function M:isDeployed()
    if self.state then
        return 1
    end
    return 0
end

--- Set the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- no longer responds to setSignalIn
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal.</li>
-- </ul>
-- @tparam string plug A valid plug name to query.
-- @treturn 0/1 The plug signal state
function M:getSignalIn(plug)
    if plug == "in" then
        return self.plugIn
    end
    return MockElement.getSignalIn(self)
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElementWithToggle.mockGetClosure(self)
    closure.deploy = function() return self:deploy() end
    closure.retract = function() return self:retract() end
    closure.isDeployed = function() return self:isDeployed() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end    return closure
end

return M