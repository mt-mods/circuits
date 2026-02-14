local S, PS = core.get_translator("circuits")
local c = circuits

local function is_facedir(npos)
	local def = core.registered_nodes[npos.node.name]
	if not def then
		return false
	end

	if def.paramtype2 == "facedir" then
		return true
	end
	return false
end

local dir_to_facedir = {
	[c.hash_pos({x=0,y=1,z=0})] = 0,
	[c.hash_pos({x=0,y=-1,z=0})] = 20,
	[c.hash_pos({x=1,y=0,z=0})] = 12,
	[c.hash_pos({x=-1,y=0,z=0})] = 16,
	[c.hash_pos({x=0,y=0,z=1})] = 4,
	[c.hash_pos({x=0,y=0,z=-1})] = 8
}

core.register_craftitem(c.mod()..":wrench", {
	description = S("Wrench"),
	inventory_image = "circuits_wrench.png",
	on_use = function(itemstack, placer, pointed_thing)
		-- Prevents shutdown of the game when pointed at nothing.
		if pointed_thing.type ~= "node" then
			core.log("You must point at a node!")
			return nil
		end
		local node = core.get_node(pointed_thing.under)
		local name = node.name
		-- Prevents use on the wrench on chests
		if string.find(name,"chest") then
			core.log("Don't use the wrench on a chest!")
			return nil
		end
		local npos = c.npos(pointed_thing.under)
		if not is_facedir(npos) then
			return
		end
		local above = pointed_thing.above
		local dir = vector.subtract(npos, above)
		npos.node.param2 = dir_to_facedir[c.hash_pos(dir)]
		core.set_node(npos, npos.node)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		-- Prevents shutdown of the game when pointed at nothing.
		if pointed_thing.type ~= "node" then
			core.log("You must point at a node!")
			return nil
		end
		local node = core.get_node(pointed_thing.under)
		local name = node.name
		-- Prevents use on the wrench on chests
		if string.find(name,"chest") then
			core.log("Don't use the wrench on a chest!")
			return nil
		end
		local npos = c.npos(pointed_thing.under)
		if not is_facedir(npos) then
			return
		end
		local new_rot = npos.node.param2 + 1
		if new_rot % 4 < npos.node.param2 % 4 then
			new_rot = npos.node.param2 - (npos.node.param2 % 4)
		end
		npos.node.param2 = new_rot
		core.set_node(npos, npos.node)
	end
})
core.register_alias("wrench", c.mod()..":wrench")

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = "wrench",
    recipe = {
      {"", "default:steel_ingot", ""},
      {"default:steel_ingot", "default:steel_ingot", ""},
			{"", "", "default:steel_ingot"}
    }
  })
end