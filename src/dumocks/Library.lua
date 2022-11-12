--- Contains a list of useful math and helper methods that would be slow to implement in Lua, and which are given here
-- as fast C++ implementation.
-- @module library
-- @alias M

-- define class fields
local M = {}

function M:new(o)
    -- define default instance fields
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.systemResolution3Index = 1
    o.systemResolution3Solutions = {}

    o.systemResolution2Index = 1
    o.systemResolution2Solutions = {}

    o.getPointOnScreenIndex = 1
    o.getPointOnScreenSolutions = {}

    return o
end

--- Solve the 3D linear system M*x=c0 where M is defined by its colum vectors c1,c2,c3.
-- @tparam vec3 vec_c1 The first column of the matrix M.
-- @tparam vec3 vec_c2 The second column of the matrix M.
-- @tparam vec3 vec_c3 The third column of the matrix M.
-- @tparam vec3 vec_c0 The target column of the matrix M.
-- @treturn vec3 The vec3 solution of the above system.
function M:systemResolution3(vec_c1, vec_c2, vec_c3, vec_c0)
    -- find the next solution in the provided sequence
    local result = self.systemResolution3Solutions[self.systemResolution3Index]
    if not result then
        error("Solution " .. self.systemResolution3Index .. " not loaded.")
    end

    self.systemResolution3Index = self.systemResolution3Index + 1
    return result
end

--- Solve the 2D linear system M*x=c0 where M is defined by its colum vectors c1,c2.
-- @tparam vec3 vec_c1 The first column of the matrix M.
-- @tparam vec3 vec_c2 The second column of the matrix M.
-- @tparam vec3 vec_c0 The target column of the matrix M.
-- @treturn vec2 The vec2 solution of the above system.
function M:systemResolution2(vec_c1, vec_c2, vec_c0)
    -- find the next solution in the provided sequence and increment index
    local result = self.systemResolution2Solutions[self.systemResolution2Index]
    if not result then
        error("Solution " .. self.systemResolution2Index .. " not loaded.")
    end

    self.systemResolution2Index = self.systemResolution2Index + 1
    return result
end

--- Returns the position of the given point in world coordinates system, on the game screen.
-- @tparam vec3 worldPos The world position of the point.
-- @treturn vec3 The position in percentage (between 0 and 1) of the screen resolution as vec3 with {x, y, depth}.
function M:getPointOnScreen(worldPos)
    -- find the next solution in the provided sequence and increment index
    local result = self.getPointOnScreenSolutions[self.getPointOnScreenIndex]
    if not result then
        error("Point " .. self.getPointOnScreenIndex .. " not loaded.")
    end

    self.getPointOnScreenIndex = self.getPointOnScreenIndex + 1
    return result
end

--- Unknown use.
function M:load()
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
function M:mockGetClosure()
    local closure = {}
    closure.systemResolution3 = function(vec_c1, vec_c2, vec_c3, vec_c0)
        return self:systemResolution3(vec_c1, vec_c2, vec_c3, vec_c0)
    end
    closure.systemResolution2 = function(vec_c1, vec_c2, vec_c0)
        return self:systemResolution2(vec_c1, vec_c2, vec_c0)
    end
    closure.getPointOnScreen = function(worldPos) return self:getPointOnScreen(worldPos) end
    closure.load = function() return self:load() end
    return closure
end

return M
