local S, PS = core.get_translator("circuits")
local c = circuits

local wire = {
	description = S("Wire"),
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
		connect_top = {-0.2,-0.2,-0.2,0.2,0.5,0.2},
		connect_bottom = {-0.2,-0.5,-0.2,0.2,0.2,0.2},
		connect_front = {-0.2,-0.2,-0.5,0.2,0.2,0.2},
		connect_back = {-0.2,-0.2,-0.2,0.2,0.2,0.5},
		connect_left = {-0.5,-0.2,-0.2,0.2,0.2,0.2},
		connect_right = {-0.2,-0.2,-0.2,0.5,0.2,0.2}
	},
	selection_box = {
		type = "connected",
		fixed = {-0.3,-0.3,-0.3,0.3,0.3,0.3},
		connect_top = {-0.3,-0.3,-0.3,0.3,0.5,0.3},
		connect_bottom = {-0.3,-0.5,-0.3,0.3,0.3,0.3},
		connect_front = {-0.3,-0.3,-0.5,0.3,0.3,0.3},
		connect_back = {-0.3,-0.3,-0.3,0.3,0.3,0.5},
		connect_left = {-0.5,-0.3,-0.3,0.3,0.3,0.3},
		connect_right = {-0.3,-0.3,-0.3,0.5,0.3,0.3}
	},
	collision_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
	},
	tiles = {"circuits_wire.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {choppy=1,circuit_wire=1,circuit_raw_wire=1},
	stack_max = c.stack_max(),
	connects_to = {"group:circuit_wire", "group:circuit_consumer", "group:circuit_power"},
	--	Circuits properties definition area
	circuits = {
		connects = c.local_area,
		connects_to = {"circuit_consumer", "circuit_wire", "circuit_power"},
		store_connect = "param2",
		powering = function(npos, rpos)
			return c.is_on(npos)
		end
	},
}

c.register_on_off(c.mod()..":wire", wire,
{
	groups = {
		choppy=1,
		circuit_wire=1,
		circuit_raw_wire=1,
		not_in_creative_inventory=1
	}
},
{
	tiles = {"circuits_wire.png^[colorize:#111:160"},
})

if c.is_mod_enabled("default") then
	core.register_craft({
		output = c.mod()..":wire_off 9",
		recipe = {
			{"default:papyrus", "default:papyrus", "default:papyrus"},
			{"copper_wire_spool", "copper_wire_spool", "copper_wire_spool"},
			{"default:papyrus", "default:papyrus", "default:papyrus"}
		}
	})
end

local colors = {
	red = "^[colorize:#F00:160",
	green = "^[colorize:#0F0:160",
	blue = "^[colorize:#00F:160",
}

for k, color in ipairs{"red", "green", "blue"} do
	local def = table.copy(wire)
	local col_string = colors[color]
	local function color_translated(i)
		local color_trans = {S("Red"), S("Green"), S("Blue")}
		return color_trans[i]
	end
	def.description = S("@1 Wire", color_translated(k))
	def.tiles[1] = def.tiles[1] .. col_string
	def.groups = {choppy=1,["circuit_wire_"..color]=1,circuit_wire=1}
	def.connects_to = {"group:circuit_raw_wire", "group:circuit_wire_"..color,
		"group:circuit_consumer", "group:circuit_power"}
	def.circuits.connects_to = {"circuit_raw_wire", "circuit_wire_"..color,
	  "circuit_consumer", "circuit_power"}
	c.register_on_off(c.mod()..":wire_"..color, def,
	{
		groups={choppy=1,circuit_wire=1,not_in_creative_inventory=1,["circuit_wire_"..color]=1}
	},
	{
		tiles = {"circuits_wire.png" .. col_string .. "^[colorize:#111:160"}
	})
	if c.is_mod_enabled("default") then
		core.register_craft({
			output = "wire_"..color.." 9",
			recipe = {
				{"default:papyrus", "dye:"..color, "default:papyrus"},
				{"copper_wire_spool", "copper_wire_spool", "copper_wire_spool"},
				{"default:papyrus", "dye:"..color, "default:papyrus"}
			}
		})
	end
end