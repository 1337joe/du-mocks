--- The database library offers multiple useful functions to get all information
-- in one object about a player, a construct, an organization or an element.
--
-- The database is defined by a Lua file within your Dual Universe installation, view it at:
-- <code>...\Dual Universe\Game\data\lua\database.lua</code>
-- @module game_data_lua.database

local database = {}

--- Returns all info about a given player, identified by its id.
-- @tparam integer id The player ID.
-- @treturn table The player structure.
function database.getPlayer(id)
end

--- Returns all informations about the player running the script.
-- @tparam table unit The unit object.
-- @treturn table The player structure.
function database.getMasterPlayer(unit)
end

--- Returns all informations about the given organization, identified by its id.
-- @tparam integer id The organization id.
-- @treturn table The organization structure.
function database.getOrganization(id)
end

--- Returns all info about a given construct, identified by its id and seen from a radar.
-- @tparam table radar The radar object.
-- @tparam integer id The construct ID.
-- @treturn table The construct structure.
function database.getConstruct(radar, id)
end

--- Returns all info about a given element, identified by its id and coupled to a core unit.
-- @tparam table core The core unit object.
-- @tparam integer id The element ID.
-- @treturn table The construct structure.
function database.getElement(core, id)
end
