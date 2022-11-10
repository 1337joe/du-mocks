--- Stores key/value pairs in a persistent way.
--
-- Storage capacity: 30 kB
--
-- Element class: DataBankUnit
--
-- Extends: @{Element}
-- @module DatabankUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["databank xs"] = {mass = 17.09, maxHitPoints = 50.0, itemId = 812400865}
local DEFAULT_ELEMENT = "databank xs"

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

--- Clear the databank.
function M:clear()
    self.data = {}
end

--- Returns the number of keys that are stored inside the databank.
-- @treturn int The number of keys.
function M:getNbKeys()
    local count = 0
    for _,_ in pairs(self.data) do
        count = count + 1
    end
    return count
end

--- <b>Deprecated:</b> Returns all the keys in the databank.
--
-- This method is deprecated: getKeyList should be used instead.
-- @see getKeyList
-- @treturn json The key list, as JSON sequence.
function M:getKeys()
    M.deprecated("getKeys", "getKeyList")

    local quotedKeys = {}
    for i, v in pairs(self:getKeyList()) do
        quotedKeys[i] = string.format([["%s"]], v)
    end
    return "[" .. table.concat(quotedKeys, ",") .. "]"
end

--- Returns all the keys in the databank.
-- @treturn list The key list, as a list of string.
function M:getKeyList()
    local keysList = {}
    for key,_ in pairs(self.data) do
        keysList[#keysList + 1] = string.format("%s", key)
    end
    return keysList
end

--- Returns 1 if the key is present in the databank, 0 otherwise.
-- @treturn 0/1 1 if the key exists and 0 otherwise.
function M:hasKey(key)
    key = tostring(key)
    if self.data[key] ~= nil then
        return 1
    end
    return 0
end

--- Remove the given key if the key is present in the databank.
-- @tparam string key The key used to store a value.
-- @treturn 0/1 1 if the key has been successfully removed, 0 otherwise.
function M:clearValue(key)
    key = tostring(key)
    if self.data[key] ~= nil then
        self.data[key] = nil
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
    elseif type(val) == "boolean" then
        if val then
            self.data[key] = 1
        else
            self.data[key] = 0
        end
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
    elseif type(value) == "number" and value ~= math.floor(value) then
        value = 0
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
    closure.getKeyList = function() return self:getKeyList() end
    closure.hasKey = function(key) return self:hasKey(key) end
    closure.clearValue = function(key) return self:clearValue(key) end
    closure.setStringValue = function(key, val) return self:setStringValue(key, val) end
    closure.getStringValue = function(key) return self:getStringValue(key) end
    closure.setIntValue = function(key, val) return self:setIntValue(key, val) end
    closure.getIntValue = function(key) return self:getIntValue(key) end
    closure.setFloatValue = function(key, val) return self:setFloatValue(key, val) end
    closure.getFloatValue = function(key) return self:getFloatValue(key) end
    return closure
end

return M