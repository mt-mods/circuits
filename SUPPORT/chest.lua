local c = circuits

if c.is_mod_enabled("default") then
  local chests = {
    core.registered_nodes["default:chest"],
    core.registered_nodes["default:chest_locked"]
  }

  local circuits_def = {
		connects = c.behind,
		connects_to = {"circuit_consumer", "circuit_wire"},
		store_connect = "meta",
		on_update = function(npos, args)
			for _,node in ipairs(c.get_all_connected(npos)) do
				c.update(node)
			end
			return true
		end,
		powering = function(npos, rpos)
			return c.is_on(npos)
		end
	}

  for k, chest in ipairs(chests) do
    local on_destruct = table.copy(chest.on_destruct)
    local on_rightclick = table.copy(chest.on_rightclick)
    local on_construct = table.copy(chest.on_construct)
    chest.groups.circuit_power = 1

    local name = chest.name
    circuits_def.powered = name
    circuits_def.off = name

    core.override_item(name, {
      groups = chest.groups,
      connects_to = {"group:circuit_consumer", "group:circuit_wire"},
      circuits = circuits_def,
      on_construct = function(pos)
        if on_construct then
          on_construct(pos)
        end
        circuits.on_construct(pos)
      end,
      on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local npos = c.npos(pos)
        c.power_update(npos, "on")
        core.get_node_timer(pos):start(1)
        return on_rightclick(pos, node, clicker, itemstack, pointed_thing)
      end,
      on_timer = function(pos, elapsed, node, timeout)
        local npos = c.npos(pos)
  	    c.power_update(npos,"off")
      end,
      on_destruct = function(pos)
        circuits.on_destruct(pos)
        if on_destruct then
          return on_destruct(pos)
        end
      end
    })
  end
end