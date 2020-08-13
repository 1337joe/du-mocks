#!/usr/bin/env lua
--- Tests on dumocks.System.
-- @see dumocks.System

-- set search path to include root of project
package.path = package.path..";../?.lua"

local lu = require("luaunit")

local ms = require("dumocks.System")

TestSystem = {}

os.exit(lu.LuaUnit.run())