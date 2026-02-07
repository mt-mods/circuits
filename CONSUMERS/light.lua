local c = circuits

local light = {
	description = "Light",
	drawtype = "nodebox",
	node_box = {
	  type = "fixed",
	  fixed = {{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}}
  },
	tiles = {"circuits_light_on.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	light_source = 14,
	is_ground_content = false,
	walkable = true,
	groups = {oddly_breakable_by_hand=2,circuit_light = 1,circuit_consumer=1},
	connects_to = {"group:circuit_wire","group:circuit_power"},
	circuits = {
		connects = {x = {2, -2}, y = {2, -2}, z = {2, -2}},
		connects_to = {"circuit_wire", "circuit_power"},
		store_connect = "meta",
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

c.register_on_off(c.mod()..":light",light,
{
	groups = {oddly_breakable_by_hand=2,circuit_consumer=1,not_in_creative_inventory=1}
},
{
	tiles = {"circuits_light_off.png"},
	light_source = 0,
})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = "light",
    recipe = {
      {"group:glass", "group:glass", "group:glass"},
      {"default:copper_ingot", "light_bulb", "default:steel_ingot"}
    }
  })
end

-- For some reason the regular lights don't work when these are registered.
--[[
light.circuits.connects_to = {"circuit_consumer","circuit_wire","circuit_power"}

c.register_on_off(c.mod()..":wired_light",light,
	{
		description = "Wired Light",
		groups = {
			choppy=1,
			circuit_light=1,
			circuit_wire=1,
			circuit_consumer=1,
			not_in_creative_inventory=1
		}
	}, {
		description = "Wired Light",
		tiles = {"circuits_light_off.png"},
		light_source = 0,
		groups = {
			choppy=1,
			circuit_light = 1,
			circuit_wire=1,
			circuit_consumer=1}
	}
)
]]