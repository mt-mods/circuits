local c = circuits

c.modpath("/aliases.lua")
c.modpath("/doors.lua")
c.modpath("/mod.lua")
c.modpath("/craftitems.lua")
if c.is_mod_enabled("mesecons") then
  c.modpath("/mesecons.lua")
end
-- currently does not work, need to solve issues with circuits definition not being found
-- c.modpath("/furnace.lua")
-- circuits.modpath("/chest.lua")