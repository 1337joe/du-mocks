--- Stores key/value pairs in a persistent way.
--
-- Storage capacity: 30 kB
--
-- Element class: DataBankUnit
--
-- Extends: Element
-- @see Element
-- @module DatabankUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["databank"] = {mass = 17.09, maxHitPoints = 50.0}
local DEFAULT_ELEMENT = "databank"

local M = MockElement:new()
M.elementClass = "DataBankUnit"

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.data = {}

    return o
end

--- Clear the data bank.
function M:clear()
    self.data = {}
end

--- Returns the number of keys that are stored inside the data bank.
-- @treturn int The number of keys.
function M:getNbKeys()
    local count = 0
    for _,_ in pairs(self.data) do
        count = count + 1
    end
    return count
end

--- Returns all the keys in the data bank.
-- @treturn json The key list, as JSON sequence.
function M:getKeys()
    local keys = "["
    for key,_ in pairs(self.data) do
        keys = keys..'"'..key..'",'
    end
    if string.len(keys) == 1 then
        keys = keys.."]"
    else
        keys = string.sub(keys, 0, string.len(keys) - 1).."]"
    end
    return keys
end

--- Returns 1 if the key is present in the databank, 0 otherwise.
-- @treturn bool 1 if the key exists and 0 otherwise
function M:hasKey(key)
    key = tostring(key)
    if self.data[key] ~= nil then
        return 1
    end
    return 0
end

--- Stores a string value at the given key.
-- @tparam string key The key used to store the value.
-- @tparam string val The value, as a string.
function M:setStringValue(key, val)
    key = tostring(key)
    if val == nil or type(val) == "boolean" then
        val = ""
    end
    self.data[key] = val
end

--- Returns value stored in the given key as a string.
-- @tparam string key The key used to retrieve the value.
-- @treturn string The value as a string.
function M:getStringValue(key)
    key = tostring(key)
    local value = self.data[key]
    if value == nil then
        value = ""
    else
        value = tostring(value)
    end
    return value
end

--- Stores an integer value at the given key.
-- @tparam string key The key used to store the value.
-- @tparam int val The value, as an integer.
function M:setIntValue(key, val)
    key = tostring(key)
    -- only store if an int
    if type(val) == "number" and val % 1 == 0 then
        self.data[key] = math.floor(val)
    else
        self.data[key] = 0
    end
end

--- Returns value stored in the given key as an integer.
-- @tparam string key The key used to retrieve the value.
-- @treturn int The value as an integer.
function M:getIntValue(key)
    key = tostring(key)
    local value = self.data[key]
    if value == nil or type(value) ~= "number" then
        value = 0
    else
        value = math.floor(value)
    end
    return value
end

--- Stores a floating number value at the given key.
-- @tparam string key The key used to store the value.
-- @tparam float val The value, as a floating number.
function M:setFloatValue(key, val)
    key = tostring(key)
    if type(val) == "number" and val ~= 0 then
        self.data[key] = val
    else
        self.data[key] = 0
    end
end

--- Returns value stored in the given key as a floating number.
-- @tparam string key The key used to retrieve the value.
-- @treturn float The value as a floating number.
function M:getFloatValue(key)
    key = tostring(key)
    local value = self.data[key]
    if value == nil or type(value) ~= "number" then
        value = 0.0
    else
        value = value * 1.0
    end
    return value
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.clear = function() return self:clear() end
    closure.getNbKeys = function() return self:getNbKeys() end
    closure.getKeys = function() return self:getKeys() end
    closure.hasKey = function(key) return self:hasKey(key) end
    closure.setStringValue = function(key, val) return self:setStringValue(key, val) end
    closure.getStringValue = function(key) return self:getStringValue(key) end
    closure.setIntValue = function(key, val) return self:setIntValue(key, val) end
    closure.getIntValue = function(key) return self:getIntValue(key) end
    closure.setFloatValue = function(key, val) return self:setFloatValue(key, val) end
    closure.getFloatValue = function(key) return self:getFloatValue(key) end
    return closure
end

return M