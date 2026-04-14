-- register circuits namespace
circuits = {}
-- info about circuits
circuits.info = {
	name = "circuits",
	version = "v1.2.2"
}

-- funcion to load files
function circuits.modpath(file)
	local mod = core.get_current_modname()
	local modpath = core.get_modpath(mod)
	return dofile(modpath..file)
end

-- load the files
circuits.modpath("/util.lua")
circuits.modpath("/position.lua")
circuits.modpath("/connection.lua")
circuits.modpath("/persistance.lua")
circuits.modpath("/power.lua")
circuits.modpath("/wire.lua")
circuits.modpath("/modding.lua")

-- check if the wrench is enabled
local wrench_enabled = core.settings:get("circuits_wrench_enabled") or false

if wrench_enabled then
	circuits.modpath("/wrench.lua")
end