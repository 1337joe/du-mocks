--- A force field to create an uncrossable energy barrier.
--
-- Element class: ForceFieldUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module ForceFieldUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["force field xs"] = {mass = 110.62, maxHitPoints = 50.0, itemId = 3686074288}
elementDefinitions["force field s"] = {mass = 110.62, maxHitPoints = 50.0, itemId = 3685998465}
elementDefinitions["force field m"] = {mass = 110.62, maxHitPoints = 50.0, itemId = 3686006062}
elementDefinitions["force field l"] = {mass = 110.62, maxHitPoints = 50.0, itemId = 3685982092}
local DEFAULT_ELEMENT = "force field xs"

local M = MockElementWithToggle:new()
M.elementClass = "ForceFieldUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.plugIn = 0.0

    return o
end

--- Deploys the forcefield.
function M:deploy()
    self.state = true
end

--- Retracts the forcefield.
function M:retract()
    self.state = false
end

--- Checks if the forcefield is deployed.
-- @treturn 0/1 1 if the forcefield is deployed.
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
-- <li>"in" for the in signal (only appears to cause the element to refresh state to match actual input signal when it
--   doesn't already).</li>
-- </ul>
-- @tparam string plug A valid plug name to set.
-- @tparam 0/1 state The plug signal state
function M:setSignalIn(plug, state)
    if plug == "in" then
        -- does not set signal but updates state to match it
        local value = tonumber(self.plugIn)
        if type(value) ~= "number" or value < 1.0 then
            self:retract()
        else
            self:deploy()
        end
    end
end

--- Return the value of a signal in the specified IN plug of the element.
--
-- Valid plug names are:
-- <ul>
-- <li>"in" for the in signal (seems to have no actual effect when modified this way).</li>
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
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M