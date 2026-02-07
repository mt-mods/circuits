circuits = {}
circuits.info = {
	name = "circuits",
	version = "v1.0.0"
}
circuits.hash_pos = core.hash_node_position
circuits.unhash_pos = core.get_position_from_hash

-- loads files
function circuits.modpath(file)
	local mod = core.get_current_modname()
	local modpath = core.get_modpath(mod)
	return dofile(modpath..file)
end
circuits.modpath("/util.lua")
circuits.modpath("/position.lua")
circuits.modpath("/connection.lua")
circuits.modpath("/persistance.lua")
circuits.modpath("/power.lua")
circuits.modpath("/wire.lua")
circuits.modpath("/modding.lua")

local wrench_enabled = core.settings:get("circuits_wrench_enabled") or false
if wrench_enabled then
	circuits.modpath("/wrench.lua")
end