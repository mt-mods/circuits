local c = circuits

c.modpath("/src/aliases.lua")
c.modpath("/src/doors.lua")
c.modpath("/src/mod.lua")
c.modpath("/src/craftitems.lua")

if c.is_mod_enabled("mesecons") then
	c.modpath("/src/mesecons.lua")
end
--[[
currently does not work, need to solve issues with circuits definition not being found
-- c.modpath("/furnace.lua")
-- c.modpath("/chest.lua")
]]
