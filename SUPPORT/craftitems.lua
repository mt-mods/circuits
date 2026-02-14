local S, PS = core.get_translator("circuits")
local c = circuits

-- for use in crafting recipes
core.register_craftitem(c.mod()..":circuit_board",{
  description = S("Circuit Board"),
  inventory_image = "circuits_circuit_board.png",
  groups = {circuit_board = 1, craft_item = 1}
})
core.register_alias("circuit_board", c.mod()..":circuit_board")

core.register_craftitem(c.mod()..":light_bulb",{
  description = S("Lightbulb"),
  inventory_image = "circuits_light_bulb.png",
  groups = {light_bulb = 1, craft_item = 1}
})
core.register_alias("light_bulb", c.mod()..":light_bulb")

-- crafts
if c.is_mod_enabled("default") then
  -- circuit board
  core.register_craft({
    output = c.mod()..":circuit_board",
    recipe = {
      {"dye:green", "default:copper_ingot", "dye:green"},
      {"default:tin_ingot", "group:circuit_wire", "default:tin_ingot"},
      {"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"}
    }
  })
  -- lightbulb
  core.register_craft({
    output = "light_bulb 9",
    recipe = {
      {"group:glass"},
      {"default:torch"},
      {"default:copper_ingot"}
    }
  })
elseif c.is_mod_enabled("blk") then
  -- circuit board
  core.register_craft({
    output = c.mod()..":circuit_board",
    recipe = {
      {"iron_bar", "copper_bar", "iron_bar"},
      {"gold_bar", "group:circuit_wire", "gold_bar"},
      {"iron_bar", "copper_bar", "iron_bar"}
    }
  })
end