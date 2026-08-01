local c = circuits
function c.stack_max()
	if c.is_mod_enabled("default") then
		return 99
	elseif c.is_mod_enabled("blk") then
		return 256
	end
end
