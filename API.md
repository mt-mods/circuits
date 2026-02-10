These are functions contained within the namespace `circuits` to be used both
internally and externally. This documentation of them is a work in progress.
Many of these descriptions may be incomplete, missing, or incorrect. Take everything here 
with a grain of salt.  

# Supporting Circuits in your own mods
## Groups
There are three main groups used by the mod. `circuit_power` is the group that 
all power providing nodes should use. `circuit_wire` is the group that all wire 
nodes should use. And `circuit_consumer` is the group that all power using nodes 
should use.

## Definition Table
This mod requires that any node that will/should connect to a network have a 
circuits definition table. It is recommended that you fill out this by hand, 
we are working on a helper function that will make this easier.

## on_construct and on_destruct
You will need to add `circuits.on_construct(pos)` to your node's on_construct function.
And  `circuits.on_destruct(pos)` to your node's on_destruct function. If you don't then 
they will not be able to connect (or disconnect) from any other node.

## Modding Functions
So that you don't have to hunt through the rest of this document for the documentation 
on the above mentioned api's, we've added their documentation here for you.

## Circuits Definition
This is required in any node that will interact with nodes in this mod. 
Note that there are no defaults for these options, they were filled instead with the most common values. 
Fields are required unless otherwise stated.   
```lua
circuits = {
  connects = circuits.local_area
  -- Options are circuits.local_area and circuits.behind.
  connects_to = {"circuit_consumer", "circuit_wire", "circuit_power"},
  -- Table of types of nodes this one connects to.
  store_connect = "meta",
  -- Options are "meta", "param1", "param2", you must not use param1 or 2 if it will be used else where.
  on_update = function(npos, args)
    -- Code to execute when power states are updated.
  end
  powering = function(npos, rpos)
    return circuits.is_on(npos)
  end
  -- Only required by nodes that will provide power.
}
```

### on_construct
```lua
--- Attempts to connect all nodes next to that pos
-- @param pos table The pos at which to attempt to connect nodes.
circuits.on_construct(pos)
```

### on_destruct
```lua
--- Disconnects all nodes attached to that pos
-- @param pos table
circuits.on_destruct(pos)
```
### add_circuit_def
WARNING: This is an experimental function and should only be used for testing.
```lua
--- Should be placed in circuits = in the node definition table.
-- @param connect string values are "area", or "behind".
-- (Area will connect to any node next to it. Behind will connect through one node.)
-- @param connects table Of groups (without group:) that the node will connnect to in the network.
-- @param storage string Tells what storing method to use, options are meta, param1, and param2
-- Param1 and 2 can only be used if they are not used by the engine.
-- @param on_update function Params are npos and args.
-- This is called when other nodes in the network update the status, like when they turn it on.
function circuits.add_circuit_def(connect, connects, storage, on_update)
```

# Util Functions
These functions are contained within the `util.lua` file.
## register_on_off
```lua
--- Used to register both the on and the off nodes.
-- @param name string The name of the two nodes without `_on` or `_off`.
-- @param def table Node def that should be shared for both nodes.
-- @param on_def table Node def with values that only the on node should have.
-- @param off_def table Node def with values that only the off node should have.
circuits.register_on_off(name,def,on_def,off_def)
```
## get_circuit_def
```lua
--- Used to get the circuit definition from the node definition table.
-- @param node_name string The full name of the node.
-- @return circuits table If included in that nodes definition table.  
-- @return false If the node name is not valid or that node has no circuits table.
circuits.get_circuit_def(node_name)
```
## get_powered
```lua
--- Get the powered version name of the node located at the pos given.
-- @param npos table The npos of the node.
-- @return false If node does not have a powered version.
-- @return string Name of the node's powered version.
circuits.get_powered(npos)
```
## get_off
```lua
--- Get the off version name of the node located at the pos given.
-- @param npos table The npos of the node.
-- @return false If node does not have a off version.
-- @return string Name of the node's off version.
circuits.get_off(npos)
```
## is_on
```lua
--- Check if the node is on or off at the given pos
-- @param npos table The npos of the node.
-- @return true If the node is on.
-- @return false If the node is off.
-- @return nil If the node is not on or off, or if pos was not supplied.
circuits.is_on(npos)
```
## npos
```lua
--- Mutate a pos into a npos.
-- @param pos table The position the node is at.
-- @param [node] table A table of the name, param1, and param2.
-- @return npos
circuits.npos(pos[, node])
```
## on_construct
```lua
--- Attempts to connect all nodes next to that pos
-- @param pos table The pos at which to attempt to connect nodes.
circuits.on_construct(pos)
```
## on_destruct
```lua
--- Disconnects all nodes attached to that pos
-- @param pos table
circuits.on_destruct(pos)
```
## register_node
```lua
--- Registers nodes, used internally
-- @param name string The name of the node
-- @param def table The node definition table
circuits.register_node(name, def)
```

