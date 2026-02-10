local c = circuits

local disappear = {
  description = "Disappearing Node",
  drawtype = "normal",
  tiles = {"circuits_disappear.png"},
  is_ground_content = false,
  groups = {cracky=1,disappear=1,circuit_wire=1,circuit_consumer=1},
  connects_to = {
    "group:disappear",
    "group:vanish",
    "group:circuit_wire",
    "group:circuit_power"
  },
  circuits = {
    connects = c.local_area,
    connects_to = {"disappear", "vanish", "circuit_wire", "circuit_power"},
    store_connect = "param2",
    on_update = function(npos)
      for k,node in ipairs(c.get_all_connected(npos)) do
        if c.is_powering(node, npos) then
          if not c.is_on(npos) then
            core.swap_node(npos, {name="air"})
            return true
          else
            return false
          end
        end
      end
    end,
    powered = "air",
	  off = c.mod()..":disappear",
    base_node = c.mod()..":disappear"
  }
}

c.register_node(c.mod()..":disappear",disappear)

-- crafts
if c.is_mod_enabled("default") then
  core.register_craft({
    output = "disappear",
    recipe = {
      {"group:stone", "group:stone", "group:stone"},
      {"default:copper_ingot", "default:mese", "default:copper_ingot"},
      {"group:stone", "circuit_board", "group:stone"}
    }
  })
end