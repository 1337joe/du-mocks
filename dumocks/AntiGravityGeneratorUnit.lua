--- Generates graviton condensates to power anti-gravity pulsors.
-- @module AntiGravityGeneratorUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["anti-gravity generator s"] = {mass = 27134.86, maxHitPoints = 43117.0}
-- elementDefinitions["anti-gravity generator m"] = {mass = , maxHitPoints = }
-- elementDefinitions["anti-gravity generator l"] = {mass = , maxHitPoints = }
local DEFAULT_ELEMENT = "anti-gravity generator s"

local M = MockElement:new()
M.elementClass = "AntiGravityGeneratorUnit"

local AG_MIN_BASE_ALTITUDE = 1000
local AG_ALTITUDE_RATE = 4 -- m/s

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.state = false
    o.targetAltitude = 2000.0 -- m
    -- setting base altitude sets the target, the base altitude slowly adjusts to match it
    o.baseAltitude = 2000.0 -- m
    o.antiGravityPower = 0.0
    o.antiGravityField = 0.0

    return o
end

local DATA_TEMPLATE = '{"antiGPower":%f,"antiGravityField":%f,"baseAltitude\":%f,\"helperId\":\"antigravity_generator'..
    '\",\"name\":\"%s [%d]\",\"showError\":false,\"type\":\"antigravity_generator\"}'
function M:getData()
    return string.format(DATA_TEMPLATE, self.antiGravityPower, self.antiGravityField, self.baseAltitude, self.name, self.id)
end

--- Start the anti-g generator.
function M:activate()
    self.state = true
end

--- Stop the anti-g generator.
function M:deactivate()
    self.state = false
end

--- Toggle the state of the anti-g generator.
function M:toggle()
    self.state = not self.state
end

--- Returns the activation state of activation of the anti-g generator.
-- @return 1 when the anti-g generator is started, 0 otherwise.
function M:getState()
    if self.state then
        return 1
    end
    return 0
end

--- Sets the base altitude for the anti-gravity field.
-- @tparam m altitude The desired altitude. It will be reached with a slow acceleration (not instantaneous).
function M:setBaseAltitude(altitude)
    altitude = math.max(AG_MIN_BASE_ALTITUDE, altitude)
    self.targetAltitude = altitude
end

--- Return the base altitude for the anti-gravity field.
--
-- Note: This is the altitude that the anti-gravity generator is currently trying to hold at. It will adjust slowly
-- to match the altitude provided to setBaseAltitude but will not instantly reflect the value set.
-- @tparam m The base altitude.
function M:getBaseAltitude()
    return self.baseAltitude
end

--- Mock only, not in-game: Updates the base altitude to approach the target altitude at 4 m/s.
-- @tparam number seconds The number of seconds to move at 4 m/s.
function M:mockStepBaseAltitude(seconds)
    seconds = seconds or 1

    if self.baseAltitude < self.targetAltitude then
        self.baseAltitude = math.min(self.baseAltitude + AG_ALTITUDE_RATE * seconds, self.targetAltitude)
    elseif self.baseAltitude > self.targetAltitude then
        self.baseAltitude = math.max(self.baseAltitude - AG_ALTITUDE_RATE * seconds, self.targetAltitude)
    end
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.activate = function() return self:activate() end
    closure.deactivate = function() return self:deactivate() end
    closure.toggle = function() return self:toggle() end
    closure.getState = function() return self:getState() end
    closure.setBaseAltitude = function(altitude) return self:setBaseAltitude(altitude) end
    closure.getBaseAltitude = function() return self:getBaseAltitude() end
    return closure
end

return M