# Connect Functions
These functions are contained within the `connection.lua` file.
## connect
```lua
--- Attempt to connect 2 nodes together.
-- @param a table npos of node a.
-- @param b table npos of node b.
-- @return false If connection fails.
-- @return true If connection is made.
circuits.connect(a, b)
```
## disconnect
```lua
--- Disconnect node b from node a
-- @param a table npos of node a
-- @param b table npos of node b
-- @return true If disconnect is completed.
-- @return false If disconnection fails.
circuits.disconnect(a, b)
```
## connect_all
```lua
--- Connects a node to all nearby nodes.
-- @param node table npos of node to connect.
-- @return node If connection attempts are made.
circuits.connect_all(node)
```
## disconnect_all
```lua
--- Disconnects all connects for a node.
-- @param node table npos of node.
-- @return true If disconnection attempts are made.
-- @return false If disconnection fails.
circuits.disconnect_all
```
## get_connected_in_dir
```lua
--- Tells you if it's connected in that direction?
-- @param npos table npos of node.
-- @param dir
-- @param flags
circuits.get_connected_in_dir(npos, dir, flags)
```
## is_connected
```lua
--- Tells you if a node is connected.
-- @param npos table npos of a node.
-- @param to
-- @return true If node is connected.
-- @return false If node is not connected.
circuits.is_connected(npos, to)
```
## get_all_connected
```lua
--- Gets all connnections for a node.
-- @param node table npos of the node.
-- @return table
-- @return false If operation fails.
```

# Position Functions
These functions are contained within the `position.lua` file.
## dir_to_mount
```lua
--- Gives you the mapping matrix for each direction.
-- @param dir table dir in the form {y=-2}.
-- @return mounts
circuits.dir_to_mount(dir)
```
## pos_wallmount_relative
```lua
--- Converts wallmounted pos to a relative pos.
-- @param wallmount param of wallmounted node.
-- @param npos table pos of wallmounted node.
-- @param pos real pos of node.
circuits.pos_wallmout_relative(wallmount, npos, pos)
```
## wallmount_real_pos
```lua
--- Converts wallmounted relative pos into real pos.
-- @param wallmount param of wallmounted node.
-- @param npos table pos ot wallmounted node.
-- @param rpos table relative pos.
circuits.wallmount_real_pos(wallmounted, npos, rpos)
```
## facedir_to_dir
```lua
--- Gives you the vertical axis and axis transformations of a facedif node.
-- @param facedir
-- @return vertical axes and axis transformation.
circuits.facedir_to_dir(facedir)
```
## pos_facedir_relative
```lua
--- Transforms pos to pos relative to a facedir node.
-- @param facedir param of facedir node.
-- @param npos table pos of facedir node.
-- @param pos table real pos.
circuits.pos_facedir_relative(facedir, npos, pos)
```
## facedir_real_pos
```lua
--- Transform real pos into pos relative to facedir node.
-- @param facedir param of facedir node.
-- @param npos table of facedir node.
-- @param rpos talbe real pos.
circuits.facedir_real_pos(facedir, npos, rpos)
```
## relative_pos
```lua
-- @param node
-- @param pos
circuits.relative_pos(node, pos)
```
## relative_real_pos
```lua
-- @param node
-- @param rpos
circuits.relative_real_pos(node, rpos)
```
## invert_relative
```lua
-- @param dir
circuits.invert_relative(dir)
```
## rpos_is_dir
```lua
-- @param rpos
circuits.rpos_is_dir(rpos)
```
## rot_relative_pos
```lua
--- Takes two npos and gives you rpos of node a relative to any rotation a might have.
-- @param a table npos of node a.
-- @param b table npos of node b.
circuits.rot_relative_pos(a, b)
```
## rot_relative_real_pos
```lua
--- Takes a npos and an rpos, returns the real pos, relative to any rotation a might have.
-- @param a table npos a
-- @param rpos table rpos b
circuits.rot_relative_real_pos(a, rpos)
```

# Power Functions
These functions are contained within the `power.lua` file.
## is_powering
```lua
--- Checks if the npos node is powering.
-- @param npos table The npos of the powering node.
-- @param node table The npos of the powered node.
-- @return The circuit power definition of the npos node.
-- @return false If the node does not have a circuit powering definition.
circuits.is_powering(npos, node)
```
## wait
```lua
--- Inserts a delayed update.
-- @param npos table The npos to be updated.
-- @param args Any arguments for the update.
-- @param no_ticks The delay for the update.
circuits.wait(npos, args, no_ticks)
```
## update
```lua
--- Creates an update with no delay.
-- @param npos table The npos to be updated.
-- @param args Any arguments for the update.
circuits.update(npos, args)
```
## power_update
```lua
--- Creates a power update with no delay.
-- @param npos table The npos to be updated.
-- @param args Any arguments for the update.
circuits.power_update(npos, args)
```

# Wire Functions
This function is contained within the `wire.lua` file.
## wire.update
```lua
--- Updates the wire.
-- @param npos table The npos of the node to be updated.
circuits.wire_update(npos)
```