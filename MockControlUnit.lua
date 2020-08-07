--- Control unit.
-- Control units come in various forms: cockpits, programming boards, emergency control units, etc. A control unit
-- stores a set of Lua scripts that can be used to control the elements that are plugged in on its CONTROL plugs.
-- Kinematics control units like cockpit or commander seats are also capable of controlling the ship's engines via the
-- update ICC method.
-- @module MockControlUnit
-- @alias M

local MockElement = require "MockElement"

local controlDefinitions = {
    programmingBoard = {
        mass = 27.74,
        maxHitPoints = 50.0
    },
    hovercraftSeat = {
        mass = 110.33,
        maxHitPoints = 187.0
    }
}

local M = MockElement:new()
M.elementClass = "Generic"

function M:new(o, id)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    return o
end

--- Stops the control unit's Lua code and exits. Warning: calling this might cause your ship to fall from the sky, use
-- it with care. It is typically used in the coding of emergency control unit scripts to stop control once the ECU
-- thinks that the ship has safely landed.
function M:exit()
end

--- Set up a timer with a given tag ID in a given period. This will start to trigger the 'tick' event with the
-- corresponding ID as an argument, to help you identify what is ticking, and when.
-- @tparam string timerTagId The ID of the timer, as a string, which will be used in the 'tick' event to identify this
-- particular timer.
-- @tparam second period The period of the timer, in seconds. The time resolution is limited by the framerate here, so
-- you cannot set arbitrarily fast timers.
function M:setTimer(timerTagId, period)
end

-- @see MockElement:getClosure
function M:getClosure()
    local closure = MockElement.getClosure(self)
    closure.exit = function() return self:exit() end
    closure.setTimer = function(timerTagId, period) return self:setTimer(timerTagId, period) end
    return closure
end

return M