local S, PS = core.get_translator("circuits")
local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	core.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	core.swap_node(npos,npos.node)
end

local solar_panel = {
  drawtype = "nodebox",
  description = S("Solar Panel"),
  tiles = {"circuits_solar_panel.png"},
  paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {choppy=1,source=1,circuit_power=1},
  node_box = {
	  type = "fixed",
	  fixed = {{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}}
  },
	stack_max = c.stack_max(),
  connects_to = {"group:circuit_consumer","group:wire"},
	on_construct = function(pos)
		core.get_node_timer(pos):start(0.5)
	end,
	on_timer = function(pos,_)
		local npos = c.npos(pos)
    local mpos = {x = pos.x, y = pos.y, z = pos.z}
		local light = core.get_node_light(mpos)

		if light and light >= 12 then
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
	  	if args == "on" and not c.is_on(npos) then power_on(npos)
			elseif args == "off" and c.is_on(npos) then power_off(npos)
      else return false
			end
			for _,node in ipairs(c.get_all_connected(npos)) do c.update(node) end
		  return true
		end,
    powering = function(npos, rpos) return c.is_on(npos) end
  }
}

c.register_on_off(c.mod()..":solar_panel", solar_panel,
{
	groups = {choppy=1,source=1,circuit_power=1,not_in_creative_inventory=1}
},{})

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
		output = "solar_panel",
		recipe = {
      {"group:glass", "group:glass", "group:glass"},
      {"default:steel_ingot", "circuit_board", "default:steel_ingot"}
    }
	})
elseif c.is_mod_enabled("blk") then
	core.register_craft({
		output = "solar_panel",
		recipe = {
      {"group:glass", "group:glass", "group:glass"},
      {"iron_bar", "circuit_board", "iron_bar"}
    }
  })
end