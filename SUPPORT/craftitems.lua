local S, PS = core.get_translator("circuits")
local c = circuits

-- For use in crafting recipes.
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

core.register_craftitem(c.mod()..":spool",{
  description = S("Spool"),
  inventory_image = "circuits_spool.png",
  groups = {spool = 1, craft_item = 1}
})
core.register_alias("spool", c.mod()..":spool")

core.register_craftitem(c.mod()..":copper_wire_spool",{
  description = S("Copper Wire Spool"),
  inventory_image = "circuits_copper_spool.png",
  groups = {copper_spool = 1, craft_item = 1}
})
core.register_alias("copper_wire_spool", c.mod()..":copper_wire_spool")

-- crafts
-- MTG Support
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

  -- spool
  core.register_craft({
    output = "spool 9",
    recipe = {
      {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
      {"", "default:steel_ingot", ""},
      {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
    }
  })

  -- copper spool
  core.register_craft({
    output = "copper_wire_spool 6",
    recipe = {
      {"spool", "spool", "spool"},
      {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
      {"spool", "spool", "spool"}
    }
  })

-- Blockd Support
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