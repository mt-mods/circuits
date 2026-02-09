local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	core.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	core.swap_node(npos,npos.node)
end

local on_time = tonumber(core.settings:get("circuits_button_on_timer")) or 1

local button = {
	description = "Button",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.15,-0.501,-0.15,0.15,-0.35,0.15}}
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.2,0.3,-0.2,0.2,0.5,0.2},
		wall_side = {-0.3,-0.2,-0.2,-0.5,0.2,0.2},
		wall_bottom = {-0.2,-0.3,-0.2,0.2,-0.5,0.2},
	},
	tiles = {"circuits_wood.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {oddly_breakable_by_hand=2,circuit_power=1},
	stack_max = c.stack_max(),
	connects_to = {"group:circuit_wire"},
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		local npos = c.npos(pos,node)
		if not c.is_on(npos) then
			c.power_update(npos,"on")
		end
		core.get_node_timer(pos):start(on_time)
	end,
	on_timer = function(pos,_)
		local npos = c.npos(pos)
		if c.is_on(npos) then
			c.power_update(npos,"off")
		end

		return false
	end,
	circuits = {
		connects = c.behind,
		connects_to = {"circuit_consumer", "circuit_wire"},
		store_connect = "meta",
		on_update = function(npos, args)
			if args == "on" and not c.is_on(npos) then
				power_on(npos)
			elseif args == "off" and c.is_on(npos) then
				power_off(npos)
			else
				return false
			end

			for _,node in ipairs(c.get_all_connected(npos)) do
				c.update(node)
			end
			return true
		end,
		powering = function(npos, rpos)
			return c.is_on(npos)
		end
	}
}

circuits.register_on_off(c.mod()..":button",button,
{
	groups = {oddly_breakable_by_hand=2,circuit_power=1,not_in_creative_inventory=1}
},{})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({output="button",recipe={{"group:wood"}}})
elseif c.is_mod_enabled("blk") then
	core.register_craft({output="button",recipe={{"group:wood_planks"}}})
end