-- checks if doors is enabled
-- gets all registered doors
local registered_doors = {}
for name, def in pairs(core.registered_nodes) do
	if def.groups.door > 0 then
		table.insert(registered_doors, name)
	end
end
-- creates the circuits_def for the doors
local circuits_def = {
	connects = circuits.behind,
	connects_to = { "circuit_wire", "circuit_power" },
	store_connect = "meta",
	on_update = function(npos)
		for _, node in ipairs(circuits.get_all_connected(npos)) do
			if circuits.is_powering(node, npos) then
				if not circuits.is_on(npos) then
					if circuits.is_mod_enabled("doors") then
						doors.door_toggle(npos)
					end
					return true
				else
					break
				end
			end
		end
		if circuits.is_on(npos) then
			if circuits.is_mod_enabled("doors") then
				doors.door_toggle(npos)
			end
			return true
		else
			return false
		end
	end,
}
-- adds updates and adds new definitions to the registered doors
for i, name in ipairs(registered_doors) do
	local node_def = core.registered_nodes[name]
	local node_groups = node_def.groups
	local function node_destruct(pos)
		return node_def.on_destruct
	end
	node_groups.circuit_consumer = 1
	core.override_item(name, {
		groups = node_groups,
		circuits = circuits_def,
		on_construct = function(pos)
			circuits.on_construct(pos)
		end,
		on_destruct = function(pos)
			circuits.on_destruct(pos)
			if node_destruct then
				node_destruct(pos)
			end
		end,
	})
end
