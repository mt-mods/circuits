local c = circuits

-- Should be placed in circuits = in the node definition
-- Connect is "area", or "behind".
-- (Area will connect to any node next to it. Behind will connect through one node.)
-- Connects is a table of groups (without group:) that the node will connnect to in the network.
-- Storage is for storing the connection(s), options are meta, param1, and param2
-- Param1 and 2 can only be used if they are not used by the engine.
-- on_update is to be a function, params are npos and args.
-- This is called when other nodes in the network update the status, like when they turn it on.
function c.add_circuit_def(type, connect, connects, storage, on_update)
  if type and connect and connects and storage and on_update then
    local connection = nil
    if connect == "area" then
      connection = c.local_area()
    elseif connect == "behind" then
      connection = c.behind
    end
    if type == "power" then
      return {
        connnects = connection,
        connects_to = connects,
        store_connect = storage,
        on_update = on_update,
        powering = function(npos, rpos) return c.is_on(npos) end
      }
    else
      return {
        connnects = connection,
        connects_to = connects,
        store_connect = storage,
        on_update = on_update
      }
    end
  else
    core.log("error", "add_circuit_def was not completed, all fields are required.")
  end
end