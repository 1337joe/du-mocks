--- Based on the principle of the Alcubierre drive, this unit creates a powerful negative energy-density field capable
-- to distort space-time and transport your ship at hyper speeds through space.
-- @module WarpDriveUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
local DEFAULT_ELEMENT = "warp drive l"

local M = MockElement:new()
M.elementClass = "???"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.warpActivated = false

    return o
end

--- Start the warp drive, if a warp destination has been selected.
function M:activateWarp()
    self.warpActivated = true
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activateWarp = function() return self:activateWarp() end
    return closure
end

return M