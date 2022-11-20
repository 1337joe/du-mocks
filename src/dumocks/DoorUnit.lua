--- A door that can be opened or closed.
--
-- Applies to doors, hatches, gates, etc.
--
-- Element class: DoorUnit
--
-- Extends: @{Element} &gt; @{ElementWithState} &gt; @{ElementWithToggle}
-- @module DoorUnit
-- @alias M

local MockElement = require "dumocks.Element"
local MockElementWithToggle = require "dumocks.ElementWithToggle"

local elementDefinitions = {}
elementDefinitions["airlock"] = {mass = 4197.11, maxHitPoints = 663.0}
elementDefinitions["fuel intake xs"] = {mass = 4.12, maxHitPoints = 50.0, itemId = 764397251}
elementDefinitions["gate xs"] = {mass = 122752.84, maxHitPoints = 50029.0, itemId = 1097676949}
elementDefinitions["expanded gate s"] = {mass = 122752.84, maxHitPoints = 74872.0, itemId = 581667413}
elementDefinitions["gate m"] = {mass = 122752.84, maxHitPoints = 150117.0, itemId = 2858887382}
elementDefinitions["expanded gate l"] = {mass = 122752.84, maxHitPoints = 199892.0, itemId = 1289884535}
elementDefinitions["gate xl"] = {mass = 122752.84, maxHitPoints = 448208.0, itemId = 1256519882}
elementDefinitions["hatch s"] = {mass = 98.56, maxHitPoints = 969.0, itemId = 297147615}
elementDefinitions["interior door"] = {mass = 4197.11, maxHitPoints = 560.0, itemId = 3709017308}
elementDefinitions["reinforced sliding door"] = {mass = 4197.11, maxHitPoints = 969.0}
elementDefinitions["sliding door s"] = {mass = 749.15, maxHitPoints = 56.0, itemId = 201196316}
elementDefinitions["sliding door m"] = {mass = 1006.01, maxHitPoints = 450.0, itemId = 741980535}
local DEFAULT_ELEMENT = "sliding door s"

local M = MockElementWithToggle:new()
M.elementClass = "DoorUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElementWithToggle:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.plugIn = 0.0

    return o
end

--- Open the door.
function M:open()
    self.state = true
end

--- Close the door.
function M:close()
    self.state = false
end

--- Returns the opening status of the door.
-- @treturn 0/1 1 if the door is open.
function M:isOpen()
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
    closure.open = function() return self:open() end
    closure.close = function() return self:close() end
    closure.isOpen = function() return self:isOpen() end

    closure.setSignalIn = function(plug, state) return self:setSignalIn(plug, state) end
    closure.getSignalIn = function(plug) return self:getSignalIn(plug) end
    return closure
end

return M