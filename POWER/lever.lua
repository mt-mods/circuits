-- local variables
local S, PS = core.get_translator("circuits")
local c = circuits
local auto_off = core.settings:get("circuits_lever_auto_off") or false
local on_time = tonumber(core.settings:get("circuits_lever_on_timer")) or 5

-- local functions
local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	core.swap_node(npos,npos.node)
end
local function power_off(npos)
	npos.node.name = c.get_off(npos)
	core.swap_node(npos,npos.node)
end

-- definition
local lever = {
	description = S("Lever"),
	drawtype = "mesh",
	mesh = "circuits_lever_down.gltf",
	selection_box = {
		type = "fixed",
		fixed = {-0.2500, -0.2500, 0.3125, 0.2500, 0.2500, 0.5000}
	},
  collision_box = {
		type = "fixed",
		fixed = {-0.2500, -0.2500, 0.3125, 0.2500, 0.2500, 0.5000}
	},
	tiles = {"circuits_lever_mesh.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {oddly_breakable_by_hand=1,choppy=1,circuit_power=1},
	stack_max = c.stack_max(),
	connects_to = {"group:circuit_wire"},
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		local npos = c.npos(pos,node)

		if not c.is_on(npos) then
			c.power_update(npos,"on")
    elseif c.is_on(npos) then
      c.power_update(npos, "off")
		end

    if auto_off then
		  core.get_node_timer(pos):start(on_time)
    end
	end,
	on_timer = function(pos,_)
		local npos = c.npos(pos)

		if c.is_on(npos) then
			c.power_update(npos,"off")
		end

		return false
	end,
	circuits = {
		connects = {x = {2, -2}, y = {2, -2}, z = {2, -2}},
		connects_to = {"circuit_consumer", "circuit_wire"},
		store_connect = "meta",
		on_update = function(npos, args)
			if args == "on" and not c.is_on(npos) then
				power_on(npos)
			elseif args =="off" and c.is_on(npos) then
				power_off(npos)
			else
				return false
			end

			for _,node in ipairs(c.get_all_connected(npos)) do
				c.update(node)
			end

			return true
		end,
		powering = function(npos)
			return c.is_on(npos)
		end
	}
}

-- register the nodes
circuits.register_on_off(c.mod()..":lever",lever,
{
  mesh = "circuits_lever_up.gltf",
	groups = {
    oddly_breakable_by_hand=1,
    choppy=1,
    circuit_power=1,
    not_in_creative_inventory=1
  }
},{})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
		output = "lever 4",
		recipe = {
    	{"group:wood"},
    	{"copper_wire_spool"}
		}
  })
elseif c.is_mod_enabled("blk") then
	core.register_craft({
		output = "lever 4",
		recipe = {
  	  {"group:wood_planks"},
    	{"copper_bar"}
  	}
	})
end