local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	core.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	core.swap_node(npos,npos.node)
end

local pressure_plate = {
	description = "Pressure Plate",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.4,-0.5,-0.4,0.4,-0.4,0.4}}
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.4,0.3,-0.4,0.4,0.5,0.4},
		wall_side = {-0.3,-0.4,-0.4,-0.5,0.4,0.4},
		wall_bottom = {-0.4,-0.3,-0.4,0.4,-0.5,0.4}
	},
	tiles = {"circuits_wood.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {choppy=1,source=1,circuit_power=1},
	stack_max = c.stack_max(),
	on_construct = function(pos)
		core.get_node_timer(pos):start(0.1)
	end,
	on_timer = function(pos,_)
		local npos = c.npos(pos)
		local entity = core.get_objects_inside_radius(npos,0.8)

		if entity and #entity >= 1 then
			if not c.is_on(npos) then
				c.power_update(npos,"on")
			end
		else
			if c.is_on(npos) then
				c.power_update(npos,"off")
			end
		end
		return true
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
		end,
	},
}

c.register_on_off(c.mod()..":pressure_plate",pressure_plate,
{
	groups = {choppy=1,source=1,circuit_power=1,not_in_creative_inventory=1}
},{})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
		output = "pressure_plate",
		recipe = {{"group:wood","group:wood","group:wood"}}
	})
elseif c.is_mod_enabled("blk") then
	core.register_craft({
		output = "pressure_plate",
		recipe = {{"group:wood_planks","group:wood_planks","group:wood_planks"}}})
end