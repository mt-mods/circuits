local c = circuits
local database_path = core.get_worldpath() .. "/circuits_db.txt"

--[[ {
--	update_list = {
--		producer = {updates}
--		wire     = {updates}
--		consumer = {updates}
	}
--
--	wait = {}
--   }
--]]

local file = io.open(database_path, "r")
if file then
	local pending_string = file:read("*all")
	if pending_string and pending_string ~= "" then
		c.pending = core.deserialize(pending_string)
	end
	file:close()
end

if not c.pending then
	c.pending = {
		update_list = {},
		wait = {},
	}
end

local function save_pending()
	local file = assert(io.open(database_path, "w"))
	local pending_string = core.serialize(c.pending)
	if pending_string then
		file:write(pending_string)
	end
	file:close()
end

core.register_on_shutdown(save_pending)
