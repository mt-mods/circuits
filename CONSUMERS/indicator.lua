local S, PS = core.get_translator("circuits")
local c = circuits

local indicator = {
	description = S("Indicator"),
	drawtype = "normal",
	tiles = {"circuits_indicator_on.png"},
	use_texture_alpha = "opaque",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	groups = {choppy=1,circuit_consumer=1},
	connects_to = {"group:circuit_wire","group:circuit_power"},
	circuits = {
		connects = c.local_area,
		connects_to = {"circuit_wire", "circuit_power"},
		store_connect = "param1",
		on_update = function(npos)
			for _,node in ipairs(c.get_all_connected(npos)) do
				if c.is_powering(node, npos) then
					if not c.is_on(npos) then
						npos.node.name = c.get_powered(npos)
						core.swap_node(npos,npos.node)
						return true
					else
						return false
					end
				end
			end

			if c.is_on(npos) then
				npos.node.name = c.get_off(npos)
				core.swap_node(npos,npos.node)
				return true
			else
				return false
			end
		end
	}
}

c.register_on_off(c.mod()..":indicator",indicator,
{
	groups = {choppy=1,circuit_consumer=1,not_in_creative_inventory=1}
},
{
	tiles = {"circuits_indicator_off.png"}
})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = "indicator",
    recipe = {
      {"group:stone", "group:glass", "group:stone"},
      {"group:stone", "light_bulb", "group:stone"},
			{"group:stone", "default:copper_ingot", "group:stone"}
    }
  })
end