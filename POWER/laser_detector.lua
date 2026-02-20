local S, PS = core.get_translator("circuits")
local c = circuits

local range = tonumber(core.settings:get("circuits_laser_connect_range")) or 10
local function ray_points(pos, pos2)
  local pos_start = {}
  local pos_end = {}
  if pos and pos2 then
    -- Check the x.pos to see if they match.
    if pos.x ~= pos2.x then
      if pos.x > pos2.x then
        pos_start = {x=pos.x-1, y=pos.y, z=pos.z}
        pos_end = {x=pos2.x+1, y=pos2.y, z=pos2.z}
      else
        pos_start = {x=pos.x+1, y=pos.y, z=pos.z}
        pos_end = {x=pos2.x-1, y=pos2.y, z=pos2.z}
      end
    -- Check the y.pos to see if they match.
    elseif pos.y ~= pos2.y then
      if pos.y > pos2.y then
        pos_start = {x=pos.x, y=pos.y-1, z=pos.z}
        pos_end = {x=pos2.x, y=pos2.y+1, z=pos2.z}
      else
        pos_start = {x=pos.x, y=pos.y+1, z=pos.z}
        pos_end = {x=pos2.x, y=pos2.y-1, z=pos2.z}
      end
    -- Check the z.pos to see if they match.
    elseif pos.z ~= pos2.z then
      if pos.z > pos2.z then
        pos_start = {x=pos.x, y=pos.y, z=pos.z-1}
        pos_end = {x=pos2.x, y=pos2.y, z=pos2.z+1}
      else
        pos_start = {x=pos.x, y=pos.y, z=pos.z+1}
        pos_end = {x=pos2.x, y=pos2.y, z=pos2.z-1}
      end
    end
  end
  return pos_start, pos_end
end

local detector = {
  description = S("Laser Detector"),
  tiles = {"circuits_laser_detector.png"},
  paramtype = "light",
  is_ground_content = false,
  groups = {cracky=1,laser=1,detector=1,circuit_power=1,not_in_creative_inventory=1},
  stack_max = c.stack_max(),
  on_construct = function(pos)
    core.get_node_timer(pos):start(0.01)
    local pos_table = {
      {x=pos.x+range, y=pos.y, z=pos.z}, {x=pos.x-range, y=pos.y, z=pos.z},
      {x=pos.x, y=pos.y+range, z=pos.z}, {x=pos.x, y=pos.y-range, z=pos.z},
      {x=pos.x, y=pos.y, z=pos.z+range}, {x=pos.x, y=pos.y, z=pos.z-range}
    }
    for i, pos2 in ipairs(pos_table) do
      local ray = core.raycast(pos, pos2, false)
      for pointed_thing in ray do
        if pointed_thing.type == "node" then
          local pos_hit = pointed_thing.under
          local node = core.get_node(pos_hit)
          if node.name == "circuits_power:laser_detector_off" and pos_hit ~= pos then
            local meta1 = core.get_meta(pos)
            local meta2 = core.get_meta(pos_hit)
            if meta2:get_string("laser_connect") == "" then
              meta1:set_string("laser_connect", core.pos_to_string(pos_hit))
              meta2:set_string("laser_connect", core.pos_to_string(pos))
              break
            end
          end
        end
      end
    end
  end,
  on_destruct = function(pos)
    local meta = core.get_meta(pos)
    local connect = meta:get_string("laser_connect")
    if connect ~= "" then
      local pos2 = core.string_to_pos(connect)
      local meta2 = core.get_meta(pos2)
      meta2:set_string("laser_connect", "")
    end
  end,
  on_timer = function(pos)
    local npos = c.npos(pos)
    local meta = core.get_meta(pos)
    local connect = meta:get_string("laser_connect")
    if connect ~= "" then
      local pos2 = core.string_to_pos(connect)
      local pos_start, pos_end = ray_points(pos, pos2)
      local ray = nil
      if pos_start.x and pos_end.x then
        ray = core.raycast(pos_start, pos_end)
      end
      local first_hit = nil
      if ray then
        first_hit = ray()
      end
      local has_hit = first_hit ~= nil
      if not c.is_on(npos) and has_hit then
        c.power_update(npos, "on")
      elseif c.is_on(npos) and not has_hit then
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
        npos.node.name = c.get_powered(npos)
	      core.swap_node(npos,npos.node)
      elseif args == "off" and c.is_on(npos) then
        npos.node.name = c.get_off(npos)
	      core.swap_node(npos,npos.node)
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

c.register_on_off(c.mod()..":laser_detector",detector,{},{
  groups = {cracky=1,laser=1,detector=1,circuit_power=1}
})

--crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = c.mod()..":laser_detector_off",
    recipe = {
      {"default:steel_ingot", "dye:red", "default:steel_ingot"},
      {"copper_wire_spool", "light_bulb", "copper_wire_spool"},
      {"group:stone", "circuit_board", "group:stone"}
    }
  })
end