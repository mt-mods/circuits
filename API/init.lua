circuits = {}

-- function to load files
function circuits.modpath(file)
	local mod = core.get_current_modname()
	local modpath = core.get_modpath(mod)
	return dofile(modpath .. file)
end

-- load the files
circuits.modpath("/src/util.lua")
circuits.modpath("/src/position.lua")
circuits.modpath("/src/connection.lua")
circuits.modpath("/src/persistance.lua")
circuits.modpath("/src/power.lua")
circuits.modpath("/src/wire.lua")
circuits.modpath("/src/modding.lua")

-- check if the wrench is enabled
local wrench_enabled = core.settings:get("circuits_wrench_enabled") or false

if wrench_enabled then
	circuits.modpath("/wrench.lua")
end
