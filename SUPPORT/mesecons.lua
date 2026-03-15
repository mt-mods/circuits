local S, PS = core.get_translator("circuits")
local c = circuits
local name = c.mod()..":converter"
local rules = mesecon.rules.flat
local refresh_rate = tonumber(core.settings:get("circuits_converter_refresh_rate")) or 0.3

local converter = {
  description = S("Converter"),
  drawtype = "normal",
  tiles = {
    "circuits_converter_top_on.png",
    "circuits_converter_bottom_on.png",
    "circuits_converter_side_on.png"
  },
  use_texture_alpha = "clip",
  is_ground_content = false,
  mesecon_wire = false,
  stack_max = c.stack_max(),
  groups = {
    cracky = 1,
    circuit_wire = 1,
    circuit_consumer = 1,
    not_in_creative_inventory = 1
  },
  connects_to = {
    "group:circuit_wire",
    "group:circuit_power",
    "group:mesecon_conductor_craftable"
  },
  on_timer = function(pos)
    local npos = c.npos(pos)
    local network_on = false
    local searched = {}
    local queue = {pos}
    local mctable = {
      pos1 = {x = pos.x+1, y = pos.y, z = pos.z},
      pos2 = {x = pos.x-1, y = pos.y, z = pos.z},
      pos3 = {x = pos.x, y = pos.y, z = pos.z+1},
      pos4 = {x = pos.x, y = pos.y, z = pos.z-1}
    }

    while #queue > 0 and not network_on do
      local pos2 = table.remove(queue, 1)

      if not searched[tostring(pos2)] then
        searched[tostring(pos2)] = true

        local node = core.get_node(pos2)
        local npos2 = c.npos(pos2, node)
        local cd = c.get_circuit_def(node.name)
        local connected = c.get_all_connected(npos2)

        if cd and cd.powering and c.is_on(npos2) and not c.is_same_pos(pos, pos2)
            and core.get_item_group(node.name, "circuit_power") > 0 then
          network_on = true
          break
        end

        for _, cpos in ipairs(connected) do
          if not searched[tostring(cpos)] then
            table.insert(queue, cpos)
          end
        end
      end
    end

    for b, mcpos in pairs(mctable) do
      if type(mesecon.is_powered(mcpos)) == "table" then
        for a, mpos in ipairs(mesecon.is_powered(mcpos)) do
          local mnode = mesecon.get_node_force(mpos)

          if mesecon.is_receptor_on(mnode.name) and not c.is_same_pos(pos, mpos) then
            network_on = true
            break
          end
        end
      end
    end

    if network_on then
      c.update(npos, "on")
    elseif not network_on then
      c.update(npos, "off")
    end

    return true
  end,
  on_construct = function(pos)
    core.get_node_timer(pos):start(refresh_rate)
  end,
  circuits = {
    connects = c.local_area,
    connects_to = {
      "circuit_wire",
      "circuit_power",
      "mesecon_conductor_craftable"
    },
    store_connect = "meta",
    on_update = function(npos, args)
      if args == "on" and not c.is_on(npos) then
        mesecon.receptor_on(npos, rules)
        npos.node.name = c.get_powered(npos)
	      core.set_node(npos,npos.node)
      elseif args == "off" and c.is_on(npos) then
        mesecon.receptor_off(npos, rules)
        npos.node.name = c.get_off(npos)
	      core.set_node(npos,npos.node)
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

c.register_on_off(name, converter,
  {
    groups = {cracky=1, not_in_creative_inventory=1, circuit_consumer=1, circuit_power=1},
    mesecons = {
      receptor = {
        rules = rules,
        state = mesecon.state.on
      }
    }
  },
  {
    tiles = {
      "circuits_converter_top_off.png",
      "circuits_converter_bottom_off.png",
      "circuits_converter_side_off.png"
     },
    groups = {cracky=1, converter=1, circuit_consumer=1},
    mesecons = {
      receptor = {
        rules = rules,
        state = mesecon.state.off
      }
    }
  }
)

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = "converter",
    recipe = {
      {"copper_wire_spool", "circuit_board", "copper_wire_spool"},
      {"default:steel_ingot", "copper_wire_spool", "default:steel_ingot"},
      {"default:mese_crystal", "circuit_board", "default:mese_crystal"}
    }
  })
end
