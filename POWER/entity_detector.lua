local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	core.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	core.swap_node(npos,npos.node)
end

local range = tonumber(core.settings:get("circuits_detector_range")) or 5

local detector = {
  description = "Entity Detector",
  tiles = {"circuits_entity_detector_on.png"},
  paramtype = "light",
  is_ground_content = false,
  groups = {choppy=1,detector=1,circuit_power=1,not_in_creative_inventory=1},
  stack_max = c.stack_max(),
  on_construct = function(pos)
    core.get_node_timer(pos):start(0.1)
  end,
  on_timer = function(pos,_)
    local npos = c.npos(pos)
    local entity = core.get_objects_inside_radius(npos,range+1)
    if #entity >= 1 then
      for k,obj in pairs(entity) do
        c.power_update(npos,"on")
        break
      end
    else
      if c.is_on(npos) then
        c.power_update(npos,"off")
      end
    end
    return true
  end,
  circuits = {
    connects = c.local_area,
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

c.register_on_off(c.mod()..":entity_detector",detector,{},{
  tiles = {"circuits_entity_detector_off.png"},
  groups = {choppy=1,detector=1,circuit_power=1}
})

-- crafts
core.register_craft({
  output = c.mod()..":entity_detector_off",
  recipe = {{"player_detector"}}
})

if c.is_mod_enabled("default") then
  core.register_craft({
    output = c.mod()..":entity_detector_off",
    recipe = {
      {"default:steel_ingot", "dye:red", "default:steel_ingot"},
      {"default:gold_ingot", "light_bulb", "default:copper_ingot"},
      {"default:steel_ingot", "circuit_board", "default:steel_ingot"}
    }
  })
elseif c.is_mod_enabled("blk") then
	core.register_craft({
    output=c.mod()..":entity_detector_off",
    recipe={
      {"iron_bar", "blk_dyes:red_dye", "iron_bar"},
      {"gold_bar", "copper_bar", "gold_bar"},
      {"iron_bar", "circuit_board", "iron_bar"}
    }
  })
end