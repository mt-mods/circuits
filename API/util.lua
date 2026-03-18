local c = circuits

-- helper variables
circuits.hash_pos = core.hash_node_position
circuits.unhash_pos = core.get_position_from_hash

-- Requires the node's name with out _on or _off.
-- A definition table to be shared between the on and off nodes.
-- A definition table for both the on and off node.
-- Registers two nodes and an alias for the off node.
c.register_on_off = function(name, def, on_def, off_def)
	if not name or not def or not on_def or not off_def then
		return error("[Circuits]: circuits.register_on_off() is missing arguments")
	end
	local name_on = name .. "_on"
	local name_off = name .. "_off"

	def.circuits = def.circuits or {}
	def.circuits.base_node = name

	def.circuits.powered = name_on
	def.circuits.off = name_off

	local on = table.copy(on_def)
	local off = table.copy(off_def)

	for k,v in pairs(def) do
		on[k] = on[k] or v
		off[k] = off[k] or v
	end

	on.drop = on.drop or name_off

	local alias_off = string.gsub(name_off, "^.*:", "")
	local alias = string.gsub(alias_off, "_off", "")

	c.register_node(name_on,on)
	c.register_node(name_off,off)
	core.register_alias(alias, name_off)
end

-- Get the circuits table of a node
-- returns false if does not exist
c.get_circuit_def = function(node_name)
	if not node_name then
		return error("[Circuits]: circuits.get_circuit_def() node_name is not defined")
	end
	local def = core.registered_nodes[node_name]
	if not def or not def.circuits then
		return false
	end

	return def.circuits
end

c.get_powered = function(npos)
	if not npos then
		return error("[Circuits]: circuits.get_powered() npos is not defined")
	elseif not npos.node then
		npos = c.npos(npos)
	end
	local cd = c.get_circuit_def(npos.node.name)

	if not cd or not cd.powered then
		return nil
	end

	return cd.powered
end

c.get_off = function(npos)
	if not npos then
		return error("[Circuits]: circuits.get_off() npos is not defined")
	elseif not npos.node then
		npos = c.npos(npos)
	end
	local cd = c.get_circuit_def(npos.node.name)

	if not cd or not cd.off then
		return nil
	end

	return cd.off
end

-- gets whether the node is on or off
c.is_on = function(npos)
	if not npos then
		return error("[Circuits]: circuits.is_on() npos is not defined"
		)
	elseif not npos.node then
		npos = c.npos(npos)
	end
	if npos.node.name == c.get_off(npos) then
		return false
	end
	if npos.node.name == c.get_powered(npos) then
		return true
	end
	return nil
end

-- Mutate a pos into an npos
-- pos - a position
-- [node] - a node
c.npos = function(pos, node)
	if not pos then
		return error("[Circuits]: circuits.npos() pos is not defined")
	elseif not node then
		node = core.get_node(pos)
	end
	pos.node = node
	return pos
end

c.on_construct = function(pos)
	if not pos then
		return error("[Circuits]: circuits.on_construct() pos is not defined")
	end
	pos = c.npos(pos)
	c.connect_all(pos)
end

c.on_destruct = function(pos)
	if not pos then
		return error("[Circuits]: circuits.on_destruct() pos is not defined")
	end
	pos = c.npos(pos)
	c.disconnect_all(pos)
end

-- requires the node name and node definition table
c.register_node = function(name, def)
	if not name or not def then
		return error("[Circuits]: circuits.register_node() name or def is not defined")
	end
	def.circuits = def.circuits or {}
	local cd = def.circuits

	-- Plug in correct rotation
	if def.paramtype2 == "wallmounted" then
		cd.rot = "wallmounted"
	elseif def.paramtype2 == "facedir" then
		cd.rot = "facedir"
	end

	-- Check param storage
	if def.paramtype and cd.store_connect == "param1" then
		error("Storing connections in used param1")
	elseif def.paramtype2 and cd.store_connect == "param2" then
		error("Storing connections in used param2")
	end
	cd.store_connect = cd.store_connect or "meta"

	-- Create construct/destruct
	for _, action in ipairs{"on_construct", "on_destruct"} do
		if def[action] then
			local circuits_action = c[action]
			local def_action = def[action]
			def[action] = function(pos)
				def_action(pos)
				circuits_action(pos)
			end
		else
			def[action] = c[action]
		end
	end

	-- Check that consumers/power have updates
	if (def.groups.circuit_power or def.groups.circuit_consumer) and not cd.on_update then
		core.log("error", "Consumer/Producer defined without update")
	elseif def.groups.circuit_wire then
		cd.on_update = c.wire_update
	end

	-- Check producer is_powering
	if def.groups.circuit_power and not cd.powering then
		error("Producer defined without is_powering")
	end

	-- Check connections exist
	if not cd.connects_to or not cd.connects then
		error("Component defined without any connection rules")
	end

	-- Check that a base node is set if wire
	if def.groups.circuit_wire and not cd.base_node then
		error("Wire set without a base node")
	end

	core.register_node(name, def)
end

-- checks if a mod has been enabled for this world
function c.is_mod_enabled(mod)
	if not mod then
		return error("[Circuits]: circuits.is_mod_enabled() mod is not defined")
	end
	if mod and core.get_modpath(mod) then
		return true
	else
		return false
	end
end

-- gets the current mod's name
function c.mod()
	return core.get_current_modname()
end

-- check if a pos1 and pos2 are the same
function c.is_same_pos(pos1, pos2)
	if not pos1 or not pos2 then
		return error("[Circuits]: circuits.is_same_pos() pos1 or pos2 is not defined")
	elseif pos2.x ~= pos1.x or pos2.y ~= pos1.y or pos2.z ~= pos1.z then
		return false
	else
		return true
	end
end