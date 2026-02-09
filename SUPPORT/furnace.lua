local c = circuits

if c.is_mod_enabled("default") then
  local furnace_on = "default:furnace_active"
  local furnace_off = "default:furnace"
  local furnaces = {
    on = core.registered_nodes[furnace_on],
    off = core.registered_nodes[furnace_off]
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
		end,
    powered = furnace_on,
	  off = furnace_off
	}

  for state, furnace in pairs(furnaces) do
    local on_destruct = table.copy(furnace.on_destruct)
    local on_timer = table.copy(furnace.on_timer)
    local on_construct = table.copy(furnace.on_construct)
    furnace.groups.circuit_power = 1 

    local name = ""
    if state == "on" then
      name = furnace_on
    elseif state == "off" then
      name = furnace_off
    end
    core.override_item(name, {
      groups = furnace.groups,
      connects_to = {"group:circuit_consumer", "group:circuit_wire"},
      circuits = circuits_def,
      on_construct = function(pos)
        circuits.on_construct(pos)
        if on_construct then
          return on_construct(pos)
        end
      end,
      on_timer = function(pos, elapsed, node, timeout)
        local timer_return
        if on_timer then
          timer_return = on_timer(pos, elapsed, node, timeout)
        end
        local npos = c.npos(pos)
		    if c.is_on(npos) then
  	    	c.wait(npos,"on",1)
        elseif not c.is_on(npos) then
  	    	c.wait(npos,"off",1)
	      end
        return timer_return
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